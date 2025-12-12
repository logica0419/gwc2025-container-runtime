# 1-2. OS (Linux) の基礎知識

この章では、OSのカーネルとプロセスについて説明します。

## OSとカーネル

皆さんご存知の通り、OSは**コンピューター全体の動作を管理・制御**し、コンピューター上で我々が書いたプログラムが動くようにしてくれるソフトウェアです。  
全てのOSは、様々な部品で成り立っています。その中で最も重要な役割を担うのが**カーネル**です。

![OSとカーネル](/1-basics/7.dio.png)

カーネルは、**CPU・メモリの直接制御**を担う、OSの中核部品です。  
一般的なOSは、このカーネルの上にシェル・デーモン・コマンドなど、**カーネルをより使いやすく**する部品を一緒に提供しています。

実は、**Linux**というのはこの**カーネル部分だけ**を指します。Linux公式はカーネルしか提供していません。  
Linuxカーネルに様々な部品を上乗せしてセットで提供しているのが、**Ubuntu**や**RHEL**に代表される**Linuxディストリビューション**です。  
Linux本体とディストリビューションの違いがわかっていなかった方は、ぜひこの機会に覚えておいて下さいね！

## プロセスとスレッド

ここからはLinuxに対象を絞って話を進めます。

アプリケーションを実行すると、OSの中では**プロセス**という実態が生成されます。  
アプリケーションが設計図、プロセスがそれを元に作られた実際の製品というイメージですね。  
プロセスは1つ1つがID (**プロセスID**/**PID**) を持ち、これをもって識別されます。

プロセスは、**自分に紐づいた(子)プロセスを生成**すること (**フォーク**) で増えていきます。  
Linuxでは**initプロセス**と呼ばれるプロセスが最初に起動し、これのPIDは**必ず1**になります。  
initプロセスは**他の全てのプロセスの親** (フォーク元) であり、他のプロセスは**initプロセスをルートとする木構造**を成します。

このプロセスの木構造は、`pstree`コマンドを使うことで確認することができます。

```plain
systemd-+-ModemManager---3*[{ModemManager}]
        |-agetty
        |-containerd---14*[{containerd}]
        |-containerd-shim-+-php-fpm---2*[php-fpm]
        |                 `-10*[{containerd-shim}]
        |-containerd-shim-+-mysqld---34*[{mysqld}]
        |                 `-10*[{containerd-shim}]
        |-cron
        |-dbus-daemon
        |-dockerd-+-5*[docker-proxy---7*[{docker-proxy}]]
        |         |-2*[docker-proxy---6*[{docker-proxy}]]
        |         `-27*[{dockerd}]
        |-fwupd---5*[{fwupd}]
        |-mdadm
        |-multipathd---6*[{multipathd}]
        |-polkitd---3*[{polkitd}]
        |-rsyslogd---3*[{rsyslogd}]
        |-sshd
        |-systemd-journal
        |-systemd-logind
        |-systemd-network
        |-systemd-resolve
        |-systemd-timesyn---{systemd-timesyn}
        |-systemd-udevd
        |-tailscaled---13*[{tailscaled}]
        |-thermald---4*[{thermald}]
        |-udisksd---5*[{udisksd}]
        |-unattended-upgr---{unattended-upgr}
        `-upowerd---3*[{upowerd}]
```

プロセスの亜種として**スレッド**というものも存在します。  
プロセスの場合はフォークする時**メモリの中身** (≒ 変数内のデータ) **がコピー**・分割されますが、スレッドの場合は紐づいた**全てのスレッド同士でデータが共有**されます (レジスタなど一部共有されないデータもあります)。  
プロセスよりもスレッドの方が**軽量**で、**goroutineの裏側ではスレッド**が使われていたりします。
