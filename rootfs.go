package main

import (
	"os"

	"golang.org/x/sys/unix"
)

// rootfs設定
type RootfsConfig struct {
	// ルートファイルシステムのパス
	RootfsPath string `json:"rootfs_path"`
}

func SetupRootfs(c RootfsConfig) error {
	// 既存のルートファイルシステムを移動させるディレクトリを作成
	if err := os.MkdirAll(c.RootfsPath+"/.old_root", 0755); err != nil {
		return err
	}

	// RootfsPathをバインドマウントし、ルートファイルシステムの管轄外とする
	if err := unix.Mount(c.RootfsPath, c.RootfsPath, "", unix.MS_BIND, ""); err != nil {
		return err
	}

	// procディレクトリをマウント
	if err := os.MkdirAll(c.RootfsPath+"/proc", 0755); err != nil {
		return err
	}
	if err := unix.Mount("", c.RootfsPath+"/proc", "proc", 0, ""); err != nil {
		return err
	}

	// ルートファイルシステムのマウントを差し替え
	if err := unix.PivotRoot(c.RootfsPath, c.RootfsPath+"/.old_root"); err != nil {
		return err
	}

	// 古いルートファイルシステムはアンマウントし、不可視にする
	if err := unix.Unmount("/.old_root", unix.MNT_DETACH); err != nil {
		return err
	}

	return unix.Chdir("/")
}

// 参考: Chroot版の実装 (脆弱)
//
// func SetupRootfs(c RootfsConfig) error {
// 	if err := unix.Chroot(c.RootfsPath); err != nil {
// 		return err
// 	}
//
// 	return unix.Chdir("/")
// }
