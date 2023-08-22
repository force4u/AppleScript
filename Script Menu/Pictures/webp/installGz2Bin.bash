#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
# CLIコマンドツール webpを /Users/ユーザー名/bin/webpに展開します
########################################
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
/bin/echo "コンソールユーザー(scutil):$CONSOLE_USER"

STR_BASE_URL="https://storage.googleapis.com/downloads.webmproject.org/releases/webp/"
STR_RELEASE_HTMLFILE="index.html"
STR_RESPONSE=$(/usr/bin/curl -s "$STR_BASE_URL$STR_RELEASE_HTMLFILE" | grep mac-arm64 | grep -v rc | grep -v asc| awk -F'[<>]' '{print $3}')
/bin/echo "リリースリスト:$STR_RESPONSE"
STR_FILENAME=$(/bin/echo -e "$STR_RESPONSE" | tail -n 1)
/bin/echo "最新バージョン:$STR_FILENAME"

########################################
###ダウンロード起動時に削除する項目
USER_TEMP_DIR=$(/usr/bin/mktemp -d)
/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"
###ダウンロード
if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/$STR_FILENAME" "$STR_BASE_URL$STR_FILENAME" --connect-timeout 20; then
	/bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
	if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/$STR_FILENAME" "$STR_BASE_URL$STR_FILENAME" --http1.1 --connect-timeout 20; then
		/bin/echo "ファイルのダウンロードに失敗しました"
		exit 1
	fi
fi
########################################
######### インストール
/bin/echo "インストール開始:" "$CONSOLE_USER"
####解凍
/bin/mkdir -p "$USER_TEMP_DIR/libwebp/"
/usr/bin/bsdtar -xzf "$USER_TEMP_DIR/$STR_FILENAME" -C "$USER_TEMP_DIR/libwebp" --strip-components=1
####上書きコピー ditto
/usr/bin/ditto "$USER_TEMP_DIR/libwebp" "/Users/$CONSOLE_USER/bin/libwebp"

####終了
/bin/echo "インストール終了:" "$CONSOLE_USER"
exit 0
