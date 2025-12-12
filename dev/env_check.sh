#!/bin/sh

echo "---------- 🔍セットアップ状況🔍 ----------"
echo ""

SETUP_COMPLETED=1

if (uname >/dev/null 2>&1); then
	echo "[Linux] ✅ バージョン: $(uname -o) $(uname -r)"
else
	SETUP_COMPLETED=0
	echo "[Linux] ❌ Linux上で実行して下さい"
fi

if (type go >/dev/null 2>&1); then
	echo "[Go] ✅ バージョン: $(go version)"
else
	SETUP_COMPLETED=0
	echo "[Go] ❌ Goをインストールして下さい"
fi

if (type docker >/dev/null 2>&1); then
	echo "[Docker] ✅ バージョン: $(docker -v)"
else
	SETUP_COMPLETED=0
	echo "[Docker] ❌ Dockerをインストールして下さい"
fi

if [ -e ./config.json ] && [ -e ./spec/config.json ]; then
	echo "[make init] ✅ ファイル生成済み"
else
	SETUP_COMPLETED=0
	echo "[make init] ❌ \`make init\`を実行して下さい"
fi

if [ -d ./rootfs ] && [ -e ./rootfs/usr/bin/stress ]; then
	echo "[make rootfs] ✅ ファイル生成済み"
else
	SETUP_COMPLETED=0
	echo "[make rootfs] ❌ \`make rootfs\`を実行して下さい"
fi

if [ $SETUP_COMPLETED -eq 1 ]; then
	echo ""
	echo "---------- 🎉セットアップが完了しています🎉 ----------"
else
	echo ""
	echo "---------- 引き続きセットアップを続けて下さい ----------"
fi
