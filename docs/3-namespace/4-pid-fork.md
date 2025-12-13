# 3-4. PID Namespaceとfork

さあいよいよ今回の大詰め、**PID Namespace**です。  
(UTC、Mount、PID以外のNamespaceは、**効果を確かめにくい**ため今回は扱いません)

## PID Namespaceを分けてみる

PID Namespaceは非常に強力なNamespaceで、**プロセスIDの採番をやり直す**と共に、**Namespace外のプロセスを見えない**状態にします。  
PID Namespaceを分けると**Namespace内のinitプロセス (PID: 1)** が作られ、そこをルートとした新しいプロセスIDの採番がなされます。

ひとまず先程までと同じ要領でNamespaceを分けてみましょう！

### 想定解答

:::details 想定解答

```go
// runサブコマンド
func runCommand(c Config) error {
  // Namespaceを分離
  if err := unix.Unshare(unix.CLONE_NEWUTS | unix.CLONE_NEWNS); err != nil { // [!code --]
  if err := unix.Unshare(unixunix.CLONE_NEWUTS | unix.CLONE_NEWNS | unix.CLONE_NEWPID); err != nil { // [!code ++]
    return errors.WithStack(err)
  }

  // cgroupの設定
  if err := SetupCgroup(c.Name, os.Getpid(), c.Cgroup); err != nil {
    return errors.WithStack(err)
  }

  // rootfsの設定
  if err := SetupRootfs(c.Rootfs); err != nil {
    return errors.WithStack(err)
  }

  // 作成した簡易コンテナ内でエントリーポイントを実行
  path, err := exec.LookPath(c.EntryPoint[0])
  if err != nil {
    return errors.WithStack(err)
  }
  if err := unix.Exec(path, c.EntryPoint, os.Environ()); err != nil {
    return errors.WithStack(err)
  }

  return nil
}
```

:::

## 一筋縄ではいかないPID Namespace

PIDの採番がやり直されているか確かめてみましょう。

```console
$ sudo su
# make run
./main run bash
bash: fork: Cannot allocate memory
# echo $$
184720
#
```

おや、妙なエラーが出ていますね。  
また、PIDも**振り直されてなさ**そうです。[3-1](/3-namespace/1-os-exec-syscall)と同様にプロセスツリーを表示すると、**PIDが振り直されていない**ことがわかります。  

:::tip
`pstree`に入れるPIDを取得するのは、`sudo su`**した後のシェル**の方が見やすいと思います。
:::

```plaintext
Every 1.0s: pstree -p 184552

bash(184552)---make(184719)---bash(184720)
```

これには、PID Namespaceの**特別な仕様**が深く関わってきます。

## PID Namespaceの仕様

PID Namespaceは、Namespaceを**分離した後子プロセスを生成**をしないと正しく動かない仕様になっています。  
Namespaceを分離した後、生成された子プロセスが**Namespace内のinitプロセス (PID: 1)** になります。

![PID Namespaceの仕様](/3-namespace/2.dio.png)

Linuxの都合上、生成されたプロセスの**自認PIDを後から変更するのが不可能**なため、このような仕様になっているそうです。

## fork含めPID Namespaceを正しく実装する

では、PID Namespaceを**正しく**動かしてみましょう！  
以下のような処理の流れを実装してください。

1. cgroupの設定をする
   - コンテナの生成プロセスが暴走しないようにです
2. PID Namespaceを分けてfork
3. ここから先はfork先
4. 残りのNamespaceを分離
5. rootfsの設定
6. エントリーポイントの実行

:::details ヒント1
子プロセスを生やしたいときは`os/exec.Cmd`が使えましたね！  
今回は、新しいサブコマンドを作ったうえで**自分自身のサブコマンドを呼び出す**という方法が最適解のはずです。
:::

:::details ヒント2
`/proc/self/exe`は、常に自分自身のバイナリを指します。
:::

:::details ヒント3
Go側の都合で、PID Namespaceを**分離した後にexec.Cmdの実行はできません**！  
`exec.Cmd`には`SysProcAttr`という`*unix.SysProcAttr`型のフィールドがありますが、この中の`Cloneflags`というフィールドに`unix.Unshare()`に渡したのと同じフラッグを渡すと、**Namespaceを分けながら子プロセスを生成**してくれます。
:::

### 想定解答

:::details 想定解答

```go
func main() {
  // ～～～～～～～省略～～～～～～～

  // 指定されたサブコマンドの実行
  switch os.Args[1] {
  case "run":
    if err := runCommand(c); err != nil {
      log.Fatalln(errors.StackTraces(err))
    }

  case "init":
    if err := initCommand(c); err != nil {
      log.Fatalln(errors.StackTraces(err))
    }

  default:
    log.Fatalf("unknown command: %s", os.Args[1])
  }
}

// runサブコマンド
func runCommand(c Config) error {
  // cgroupの設定
  //  コンテナ作成処理が暴走すると困るので、他処理より前に行う
  if err := SetupCgroup(c.Name, os.Getpid(), c.Cgroup); err != nil {
    return errors.WithStack(err)
  }

  // exec.Cmdを使って自分自身を呼び出す
  cmd := exec.Command("/proc/self/exe", "init")
  cmd.Stdin, cmd.Stdout, cmd.Stderr = os.Stdin, os.Stdout, os.Stderr

  // Go側の都合で、PID Namespaceを分離した後にexec.Cmdの実行はできないので
  // PID Namespaceを分離しながら呼びだすようSysProcAttrを設定する
  cmd.SysProcAttr = &unix.SysProcAttr{
    Cloneflags: unix.CLONE_NEWPID,
  }

  if err := cmd.Run(); err != nil {
    return errors.WithStack(err)
  }

  return nil
}

// initサブコマンド
func initCommand(c Config) error {
  // 分離すべき残りのNamespaceを分離
  if err := unix.Unshare(unix.CLONE_NEWUTS | unix.CLONE_NEWNS); err != nil {
    return errors.WithStack(err)
  }

  // rootfsの設定
  if err := SetupRootfs(c.Rootfs); err != nil {
    return errors.WithStack(err)
  }

  // 作成した簡易コンテナ内でエントリーポイントを実行
  path, err := exec.LookPath(c.EntryPoint[0])
  if err != nil {
    return errors.WithStack(err)
  }
  if err := unix.Exec(path, c.EntryPoint, os.Environ()); err != nil {
    return errors.WithStack(err)
  }

  return nil
}
```

:::

## Namespaceが分かれたことを確かめる

実行したシェルの**PIDが1**になっていることを確かめましょう。  
Namespaceの分離には**root権限が必要**なので、`sudo su`を実行して**rootになってからプログラムを実行**して下さい。

```console
$ sudo su
# make run
go build -o main *.go
./main run bash
# echo $$
1
#
```

なお、`ps`コマンドが動くようにするためには`/proc`**ディレクトリの再マウント**が必要です。  
興味があれば調べてやってみて下さい。

ここまででNamespaceの実装は以上です。お疲れさまでした！
