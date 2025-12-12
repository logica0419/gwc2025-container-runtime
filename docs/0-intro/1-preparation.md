# 事前準備

今回作成する低レベルコンテナランタイムは、**Linuxの機能に強く依存**しているソフトウェアです。  
すなわち、Linuxの上で動かすことは**必須**の条件です。

ハンズオンパートをスムーズに進めるため、**Dev Container**か**ローカルLinux**のどちらかを準備して下さい。

## 共通準備

1. <https://github.com/logica0419/gwc2025-container-runtime>をフォークする
2. フォークを普段通り自分のPCにクローンする

```bash
git clone https://github.com/{あなたのアカウント名}/gwc2025-container-runtime
cd gwc2025-container-runtime
```

## Dev Container (推奨)

本ワークショップでは、**Dev Container**設定ファイルを用意しています。  
Dev Containerは**開発環境をコンテナとして定義**し、エディタ/IDEをその中で実行できる仕組みです。

### 前提条件

- PCに**Docker**が入っている
  - Docker Desktopで大丈夫です

::: warning 注意
OCI Runtimeに**runc以外**を指定している場合、構築に失敗する可能性があります (youkiでは構築できませんでした)。  
該当者はほぼいないと思いますが、念のため記載しておきます。
:::

### VS Codeの場合

[公式ドキュメント](https://code.visualstudio.com/docs/devcontainers/containers)の通りです。

1. [Dev Containers拡張機能](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)をVS Codeにインストール
2. 右下に以下のような通知が出るはずなので「**コンテナーで再度開く**」をクリック
   - 通知が出なければ再度VS Codeを開き直してください  
![通知](/0-intro/1.png)
3. しばらく待てば環境構築が終わっているはずです

### GoLandの場合

[公式ドキュメント](https://pleiades.io/help/go/connect-to-devcontainer.html)の通りです。  
「[IDE 内で Dev Container を起動する](https://pleiades.io/help/go/start-dev-container-inside-ide.html)」の手順で恐らく大丈夫だと思います。

::: info 注意
講師はVS Codeを使用しているため、**十分にサポートできない**場合があります。
:::

### その他のエディタ/IDEの場合

ご自身の使っているエディタが**Dev Containerに対応**している場合、その手順に従って構築して下さい。

::: info 注意
講師はVS Codeを使用しているため、**十分にサポートできない**場合があります。
:::

## ローカルLinux

Dev Containersを使わなくとも、今回の**コードがLinux上で起動**できれば問題ありません。  
以下のような手段が取れるかと思います。ご興味があれば挑戦してみて下さい。

### 用意して欲しい環境

- Linux
  - ディストリビューションは何でもOKです
- **Go**がインストールされている
- **Docker**がインストールされている

また、上記の準備が終わったら、以下の2つのコマンドを実行して下さい。

```bash
make init
make rootfs
```

### Windowsの場合

[WSL](https://learn.microsoft.com/ja-jp/windows/wsl/)での構築が最も手軽です。  
VS Codeの場合、[WSL拡張機能](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)を導入すれば、普段の環境とほぼ差異無く開発ができます。

### Macの場合

[UTM](https://mac.getutm.app/)を使ってLinuxを起動するのがメジャーらしいです。  
VS Codeの場合、[Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)などで直接編集できるようにしておくと良いでしょう。

::: info 注意
講師は普段Windows + WSLを使用しているため、**十分にサポートできない**場合があります。
:::

### Linuxの場合

ワークショップで用いるコンピューターのOSが**既にLinux**であれば、そのまま使っていただいて大丈夫です。

## セットアップ確認

環境のセットアップが終わったら、`make check`コマンドで確認をお願いします。  
以下のように、全ての項目が ✅ になればOKです。

```console
$ make check
---------- 🔍セットアップ状況🔍 ----------

[Linux] ✅ バージョン: GNU/Linux 6.6.87.2-microsoft-standard-WSL2
[Go] ✅ バージョン: go version go1.25.5 linux/amd64
[Docker] ✅ バージョン: Docker version 29.1.2, build 890dcca
[make init] ✅ ファイル生成済み
[make rootfs] ✅ ファイル生成済み

---------- 🎉セットアップが完了しています🎉 ----------
```
