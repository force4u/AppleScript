#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#ユーザード ~/Library/Application Support　にインストールする
#7zバージョン2501版

###ダウンロードURL
STR_URL="https://github.com/ip7z/7zip/releases/download/25.01/7z2501-mac.tar.xz"
STR_URL="https://www.7-zip.org/a/7z2501-mac.tar.xz"

########################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行ユーザーは：$USER_WHOAMI"
###実行しているユーザー名
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
/bin/echo "コンソールユーザー：$CONSOLE_USER"
###ログイン名ユーザー名※Visual Studio Codeの出力パネルではrootになる設定がある
LOGIN_NAME=$(/usr/bin/logname)
/bin/echo "ログイン名：$LOGIN_NAME"
###UID
USER_NAME=$(/usr/bin/id -un)
/bin/echo "ユーザー名:$USER_NAME"
###SUDOUSER
/bin/echo "SUDO_USER: $SUDO_USER"
########################################
###ダウンロード起動時に削除する項目
USER_TEMP_DIR=$(/usr/bin/mktemp -d)
/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"
############################################################
############################################################
###BIN
/bin/mkdir -p "/Users/$CONSOLE_USER/Library/Application Support"
for ((numTimes = 1; numTimes <= 3; numTimes++)); do
	sleep 1
	/bin/mkdir -p "/Users/$CONSOLE_USER/Library/Application Support/7zip"
	/usr/bin/touch "/Users/$CONSOLE_USER/Library/Application Support/7zip"
	/usr/sbin/chown "$CONSOLE_USER" "/Users/$CONSOLE_USER/Library/Application Support/7zip"
	/bin/chmod 700 "/Users/$CONSOLE_USER/Library/Application Support"
done

###ファイル名を取得
DL_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
/bin/echo "DL_FILE_NAME:$DL_FILE_NAME"
###ダウンロード
if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/$DL_FILE_NAME" "$STR_URL" --connect-timeout 20; then
	/bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
	if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/$DL_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20; then
		/bin/echo "ファイルのダウンロードに失敗しました"
		exit 1
	fi
fi
##全ユーザー実行可能にしておく
/bin/chmod 755 "$USER_TEMP_DIR/$DL_FILE_NAME"
/bin/echo "ダウンロードOK"
/bin/mkdir -p "$USER_TEMP_DIR/7zip/"
############################################################
######### インストール
/bin/echo "インストール開始:" "$CONSOLE_USER"
####解凍
##	/usr/bin/bsdtar -xzf "$USER_TEMP_DIR/$DL_FILE_NAME" -C "$USER_TEMP_DIR/7zip" --strip-components=1
/usr/bin/bsdtar -xzf "$USER_TEMP_DIR/$DL_FILE_NAME" -C "$USER_TEMP_DIR/7zip"
sleep 2
###旧バージョンをゴミ箱に
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/7ZZ.XXXXXXXX")
/bin/mv "/Users/$CONSOLE_USER/Library/Application Support/7zip/7zz" "$USER_TRASH_DIR"

####移動
/usr/bin/ditto "$USER_TEMP_DIR/7zip" "/Users/$CONSOLE_USER/Library/Application Support/7zip"
####終了
/bin/echo "インストール終了:" "$CONSOLE_USER"
###保存先を開く
/usr/bin/open "/Users/$CONSOLE_USER/Library/Application Support/7zip"
exit 0
