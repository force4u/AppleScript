#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#ユーザードメインにインストール
########################################
##他のユーザーインストールに対応
CHK_APP_PATH="/Applications/Google Chrome.app"
if [ -e "$CHK_APP_PATH" ]; then
TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/Chrome.XXXXXXXX")
/bin/chmod 777 "$TRASH_DIR"
/bin/mv "$CHK_APP_PATH" "$TRASH_DIR"
fi
if [ -e "$CHK_APP_PATH" ]; then
	/bin/echo "【エラー】$CHK_APP_PATHが存在します以下のコマンドをターミナルで実行してください"
	/bin/echo "/usr/bin/sudo /bin/mv \"$CHK_APP_PATH\" \"$HOME/.Trash\""
	exit 1
fi
##
CHK_APP_PATH="/Library/Google/Google Chrome Brand.plist"
if [ -e "$CHK_APP_PATH" ]; then
TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/Chrome.XXXXXXXX")
/bin/chmod 777 "$TRASH_DIR"
/bin/mv "$CHK_APP_PATH" "$TRASH_DIR"
fi
if [ -e "$CHK_APP_PATH" ]; then
	/bin/echo "【エラー】$CHK_APP_PATHが存在します以下のコマンドをターミナルで実行してください"
	/bin/echo "/usr/bin/sudo /bin/mv \"$CHK_APP_PATH\" \"$HOME/.Trash\""
	exit 1
fi
##
CHK_APP_PATH="/Library/Google/GoogleSoftwareUpdate"
if [ -e "$CHK_APP_PATH" ]; then
TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/Chrome.XXXXXXXX")
/bin/chmod 777 "$TRASH_DIR"
/bin/mv "$CHK_APP_PATH" "$TRASH_DIR"
fi
if [ -e "$CHK_APP_PATH" ]; then
	/bin/echo "【エラー】$CHK_APP_PATHが存在します以下のコマンドをターミナルで実行してください"
	/bin/echo "/usr/bin/sudo /bin/mv \"$CHK_APP_PATH\" \"$HOME/.Trash\""
	exit 1
fi
##
CHK_APP_PATH="/Library/LaunchAgents/com.google.keystone.agent.plist"
if [ -e "$CHK_APP_PATH" ]; then
TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/Chrome.XXXXXXXX")
/bin/chmod 777 "$TRASH_DIR"
/bin/mv "$CHK_APP_PATH" "$TRASH_DIR"
fi
if [ -e "$CHK_APP_PATH" ]; then
	/bin/echo "【エラー】$CHK_APP_PATHが存在します以下のコマンドをターミナルで実行してください"
	/bin/echo "/usr/bin/sudo /bin/mv \"$CHK_APP_PATH\" \"$HOME/.Trash\""
	exit 1
fi
##
CHK_APP_PATH="/Library/LaunchAgents/com.google.keystone.xpcservice.plist"
if [ -e "$CHK_APP_PATH" ]; then
TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/Chrome.XXXXXXXX")
/bin/chmod 777 "$TRASH_DIR"
/bin/mv "$CHK_APP_PATH" "$TRASH_DIR"
fi
if [ -e "$CHK_APP_PATH" ]; then
	/bin/echo "【エラー】$CHK_APP_PATHが存在します以下のコマンドをターミナルで実行してください"
	/bin/echo "/usr/bin/sudo /bin/mv \"$CHK_APP_PATH\" \"$HOME/.Trash\""
	exit 1
fi
##
CHK_APP_PATH="/Library/LaunchDaemons/com.google.keystone.daemon.plist"
if [ -e "$CHK_APP_PATH" ]; then
TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/Chrome.XXXXXXXX")
/bin/chmod 777 "$TRASH_DIR"
/bin/mv "$CHK_APP_PATH" "$TRASH_DIR"
fi
if [ -e "$CHK_APP_PATH" ]; then
	/bin/echo "【エラー】$CHK_APP_PATHが存在します以下のコマンドをターミナルで実行してください"
	/bin/echo "/usr/bin/sudo /bin/mv \"$CHK_APP_PATH\" \"$HOME/.Trash\""
	exit 1
fi





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
###ダウンロード起動時に削除する項目
USER_TEMP_DIR=$(/usr/bin/mktemp -d)
/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"

########################################
##デバイス
USER_TEMP_DIR=$(/usr/bin/mktemp -d)
/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"
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

##　Managed Itemsフォルダを作る
/bin/mkdir -p "/Users/$CURRENT_USER/Library/Managed Items"
/bin/chmod 755 "/Users/$CURRENT_USER/Library/Managed Items"
/usr/sbin/chown "$CURRENT_USER" "/Users/$CURRENT_USER/Library/Managed Items"
/usr/bin/touch "/Users/$CURRENT_USER/Library/Managed Items/.localized"

########################################
###アクアセス権　修正
STR_USER_DIR="/Users/$CURRENT_USER"

LIST_SUB_DIR_NAME=("Desktop" "Developer" "Documents" "Downloads" "Groups" "Library" "Movies" "Music" "Pictures" "jpki" "bin" "Creative Cloud Files")

for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
	/bin/chmod 700 "$STR_USER_DIR/${ITEM_DIR_NAME}"
done
/bin/chmod 755 "$STR_USER_DIR/Public"
/bin/chmod 755 "$STR_USER_DIR/Sites"
/bin/chmod 755 "$STR_USER_DIR/Library/Caches"

########################################
##ユーザーアプリケーションフォルダを作る
STR_USER_APP_DIR="/Users/$CURRENT_USER/Applications"
/bin/mkdir -p "$STR_USER_APP_DIR"
/bin/chmod 700 "$STR_USER_APP_DIR"
/usr/bin/touch "$STR_USER_APP_DIR/.localized"

########################################
##サブフォルダを作る Applications
LIST_SUB_DIR_NAME=("Demos" "Desktop" "Developer" "Documents" "Downloads" "Favorites" "Groups" "Library" "Movies" "Music" "Pictures" "Public" "Shared" "Sites" "System" "Users" "Utilities")
STR_USER_APP_DIR="/Users/$CURRENT_USER/Applications"
for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
	/bin/mkdir -p "$STR_USER_APP_DIR/${ITEM_DIR_NAME}"
	/bin/chmod 755 "$STR_USER_APP_DIR/${ITEM_DIR_NAME}"
	/usr/bin/touch "$STR_USER_APP_DIR/${ITEM_DIR_NAME}/.localized"
done
########################################
##サブフォルダを作る Public
LIST_SUB_DIR_NAME=("Documents" "Groups" "Shared Items" "Shared" "Favorites" "Drop Box")
STR_USER_PUB_DIR="/Users/$CURRENT_USER/Public"
for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
	/bin/mkdir -p "$STR_USER_PUB_DIR/${ITEM_DIR_NAME}"
	/bin/chmod 755 "$STR_USER_PUB_DIR/${ITEM_DIR_NAME}"
	/usr/bin/touch "$STR_USER_PUB_DIR/${ITEM_DIR_NAME}/.localized"
done
/bin/chmod 755 "$STR_USER_PUB_DIR/Documents"
/bin/chmod 770 "$STR_USER_PUB_DIR/Groups"
/bin/chmod 775 "$STR_USER_PUB_DIR/Shared Items"
/bin/chmod 777 "$STR_USER_PUB_DIR/Shared"
/bin/chmod 750 "$STR_USER_PUB_DIR/Favorites"
/bin/chmod 733 "$STR_USER_PUB_DIR/Drop Box"

########################################
##シンボリックリンクを作る
if [[ ! -e "/Users/$CURRENT_USER/Applications/Applications" ]]; then
	/bin/ln -s "/Applications" "/Users/$CURRENT_USER/Applications/Applications"
fi
if [[ ! -e "/Users/$CURRENT_USER//Applications/Utilities/Finder Applications" ]]; then
	/bin/ln -s "/System/Library/CoreServices/Finder.app/Contents/Applications" "/Users/$CURRENT_USER/Applications/Utilities/Finder Applications"
fi
if [[ ! -e "/Users/$CURRENT_USER/Applications/Utilities/Finder Libraries" ]]; then
	/bin/ln -s "/System/Library/CoreServices/Finder.app/Contents/Resources/MyLibraries" "/Users/$CURRENT_USER/Applications/Utilities/Finder Libraries"
fi
if [[ ! -e "/Users/$CURRENT_USER/Applications/Utilities/System Applications" ]]; then
	/bin/ln -s "/System/Library/CoreServices/Applications" "/Users/$CURRENT_USER/Applications/Utilities/System Applications"
fi
if [[ ! -e "/Users/$CURRENT_USER/Applications/Utilities/System Utilities" ]]; then
	/bin/ln -s "/Applications/Utilities" "/Users/$CURRENT_USER/Applications/Utilities/System Utilities"
fi
if [[ ! -e "/Users/$CURRENT_USER/Library/Managed Items/My Applications" ]]; then
	/bin/ln -s "/Users/$CURRENT_USER/Applications" "/Users/$CURRENT_USER/Library/Managed Items/My Applications"
fi

########################################
###ダウンロード>>起動時に削除する項目
###CPUタイプでの分岐
ARCHITEC=$(/usr/bin/arch)
/bin/echo "Running on $ARCHITEC"
if [ "$ARCHITEC" == "arm64" ]; then
	###ARM用のダウンロードURL
	STR_URL="https://dl.google.com/dl/chrome/mac/universal/stable/gcea/googlechrome.dmg"
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
	STR_URL="https://dl.google.com/dl/chrome/mac/universal/stable/gcea/googlechrome.dmg"
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

##起動中のアプリを終了
/usr/bin/osascript -e "tell application id \"com.google.Chrome\" to quit"
/bin/sleep 2
##念の為　KILLもする
/usr/bin/killall "Google Chrome" 2>/dev/null
#	/usr/bin/killall "chrome_crashpad_handler" 2>/dev/null
/usr/bin/killall "Google Chrome Helper" 2>/dev/null
/usr/bin/killall "Google Chrome Helper (Renderer)" 2>/dev/null
/usr/bin/killall "Google Chrome Helper (GPU)" 2>/dev/null


#####古いファイルをゴミ箱に 
function DO_MOVE_TO_TRASH() {
	if [ -e "$1" ]; then
		TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/XXXXXXXX")
	/bin/chmod 777 "$TRASH_DIR"
	/bin/mv "$1" "$TRASH_DIR"
	fi
}

DO_MOVE_TO_TRASH "$HOME/Applications/Google Chrome.app"
DO_MOVE_TO_TRASH "$HOME/Applications/Sites/Google Chrome.app"
DO_MOVE_TO_TRASH "$HOME/Library/Caches/com.google.SoftwareUpdate.0"
DO_MOVE_TO_TRASH "$HOME/Library/Caches/com.google.SoftwareUpdate"
DO_MOVE_TO_TRASH "$HOME/Library/Caches/com.google.Keystone"
DO_MOVE_TO_TRASH "$HOME/Library/Caches/com.google.SoftwareUpdate"
DO_MOVE_TO_TRASH "$HOME/Library/Caches/Google/Chrome"

DO_MOVE_TO_TRASH "$HOME/Library/Google/GoogleSoftwareUpdate"

DO_MOVE_TO_TRASH "$HOME/Library/LaunchAgents/com.google.keystone.xpcservice.plist"
DO_MOVE_TO_TRASH "$HOME/Library/LaunchAgents/com.google.keystone.agent.plist"
DO_MOVE_TO_TRASH "$HOME/Library/LaunchDaemons/com.google.keystone.daemon.plist"

DO_MOVE_TO_TRASH "$HOME/Library/Application Support/Google/GoogleUpdater"
DO_MOVE_TO_TRASH "$HOME/Library/Application Support/Google/Chrome/GrShaderCache"
DO_MOVE_TO_TRASH "$HOME/Library/Application Support/Google/Chrome/Guest Profile"
DO_MOVE_TO_TRASH "$HOME/Library/Application Support/Google/Chrome/ShaderCache"

DO_MOVE_TO_TRASH "$HOME/Library/HTTPStorages/com.google.Keystone"
DO_MOVE_TO_TRASH "$HOME/Library/Receipts/com.google.Chrome.bom"
DO_MOVE_TO_TRASH "$HOME/Library/Receipts/com.google.Chrome.plist"




###############/var/folde TemporaryDirectory
MKTEMP_DIR=$(/usr/bin/mktemp -d)
TEMP_DIR_T="$(/usr/bin/dirname "$MKTEMP_DIR")"
#####古いファイルをゴミ箱に
GOTOTRASH_PATH="$TEMP_DIR_T/com.google.Chrome"
if [ -e "$GOTOTRASH_PATH" ]; then
	TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/XXXXXXXX")
	/bin/chmod 777 "$TRASH_DIR"
	/bin/mv "$GOTOTRASH_PATH" "$TRASH_DIR"
fi
#####古いファイルをゴミ箱に
GOTOTRASH_PATH="$TEMP_DIR_T/com.google.Chrome.helper"
if [ -e "$GOTOTRASH_PATH" ]; then
	TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/XXXXXXXX")
	/bin/chmod 777 "$TRASH_DIR"
	/bin/mv "$GOTOTRASH_PATH" "$TRASH_DIR"
fi

TEMP_DIR="$(/usr/bin/dirname "$TEMP_DIR_T")"
TEMP_DIR_C="${TEMP_DIR}/C"

#####古いファイルをゴミ箱に
GOTOTRASH_PATH="$TEMP_DIR_C/com.google.Chrome"
if [ -e "$GOTOTRASH_PATH" ]; then
	TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/XXXXXXXX")
	/bin/chmod 777 "$TRASH_DIR"
	/bin/mv "$GOTOTRASH_PATH" "$TRASH_DIR"
fi
GOTOTRASH_PATH="$TEMP_DIR_C/com.google.Chrome.helper"
if [ -e "$GOTOTRASH_PATH" ]; then
	TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/XXXXXXXX")
	/bin/chmod 777 "$TRASH_DIR"
	/bin/mv "$GOTOTRASH_PATH" "$TRASH_DIR"
fi
#############################################
######### DITTOコピーインストール
/bin/echo "インストール開始:DITTO:" "$CURRENT_USER"
###ディスクをマウント
/usr/bin/hdiutil attach "$USER_TEMP_DIR/$DL_FILE_NAME" -noverify -nobrowse -noautoopen
/bin/echo "Done Disk mount"
sleep 2
####コピーして
/bin/echo "start ditto"
/usr/bin/ditto "/Volumes/Google Chrome/Google Chrome.app" "/Users/$CURRENT_USER/Applications/Sites/Google Chrome.app"
sleep 2
/bin/echo "Done dittto"
###ディスクをアンマウント
/usr/bin/hdiutil detach "/Volumes/Google Chrome" -force


###Dockに追加
##	PLIST_DICT="<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$HOME/Applications/Sites/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
## /usr/bin/defaults write com.apple.dock persistent-apps -array-add "$PLIST_DICT"
###Dock　再起動
##	/usr/bin/killall Dock

/bin/echo "処理終了しました"

exit 0
