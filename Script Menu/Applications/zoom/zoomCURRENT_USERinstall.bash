#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
########################################
##ユーザー
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"

CURRENT_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
/bin/echo "実行ユーザー：" "$CURRENT_USER"

USER_TEMP_DIR=$(/usr/bin/mktemp -d)
/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"


CHK_APP_PATH="/Applications/zoom.us.app"
if [ -e "$CHK_APP_PATH" ]; then
/bin/echo "【エラー】$CHK_APP_PATHが存在します以下のコマンドをターミナルで実行してください"
/bin/echo "/usr/bin/sudo /bin/mv \"/Applications/zoom.us.app\" \"$HOME/.Trash\""
exit 1
fi
CHK_APP_PATH="/Applications/ZoomOutlookPlugin"
if [ -e "$CHK_APP_PATH" ]; then
/bin/echo "【エラー】$CHK_APP_PATHが存在します以下のコマンドをターミナルで実行してください"
/bin/echo "/usr/bin/sudo /bin/mv \"/Applications/ZoomOutlookPlugin\" \"$HOME/.Trash\""
exit 1
fi
CHK_APP_PATH="/Library/Application Support/zoom.us"
if [ -e "$CHK_APP_PATH" ]; then
/bin/echo "【エラー】$CHK_APP_PATHが存在します以下のコマンドをターミナルで実行してください"
/bin/echo "/usr/bin/sudo /bin/mv \"/Library/Application Support/zoom.us\" \"$HOME/.Trash\""
exit 1
fi


########################################
#起動ディスクの名前を取得する
/usr/bin/touch "$USER_TEMP_DIR/diskutil.plist"

/usr/sbin/diskutil info -plist / >"$USER_TEMP_DIR/diskutil.plist"
STARTUPDISK_NAME=$(/usr/bin/defaults read "$USER_TEMP_DIR/diskutil.plist" VolumeName)
/bin/echo "ボリューム名：" "$STARTUPDISK_NAME"

############################################################
##基本メンテナンス

##ライブラリの不可視属性を解除
/usr/bin/chflags nohidden "/Users/$CURRENT_USER/Library"
/usr/bin/SetFile -a v "/Users/$CURRENT_USER/Library"
##ユーザーアプリケーションフォルダを作る
/bin/mkdir -p "/Users/$CURRENT_USER/Applications"
/bin/chmod 700 "/Users/$CURRENT_USER/Applications"
/usr/sbin/chown "$CURRENT_USER" "/Users/$CURRENT_USER/Applications"
/usr/bin/touch "/Users/$CURRENT_USER/Applications/.localized"
##ユーザーユーティリティフォルダを作る
/bin/mkdir -p "/Users/$CURRENT_USER/Applications/Utilities"
/bin/chmod 755 "/Users/$CURRENT_USER/Applications/Utilities"
/usr/sbin/chown "$CURRENT_USER" "/Users/$CURRENT_USER/Applications/Utilities"
/usr/bin/touch "/Users/$CURRENT_USER/Applications/Utilities/.localized"
##　Managed Itemsフォルダを作る
/bin/mkdir -p "/Users/$CURRENT_USER/Library/Managed Items"
/bin/chmod 755 "/Users/$CURRENT_USER/Library/Managed Items"
/usr/sbin/chown "$CURRENT_USER" "/Users/$CURRENT_USER/Library/Managed Items"
/usr/bin/touch "/Users/$CURRENT_USER/Library/Managed Items/.localized"
##アクセス権チェック
/bin/chmod 700 "/Users/$CURRENT_USER/Library"
/bin/chmod 700 "/Users/$CURRENT_USER/Movies"
/bin/chmod 700 /"Users/$CURRENT_USER/Music"
/bin/chmod 700 "/Users/$CURRENT_USER/Pictures"
/bin/chmod 700 "/Users/$CURRENT_USER/Downloads"
/bin/chmod 700 "/Users/$CURRENT_USER/Documents"
/bin/chmod 700 "/Users/$CURRENT_USER/Desktop"
##全ローカルユーザーに対して実施したい処理があれば追加する
/bin/echo "ユーザーディレクトリチェックDONE"

#####ダウンロードディレクトリ
DOWNLOADS_DIR_PATH=$(/usr/bin/mktemp -d)
/bin/chmod 777 "$DOWNLOADS_DIR_PATH"
/bin/echo "ダウンロードディレクトリ：" "$DOWNLOADS_DIR_PATH"

/usr/bin/killall "zoom.us" 2>/dev/null
/usr/bin/killall "caphost" 2>/dev/null

#####古いファイルをゴミ箱に  USER
function DO_MOVE_TO_TRASH() {
	if [ -e "$1" ]; then
		TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$CURRENT_USER/.Trash/ZOOM.XXXXXXXX")
		/bin/chmod 777 "$TRASH_DIR"
		/bin/mv "$1" "$TRASH_DIR"
	fi
}

DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Applications/zoom.us.app"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Applications/ZoomOutlookPlugin"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Caches/us.zoom.xos"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/WebKit/us.zoom.xos"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Saved Application State/us.zoom.xos.savedState"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Receipts/ZoomMacOutlookPlugin.pkg.plist"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Receipts/ZoomMacOutlookPlugin.pkg.bom"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Logs/ZoomPhone"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Logs/zoom.us"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/HTTPStorages/us.zoom.xos.binarycookies"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/HTTPStorages/us.zoom.xos"

#####本処理　ダウンロード

ARCHITEC=$(/usr/bin/arch)
/bin/echo "Running on $ARCHITEC"
if [ "$ARCHITEC" == "arm64" ]; then

	#######################################
	STR_URL="https://zoom.us/client/latest/ZoomMacOutlookPlugin.pkg?archType=arm64"
	###ファイル名を取得
	PKG_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
	/bin/echo "PKG_FILE_NAME" "$PKG_FILE_NAME"
	if ! /usr/bin/curl -L -o "$DOWNLOADS_DIR_PATH/$PKG_FILE_NAME" "$STR_URL" --connect-timeout 20; then
		/bin/echo "ファイルのダウンロードに失敗しました HTTP1.1をトライします"
		/usr/bin/curl -L -o "$DOWNLOADS_DIR_PATH/$PKG_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20
	fi
	/usr/bin/killall "zoom.us" 2>/dev/null
	/usr/bin/killall "caphost" 2>/dev/null
	###本処理　インストール
	/usr/sbin/installer -pkg "$DOWNLOADS_DIR_PATH/$PKG_FILE_NAME" -target CurrentUserHomeDirectory -dumplog -allowUntrusted -lang ja

	#######################################
	STR_URL="https://zoom.us/client/latest/Zoom.pkg?archType=arm64"
	###ファイル名を取得
	PKG_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
	/bin/echo "PKG_FILE_NAME" "$PKG_FILE_NAME"
	if ! /usr/bin/curl -L -o "$DOWNLOADS_DIR_PATH/$PKG_FILE_NAME" "$STR_URL" --connect-timeout 20; then
		/bin/echo "ファイルのダウンロードに失敗しました HTTP1.1をトライします"
		/usr/bin/curl -L -o "$DOWNLOADS_DIR_PATH/$PKG_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20
	fi
	/usr/bin/killall "zoom.us" 2>/dev/null
	/usr/bin/killall "caphost" 2>/dev/null
	###本処理　インストール
	/usr/sbin/installer -pkg "$DOWNLOADS_DIR_PATH/$PKG_FILE_NAME" -target CurrentUserHomeDirectory -dumplog -allowUntrusted -lang ja

else

	#######################################
	STR_URL="https://zoom.us/client/latest/ZoomMacOutlookPlugin.pkg?archType=x86"
	###ファイル名を取得
	PKG_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
	/bin/echo "PKG_FILE_NAME" "$PKG_FILE_NAME"
	if ! /usr/bin/curl -L -o "$DOWNLOADS_DIR_PATH/$PKG_FILE_NAME" "$STR_URL" --connect-timeout 20; then
		/bin/echo "ファイルのダウンロードに失敗しました HTTP1.1をトライします"
		/usr/bin/curl -L -o "$DOWNLOADS_DIR_PATH/$PKG_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20
	fi
	/usr/bin/killall "zoom.us" 2>/dev/null
	/usr/bin/killall "caphost" 2>/dev/null
	###本処理　インストール
	/usr/sbin/installer -pkg "$DOWNLOADS_DIR_PATH/$PKG_FILE_NAME" -target CurrentUserHomeDirectory -dumplog -allowUntrusted -lang ja

	#######################################
	STR_URL="https://zoom.us/client/latest/Zoom.pkg?archType=x86"
	###ファイル名を取得
	PKG_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
	/bin/echo "PKG_FILE_NAME" "$PKG_FILE_NAME"
	if ! /usr/bin/curl -L -o "$DOWNLOADS_DIR_PATH/$PKG_FILE_NAME" "$STR_URL" --connect-timeout 20; then
		/bin/echo "ファイルのダウンロードに失敗しました HTTP1.1をトライします"
		/usr/bin/curl -L -o "$DOWNLOADS_DIR_PATH/$PKG_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20
	fi
	/usr/bin/killall "zoom.us" 2>/dev/null
	/usr/bin/killall "caphost" 2>/dev/null
	###本処理　インストール
	/usr/sbin/installer -pkg "$DOWNLOADS_DIR_PATH/$PKG_FILE_NAME" -target CurrentUserHomeDirectory -dumplog -allowUntrusted -lang ja

fi

PLIST_DICT="<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$HOME/Applications/zoom.us.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
/usr/bin/defaults write com.apple.dock persistent-apps -array-add "$PLIST_DICT"

/usr/bin/killall Dock

/bin/echo "処理終了しました"

exit 0
