#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe

########################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"
if [ "$USER_WHOAMI" != "root" ]; then
	/bin/echo "このスクリプトを実行するには管理者権限が必要です。"
	/bin/echo "sudo で実行してください"
	### path to me
	SCRIPT_PATH="${BASH_SOURCE[0]}"
	/bin/echo "/usr/bin/sudo \"$SCRIPT_PATH\""
	/usr/bin/printf "\n ↑ を実行してください\n\n"
	exit 1
else
	###実行しているユーザー名
	SUDO_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
	/bin/echo "実行ユーザー：" "$SUDO_USER"
fi
###失敗して２回目の時用
/usr/bin/hdiutil detach "/Volumes/RUM" -force
#################################
##ダウンロードディレクトリ
LOCAL_TMP_DIR=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/mktemp -d)
/bin/echo "TMPDIR：" "$LOCAL_TMP_DIR"

###CPUタイプでの分岐
ARCHITEC=$(/usr/bin/arch)
if [ "$ARCHITEC" == "arm64" ]; then
	/bin/echo "Running on $ARCHITEC"
	###ARM用のダウンロードURL
	STR_URL="https://deploymenttools.acp.adobeoobe.com/RUM/AppleSilicon/RemoteUpdateManager.dmg"
	###ファイル名を取得
	DL_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
	/bin/echo "DL_FILE_NAME:$DL_FILE_NAME"
	###ダウンロード
	if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$DL_FILE_NAME" "$STR_URL" --connect-timeout 20; then
		/bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
		if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$DL_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20; then
			/bin/echo "ファイルのダウンロードに失敗しました"
			exit 1
		fi
	fi
else
	/bin/echo "Running on $ARCHITEC"
	###INTEL用のダウンロードURL
	STR_URL="https://deploymenttools.acp.adobeoobe.com/RUM/MacIntel/RemoteUpdateManager.dmg"
	###ファイル名を取得
	DL_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
	/bin/echo "DL_FILE_NAME:$DL_FILE_NAME"
	###ダウンロード
	if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$DL_FILE_NAME" "$STR_URL" --connect-timeout 20; then
		/bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
		if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$DL_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20; then
			/bin/echo "ファイルのダウンロードに失敗しました"
			exit 1
		fi
	fi
fi
###HUM.dylibバージョンチェック
STR_PLIST_PATH="$LOCAL_TMP_DIR/installed.plist"
STR_LIB_PATH="/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/HUM.dylib"
if [ "$ARCHITEC" == "arm64" ]; then
	/Library/Developer/CommandLineTools/usr/bin/llvm-otool -arch arm64 -P "$STR_LIB_PATH" >"$STR_PLIST_PATH"
	##最初の２行を削除
	/usr/bin/sed -i '' -e '1,2d' "$STR_PLIST_PATH"
else
	/Library/Developer/CommandLineTools/usr/bin/llvm-otool -arch x86_64 -P "$STR_LIB_PATH" >"$STR_PLIST_PATH"
	##最初の２行を削除
	/usr/bin/sed -i '' -e '1,2d' "$STR_PLIST_PATH"
fi
STR_LIB_VAR=$(/usr/bin/defaults read "$STR_PLIST_PATH" CFBundleVersion)
/bin/echo "HUM-INSTALLED:$STR_LIB_VAR"
###ディスクマウント
/usr/bin/hdiutil attach "$LOCAL_TMP_DIR/$DL_FILE_NAME" -noverify -nobrowse -noautoopen
###ダウンロードしたHUM.dylibのバージョンを確認
STR_LIB_PATH_DMG="/Volumes/RUM/HUM.dylib"
STR_PLIST_PATH="$LOCAL_TMP_DIR/new.plist"
if [ "$ARCHITEC" == "arm64" ]; then
	/Library/Developer/CommandLineTools/usr/bin/llvm-otool -arch arm64 -P "$STR_LIB_PATH_DMG" >"$STR_PLIST_PATH"
else
	/Library/Developer/CommandLineTools/usr/bin/llvm-otool -arch x86_64 -P "$STR_LIB_PATH_DMG" >"$STR_PLIST_PATH"
fi
##最初の２行を削除
/usr/bin/sed -i '' -e '1,2d' "$STR_PLIST_PATH"
STR_LIB_NEW_VAR=$(/usr/bin/defaults read "$STR_PLIST_PATH" CFBundleVersion)
/bin/echo "HUM-DMG:$STR_LIB_NEW_VAR"
###HUM.dylibは同じかそれ以上のバージョンなら上書きする
if [[ ! $STR_LIB_NEW_VAR > $STR_LIB_VAR ]]; then
	/usr/bin/sudo /usr/bin/ditto "/Volumes/RUM/HUM.dylib" "$STR_LIB_PATH"
	/usr/bin/sudo /usr/sbin/chown -Rf root "$STR_LIB_PATH"
	/bin/echo "HUM COPY DONE"
fi
###RemoteUpdateManagerは上書き
/usr/bin/sudo /usr/bin/ditto /Volumes/RUM/RemoteUpdateManager /usr/local/bin/RemoteUpdateManager
/usr/bin/sudo /usr/sbin/chown -Rf root /usr/local/bin/RemoteUpdateManager

/usr/bin/hdiutil detach "/Volumes/RUM" -force

/usr/local/bin/RemoteUpdateManager -h


exit
