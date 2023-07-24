#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#ユーザードメインにインストール
########################################
##OS
PLIST_PATH="/System/Library/CoreServices/SystemVersion.plist"
STR_OS_VER=$(/usr/bin/defaults read "$PLIST_PATH" ProductVersion)
/bin/echo "OS VERSION ：" "$STR_OS_VER"
STR_MAJOR_VERSION="${STR_OS_VER%%.*}"
/bin/echo "STR_MAJOR_VERSION ：" "$STR_MAJOR_VERSION"
STR_MINOR_VERSION="${STR_OS_VER#*.}"
/bin/echo "STR_MINOR_VERSION ：" "$STR_MINOR_VERSION"

########################################
##ユーザー
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"
CURRENT_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
/bin/echo "実行ユーザー：" "$CURRENT_USER"

########################################
##デバイス
USER_TEMP_DIR=$(/usr/bin/mktemp -d)
/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"
#起動ディスクの名前を取得する
/usr/bin/touch "$USER_TEMP_DIR/diskutil.plist"
/usr/sbin/diskutil info -plist / >"$USER_TEMP_DIR/diskutil.plist"
STARTUPDISK_NAME=$(/usr/bin/defaults read "$USER_TEMP_DIR/diskutil.plist" VolumeName)
/bin/echo "ボリューム名：" "$STARTUPDISK_NAME"

########################################
###ダウンロード起動時に削除する項目

###CPUタイプでの分岐
ARCHITEC=$(/usr/bin/arch)
/bin/echo "Running on $ARCHITEC"
if [ "$ARCHITEC" == "arm64" ]; then
	###ARM用のダウンロードURL
	STR_URL="https://get.skype.com/go/getskype-skypeformac"
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
else
	###INTEL用のダウンロードURL
	STR_URL="https://get.skype.com/go/getskype-skypeformac"
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
fi
##全ユーザー実行可能にしておく
/bin/chmod 755 "$USER_TEMP_DIR/$DL_FILE_NAME"
/bin/echo "ダウンロードOK"

########################################
###アプリケーションの終了
###コンソールユーザーにのみ処理する
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
/bin/echo "CONSOLE_USER:$CONSOLE_USER"
if [ -z "$CONSOLE_USER" ]; then
	/bin/echo "コンソールユーザーが無い=電源入れてログインウィンドウ状態"
else
	#####OSAスクリプトはエラーすることも多い(初回インストール時はエラーになる)
	if ! /usr/bin/osascript -e "tell application id \"com.skype.skype\" to quit"; then
		##念の為　KILLもする
		/usr/bin/killall "Skype" 2>/dev/null
		/usr/bin/killall "Skype Helper" 2>/dev/null
		/usr/bin/killall "Skype Helper (GPU)" 2>/dev/null
		/usr/bin/killall "Skype Helper (Renderer)" 2>/dev/null
	fi
fi
/bin/sleep 2

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

############################################################
#####古いファイルをゴミ箱に  USER
function DO_MOVE_TO_TRASH() {
	if [ -e "$1" ]; then
		TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$CURRENT_USER/.Trash/SKYPE.XXXXXXXX")
		/bin/chmod 777 "$TRASH_DIR"
		/bin/mv "$1" "$TRASH_DIR"
	fi
}
#####古いファイルをゴミ箱に  USER
DO_MOVE_TO_TRASH "/Applications/Skype.app"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Applications/Skype.app"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Caches/com.skype.skype"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Caches/com.skype.skype.ShipIt"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Microsoft/Skype for Desktop/Cache"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Microsoft/Skype for Desktop/Code Cache"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Microsoft/Skype for Desktop/Crashpad"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Microsoft/Skype for Desktop/GPUCache"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Microsoft/Skype for Desktop/logs"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/HTTPStorages/com.skype.skype"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Logs/Skype Helper (Renderer)"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Saved Application State/com.skype.skype.savedState"

/bin/echo "ユーザーキャッシュ削除DONE"
############################################################
###/var/folde T
MKTEMP_DIR=$(/usr/bin/mktemp -d)
TEMP_DIR_T="$(/usr/bin/dirname "$MKTEMP_DIR")"
function DO_MOVE_TO_TRASH_T() {
	if [ -e "$1" ]; then
		TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$CURRENT_USER/.Trash/SKYPE.T.XXXXXXXX")
		/bin/chmod 777 "$TRASH_DIR"
		/bin/mv "$1" "$TRASH_DIR"
	fi
}
#####古いファイルをゴミ箱に
DO_MOVE_TO_TRASH_T "$TEMP_DIR_T/Skype"
DO_MOVE_TO_TRASH_T "$TEMP_DIR_T/Skype Helper"
DO_MOVE_TO_TRASH_T "$TEMP_DIR_T/Skype Helper (GPU)"
DO_MOVE_TO_TRASH_T "$TEMP_DIR_T/Skype Helper (Renderer)"

/bin/echo "ユーザーキャッシュT DONE"
############################################################
###/var/folder C
TEMP_DIR="$(/usr/bin/dirname "$TEMP_DIR_T")"
TEMP_DIR_C="${TEMP_DIR}/C"
function DO_MOVE_TO_TRASH_C() {
	if [ -e "$1" ]; then
		TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$CURRENT_USER/.Trash/SKYPE.C.XXXXXXXX")
		/bin/chmod 777 "$TRASH_DIR"
		/bin/mv "$1" "$TRASH_DIR"
	fi
}
#####古いファイルをゴミ箱に
DO_MOVE_TO_TRASH_C "$TEMP_DIR_C/com.skype.skype"
DO_MOVE_TO_TRASH_C "$TEMP_DIR_C/com.skype.skype.Helper"
DO_MOVE_TO_TRASH_C "$TEMP_DIR_C/com.skype.skype.Helper-(GPU)"
DO_MOVE_TO_TRASH_C "$TEMP_DIR_C/com.skype.skype.Helper-(Renderer)"
/bin/echo "ユーザーキャッシュ C DONE"

############################################################
######### DITTOコピーインストール
/bin/echo "インストール開始:DITTO:" "$CURRENT_USER"
###ディスクをマウント
/usr/bin/hdiutil attach "$USER_TEMP_DIR/$DL_FILE_NAME" -noverify -nobrowse -noautoopen
sleep 2
####コピーして
/usr/bin/ditto "/Volumes/Skype/Skype.app" "/Users/$CURRENT_USER/Applications/Skype.app"
sleep 2
###ディスクをアンマウント
/usr/bin/hdiutil detach /Volumes/Skype -force
###Dockに追加して
/usr/bin/defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$HOME/Applications/Skype.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
###反映させて
/usr/bin/killall cfprefsd
###Dockを再起動
/usr/bin/killall Dock

exit 0
