#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#ユーザードメインにインストール

########################################
##実行パス
SCRIPT_PATH="${BASH_SOURCE[0]}"
/bin/echo "実行中のスクリプト"
/bin/echo "\"$SCRIPT_PATH\""
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
#起動ディスクの名前を取得する
/usr/bin/touch "$USER_TEMP_DIR/diskutil.plist"
/usr/sbin/diskutil info -plist / >"$USER_TEMP_DIR/diskutil.plist"
STARTUPDISK_NAME=$(/usr/bin/defaults read "$USER_TEMP_DIR/diskutil.plist" VolumeName)
/bin/echo "ボリューム名：" "$STARTUPDISK_NAME"

STR_DEVICE_UUID=$(/usr/sbin/ioreg -c IOPlatformExpertDevice | grep IOPlatformUUID | awk -F'"' '{print $4}')
/bin/echo "デバイスUUID: " "$STR_DEVICE_UUID"

########################################
###ダウンロード起動時に削除する項目
USER_TEMP_DIR=$(/usr/bin/mktemp -d)
/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"


########################################
## RSSから最新のバージョンを取得する
STR_RSS_URL="https://code.visualstudio.com/feed.xml"
XML_RSS_DATA=$(/usr/bin/curl -s "$STR_RSS_URL" | /usr/bin/xmllint --format -)
STR_UPDATE_URL=$(echo "$XML_RSS_DATA" | /usr/bin/xmllint --xpath "///text()" -| /usr/bin/grep "updates/v" | /usr/bin/grep -v "href")
#STR_TITLE=$(echo "$XML_RSS_DATA" | /usr/bin/xmllint --xpath "//entry/id/text()" -)
IFS=$'\n' read -r -d '' -a LIST_URL <<<"$STR_UPDATE_URL"
for ITEM_URL in "${LIST_URL[@]}"; do
  /bin/echo "$ITEM_URL"
done
STR_NEWER_VER="${LIST_URL[0]}"
/bin/echo "$STR_NEWER_VER"


###CPUタイプでの分岐
ARCHITEC=$(/usr/bin/arch)
/bin/echo "Running on $ARCHITEC"
if [ "$ARCHITEC" == "arm64" ]; then
	###ARM用のダウンロードURL
	STR_URL="https://code.visualstudio.com/sha/download?build=stable&os=darwin-arm64"
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
	STR_URL="https://code.visualstudio.com/sha/download?build=stable&os=darwin"
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
##実行可能にしておく
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
	if ! /usr/bin/osascript -e "tell application id \"com.microsoft.VSCode\" to quit"; then
		##念の為　KILLもする
		/usr/bin/killall "Code" 2>/dev/null
		/usr/bin/killall "Code Helper" 2>/dev/null
		/usr/bin/killall "Code Helper (GPU)" 2>/dev/null
		/usr/bin/killall "Code Helper (Renderer)" 2>/dev/null
	fi
fi
/bin/sleep 2

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
##　HOME
########################################
##	Developer
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Developer"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
##	bin
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/bin"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
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
########################################
##	Public
########################################
/bin/chmod 755 "/Users/$CURRENT_USER/Public"
##
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Drop Box"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 733 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"
##########
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Documents"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
##
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Downloads"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
##
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Favorites"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
##########
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Groups"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 770 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf staff "$STR_CHECK_DIR_PATH"
##
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Shared"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 750 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf staff "$STR_CHECK_DIR_PATH"
##########
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Guest"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 777 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"
##
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Shared Items"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 775 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"

########################################
##	Applications
########################################
##	Applications
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Applications"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
##サブフォルダを作る
LIST_SUB_DIR_NAME=("Demos" "Desktop" "Developer" "Documents" "Downloads" "Favorites" "Groups" "Library" "Movies" "Music" "Pictures" "Public" "Shared" "Sites" "System" "Users" "Utilities")
##リストの数だけ処理
for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
	/bin/mkdir -p "$STR_CHECK_DIR_PATH/${ITEM_DIR_NAME}"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH/${ITEM_DIR_NAME}"
	/usr/bin/touch "$STR_CHECK_DIR_PATH/${ITEM_DIR_NAME}/.localized"
done
########################################
##シンボリックリンクを作る
if [[ ! -e "/Users/$CURRENT_USER/Applications/Applications" ]]; then
	/bin/ln -s "/Applications" "/Users/$CURRENT_USER/Applications/Applications"
fi
if [[ ! -e "/Users/$CURRENT_USER/Applications/Utilities/Finder Applications" ]]; then
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
##全ローカルユーザーに対して実施したい処理があれば追加する
/bin/echo "ユーザーディレクトリチェックDONE"

############################################################
#####古いファイルをゴミ箱に  USER
function DO_MOVE_TO_TRASH() {
	if [ -e "$1" ]; then
		TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$CURRENT_USER/.Trash/CODE.XXXXXXXX")
		/bin/chmod 777 "$TRASH_DIR"
		/bin/mv "$1" "$TRASH_DIR"
	fi
}

#####古いファイルをゴミ箱に
DO_MOVE_TO_TRASH "/Applications/Visual Studio Code.app"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Applications/Visual Studio Code.app"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Applications/Documents/Visual Studio Code.app"

DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/Cache"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/CachedConfigurations"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/CachedData"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/CachedExtensions"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/CachedExtensionVSIXs"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/CachedProfilesData"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/Code Cache"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/Crashpad"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/DawnCache"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/GPUCache"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/logs"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/Service Worker/CacheStorage"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/Code/Service Worker/ScriptCache"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Application Support/vscode-beggar"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Caches/com.microsoft.VSCode"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Caches/com.microsoft.VSCode.ShipIt"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/HTTPStorages/com.microsoft.VSCode"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Saved Application State/com.microsoft.VSCode.savedState"

/bin/echo "ユーザーキャッシュ削除DONE"
############################################################
###/var/folde T
MKTEMP_DIR=$(/usr/bin/mktemp -d)
TEMP_DIR_T="$(/usr/bin/dirname "$MKTEMP_DIR")"
function DO_MOVE_TO_TRASH_T() {
	if [ -e "$1" ]; then
		TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$CURRENT_USER/.Trash/CODE.T.XXXXXXXX")
		/bin/chmod 777 "$TRASH_DIR"
		/bin/mv "$1" "$TRASH_DIR"
	fi
}
#####古いファイルをゴミ箱に
DO_MOVE_TO_TRASH_T "$TEMP_DIR_T/Visual Studio Code"
DO_MOVE_TO_TRASH_T "$TEMP_DIR_T/Visual Studio Code Helper"
DO_MOVE_TO_TRASH_T "$TEMP_DIR_T/Visual Studio Code Helper (GPU)"
DO_MOVE_TO_TRASH_T "$TEMP_DIR_T/Visual Studio Code Helper (Renderer)"
DO_MOVE_TO_TRASH_T "$TEMP_DIR_T/Visual Studio Code Helper-(GPU)"
DO_MOVE_TO_TRASH_T "$TEMP_DIR_T/Visual Studio Code Helper-(Renderer)"

# ディレクトリを再帰的に検索し、パターンに一致するものを処理する
TMP_T_TYPESCRIPT_DIR=$(/bin/ls "$TEMP_DIR_T" | /usr/bin/grep "vscode-typescript")
IFS=$'\n'
read -d '\n' -r -a LIST_TYPESCRIPT_DIR <<<"$TMP_T_TYPESCRIPT_DIR"
IFS=''
for ITEM_LIST_TYPESCRIPT_DIR in "${LIST_TYPESCRIPT_DIR[@]}"; do
	/bin/echo "$ITEM_LIST_TYPESCRIPT_DIR"
	/bin/mv "$TEMP_DIR_T/$ITEM_LIST_TYPESCRIPT_DIR" "$TRASH_DIR"
done

# ディレクトリを再帰的に検索し、パターンに一致するものを処理する
TMP_T_TYPESCRIPT_DIR=$(/bin/ls "$TEMP_DIR_T" | /usr/bin/grep "vscode-git")
IFS=$'\n'
read -d '\n' -r -a LIST_TYPESCRIPT_DIR <<<"$TMP_T_TYPESCRIPT_DIR"
IFS=''
for ITEM_LIST_TYPESCRIPT_DIR in "${LIST_TYPESCRIPT_DIR[@]}"; do
	/bin/echo "$ITEM_LIST_TYPESCRIPT_DIR"
	/bin/mv "$TEMP_DIR_T/$ITEM_LIST_TYPESCRIPT_DIR" "$TRASH_DIR"
done

/bin/echo "ユーザーキャッシュT DONE"

############################################################
###/var/folder C
TEMP_DIR="$(/usr/bin/dirname "$TEMP_DIR_T")"
TEMP_DIR_C="${TEMP_DIR}/C"
function DO_MOVE_TO_TRASH_C() {
	if [ -e "$1" ]; then
		TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$CURRENT_USER/.Trash/CODE.C.XXXXXXXX")
		/bin/chmod 777 "$TRASH_DIR"
		/bin/mv "$1" "$TRASH_DIR"
	fi
}
#####古いファイルをゴミ箱に
DO_MOVE_TO_TRASH_C "$TEMP_DIR_C/com.microsoft.VSCode"
DO_MOVE_TO_TRASH_C "$TEMP_DIR_C/com.microsoft.VSCode.Helper"
DO_MOVE_TO_TRASH_C "$TEMP_DIR_C/com.microsoft.VSCode.Helper-(GPU)"
DO_MOVE_TO_TRASH_C "$TEMP_DIR_C/com.microsoft.VSCode.Helper-(Renderer)"
/bin/echo "ユーザーキャッシュ C DONE"

/usr/bin/unzip -q "$USER_TEMP_DIR/$DL_FILE_NAME" -d "/Users/$CURRENT_USER/Applications/Documents"

################################################
###設定項目
STR_BUNDLEID="com.microsoft.VSCode"
STR_APP_PATH="$HOME/Applications/Documents/Visual Studio Code.app"

###アプリケーション名を取得
STR_APP_NAME=$(/usr/bin/defaults read "$STR_APP_PATH/Contents/Info.plist" CFBundleDisplayName)
if [ -z "$STR_APP_NAME" ]; then
	STR_APP_NAME=$(/usr/bin/defaults read "$STR_APP_PATH/Contents/Info.plist" CFBundleName)
fi
/bin/echo "アプリケーション名：$STR_APP_NAME"

##Dockの登録数を調べる
JSON_PERSISENT_APPS=$(/usr/bin/defaults read com.apple.dock persistent-apps)
NUN_CNT_ITEM=$(/bin/echo "$JSON_PERSISENT_APPS" | grep -o "tile-data" | wc -l)
/bin/echo "Dock登録数：$NUN_CNT_ITEM"
##Dockの登録数だけ繰り返し
NUM_CNT=0           #カウンタ初期化
NUM_POSITION="NULL" #ポジション番号にNULL文字を入れる
###対象のバンドルIDがDockに登録されているか順番に調べる
while [ $NUM_CNT -lt "$NUN_CNT_ITEM" ]; do
	##順番にバンドルIDを取得して
	STR_CHK_BUNDLEID=$(/usr/libexec/PlistBuddy -c "Print:persistent-apps:$NUM_CNT:tile-data:bundle-identifier" "$HOME/Library/Preferences/com.apple.dock.plist")
	##対象のバンドルIDだったら
	if [ "$STR_CHK_BUNDLEID" = "$STR_BUNDLEID" ]; then
		/bin/echo "DockのポジションNO: $NUM_CNT バンドルID：$STR_CHK_BUNDLEID"
		##位置情報ポジションを記憶しておく
		NUM_POSITION=$NUM_CNT
	fi
	NUM_CNT=$((NUM_CNT + 1))
done
##結果　対象のバンドルIDが無ければ
if [ "$NUM_POSITION" = "NULL" ]; then
	/bin/echo "Dockに未登録です"
	PLIST_DICT="<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$STR_APP_PATH</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
	/usr/bin/defaults write com.apple.dock persistent-apps -array-add "$PLIST_DICT"
else
	##すでに登録済みの場合は一旦削除
	/bin/echo "Dockの$NUM_POSITION に登録済み　削除してから同じ場所に登録しなおします"
	##削除して
	/usr/libexec/PlistBuddy -c "Delete:persistent-apps:$NUM_POSITION" "$HOME/Library/Preferences/com.apple.dock.plist"
	##保存
	/usr/libexec/PlistBuddy -c "Save" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/libexec/PlistBuddy -c "Revert" "$HOME/Library/Preferences/com.apple.dock.plist"
	###同じ内容を作成する
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION dict" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:GUID integer $RANDOM$RANDOM" "$HOME/Library/Preferences/com.apple.dock.plist"
	## 想定値 file-tile directory-tile
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-type string file-tile" "$HOME/Library/Preferences/com.apple.dock.plist"
	###↑この親Dictに子要素としてtile-dataをDictで追加
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data dict" "$HOME/Library/Preferences/com.apple.dock.plist"
	###↑子要素のtile-dataにキーと値を入れていく
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:showas integer 0" "$HOME/Library/Preferences/com.apple.dock.plist"
	## 想定値 2：フォルダ　41：アプリケーション 169 Launchpad とMission Control
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:file-type integer 41" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:displayas integer 0" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:parent-mod-date integer $(date '+%s')" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:file-mod-date integer $(date '+%s')" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:file-label string $STR_APP_NAME" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:is-beta bool false" "$HOME/Library/Preferences/com.apple.dock.plist"
	###↑この子要素のtile-dataに孫要素でfile-dataをDictで追加
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:file-data dict" "$HOME/Library/Preferences/com.apple.dock.plist"
	###値を入れていく
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:file-data:_CFURLStringType integer 15" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:file-data:_CFURLString string file://$STR_APP_PATH" "$HOME/Library/Preferences/com.apple.dock.plist"
	##保存
	/usr/libexec/PlistBuddy -c "Save" "$HOME/Library/Preferences/com.apple.dock.plist"
fi
###
###反映させて
/usr/bin/killall cfprefsd
/bin/echo "処理終了 DOCKを再起動します"
/usr/bin/killall "Dock"

/bin/echo "処理終了しました"

exit 0
