# 1-3. syscallとシステムプログラミング

この章では、コンテナを作る上で欠かせない、syscallについて解説していきます。

## syscall (システムコール)

**syscall** (システムコール) は、カーネルが**アプリケーションのため**に用意している**API**で、**カーネルを操作**するためのほぼ唯一の方法です。  
Go言語を書いているときsyscallを直接呼ぶことはほとんど無いですが、Go**標準ライブラリ**に不可欠なだけでなく、**シェル**や各種**コマンド**など、我々の開発に欠かせないツールで広く使われています。


syscallは基本的に**C言語ライブラリ**の形で提供されており、**機能ごとに関数**が用意されています。
syscallの代表例として、ここでは`open()`/`close()`/`read()`/`write()`を紹介します。  
コンテナランタイム作成では使いませんが、**ファイル操作のほとんど**を担う重要なAPIです。

```c
int open(const char *path, int flags, mode_t mode);
int close(int fd);
ssize_t read(int fd, void *buf, size_t count);
ssize_t write(int fd, const void *buf, size_t count);
```

見ていただくと、**Goの`os`や`io`標準ライブラリと似た**APIになっているのがわかると思います。  
ただ、Goの標準ライブラリよりはかなり**無骨**な作りになっており、より**細かい制御**ができるのが特徴です。

Linuxのマニュアルは**manページ**というものにまとめられており、syscallはこの**第2章**に書かれています。  
manの各ページのタイトルは`名前(章番号)`となっているため、`open()`syscallは`open(2)`と記載されています。  
manページの日本語訳は以下のURLに置いてありますので、syscallがわからなくなったときは以下のページを参照すると良いでしょう。

<https://linuxjm.sourceforge.io/INDEX/ldp.html#sec2>

## Go言語からsyscallを呼ぶ
