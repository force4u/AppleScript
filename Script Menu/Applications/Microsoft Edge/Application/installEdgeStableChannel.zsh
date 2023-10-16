#!/bin/zsh
##	!/usr/bin/env zsh
#com.cocolog-nifty.quicktimer.icefloe
########################################
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
export LANG=en_US.UTF-8
/bin/echo $LANG

###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"
if [ "$USER_WHOAMI" != "root" ]; then
	/bin/echo "このスクリプトを実行するには管理者権限が必要です。" 1>&2
	/bin/echo "sudo で実行してください" 1>&2
	### path to me (VS CODEコンソールだとマルチバイト文字は文字化けする)
	SCRIPT_PATH="$0"
	STR_FILENAME=$(/usr/bin/basename "$SCRIPT_PATH")
	STR_CONTAINER_DIR_PATH=$(/usr/bin/dirname "$SCRIPT_PATH")
	/bin/echo "/usr/bin/sudo \"$STR_CONTAINER_DIR_PATH/$STR_FILENAME\"" 1>&2
	/bin/echo "↑を実行してください" 1>&2
	exit 1
fi
###コンソールユーザー CONSOLE_USERはFinderでログインしていないと出ない
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
###実行しているユーザー名
CURRENT_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
/bin/echo "実行ユーザー：" "$CURRENT_USER"

if [ -z "$CONSOLE_USER" ]; then
	/bin/echo "コンソールユーザーが無い=電源入れてログインウィンドウ状態"
else
	/bin/echo "コンソールユーザー：" "$CONSOLE_USER"
fi
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
STR_DEVICE_UUID=$(/usr/sbin/ioreg -c IOPlatformExpertDevice | grep IOPlatformUUID | awk -F'"' '{print $4}')
/bin/echo "デバイスUUID: " "$STR_DEVICE_UUID"

########################################
###ローカルのユーザーアカウントを取得
TEXT_RESULT=$(/usr/bin/dscl localhost -list /Local/Default/Users PrimaryGroupID | /usr/bin/awk '$2 == 20 { print $1 }')
###リストにする
TFS="\n"
read -d '\\n' -r -A LIST_USER <<<"$TEXT_RESULT"
LIST_USER=("${LIST_USER[@]:0:${#LIST_USER[@]}-1}")
/bin/echo "ユーザーリスト：" "$LIST_USER"
###リスト内の項目数
NUM_CNT=${#LIST_USER[@]}
/bin/echo "ユーザー数：" "$NUM_CNT"

###各ユーザーの最終ログアウト日
for ITEM_LIST in "${LIST_USER[@]}"; do
	if [[ -n $ITEM_LIST ]]; then
		/bin/echo "ユーザー${ITEM_LIST}"
		STR_CHECK_File_PATH="/Users/${ITEM_LIST}/Library/Preferences/ByHost/com.apple.loginwindow.$STR_DEVICE_UUID.plist"
		STR_LAST_LOGOUT=$(/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$STR_CHECK_File_PATH")
		/bin/echo "ユーザー$ITEM_LIST の最終ログアウト日: " "$STR_LAST_LOGOUT"
	fi
done

########################################
##デバイス
#起動ディスクの名前を取得する
for ITEM_LIST in "${LIST_USER[@]}"; do
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Documents/Apple/IOPlatformUUID/"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "/Users/${ITEM_LIST}/Documents/Apple/IOPlatformUUID/com.apple.diskutil.plist"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/diskutil info -plist / >"/Users/${ITEM_LIST}/Documents/Apple/IOPlatformUUID/com.apple.diskutil.plist"
	STARTUPDISK_NAME=$(/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/defaults read "/Users/${ITEM_LIST}/Documents/Apple/IOPlatformUUID/com.apple.diskutil.plist" VolumeName)
done
/bin/echo "ボリューム名：" "$STARTUPDISK_NAME"
########################################
###ダウンロード起動時に削除する項目
for ITEM_LIST in "${LIST_USER[@]}"; do
	USER_TEMP_DIR=$(/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/mktemp -d)
	/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"
done
########################################
##基本メンテナンス
########################################
for ITEM_LIST in "${LIST_USER[@]}"; do
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 700 "/Users/${ITEM_LIST}/Library"
	##ライブラリの不可視属性を解除
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/chflags nohidden "/Users/${ITEM_LIST}/Library"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/SetFile -a v "/Users/${ITEM_LIST}/Library"
	##　Managed Itemsフォルダを作る
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Library/Managed Items"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 755 "/Users/${ITEM_LIST}/Library/Managed Items"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/chown "${ITEM_LIST}" "/Users/${ITEM_LIST}/Library/Managed Items"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "/Users/${ITEM_LIST}/Library/Managed Items/.localized"
	##
	/bin/chmod 777 "/Users/${ITEM_LIST}/Library/Caches"
	/bin/chmod 777 /Users/"${ITEM_LIST}"/Library/Caches/*
	##
	/bin/chmod -Rf 755 "/Users/${ITEM_LIST}/Library/Fonts"
	/usr/sbin/chown -Rf "${ITEM_LIST}" "/Users/${ITEM_LIST}/Library/Fonts"
	##
	/bin/echo "ライブラリチェックDONE：" "${ITEM_LIST}"
done
########################################
##　HOME
########################################
for ITEM_LIST in "${LIST_USER[@]}"; do
	##	Developer
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Developer"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo /usr/sbin/chown "${ITEM_LIST}" "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	##	bin
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/bin"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo /usr/sbin/chown "${ITEM_LIST}" "$STR_CHECK_DIR_PATH"
	##アクセス権チェック
	/bin/chmod 700 "/Users/${ITEM_LIST}/Movies"
	/bin/chmod 700 /"Users/${ITEM_LIST}/Music"
	/bin/chmod 700 "/Users/${ITEM_LIST}/Pictures"
	/bin/chmod 700 "/Users/${ITEM_LIST}/Downloads"
	/bin/chmod 700 "/Users/${ITEM_LIST}/Documents"
	/bin/chmod 700 "/Users/${ITEM_LIST}/Desktop"
	##全ローカルユーザーに対して実施したい処理があれば追加する
	/bin/echo "ユーザーディレクトリチェックDONE" "${ITEM_LIST}"
done
########################################
##	Public
########################################
for ITEM_LIST in "${LIST_USER[@]}"; do
	/bin/chmod 755 "/Users/${ITEM_LIST}/Public"
	##
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Drop Box"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 733 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"
	##########
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Documents"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
	##
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Downloads"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
	##
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Favorites"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
	##########
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Groups"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 770 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf staff "$STR_CHECK_DIR_PATH"
	##
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Shared"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 750 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf staff "$STR_CHECK_DIR_PATH"
	##########
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Guest"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 777 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"
	##
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Shared Items"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 775 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"
	/bin/echo "パブリックチェックDONE" "${ITEM_LIST}"
done
########################################
##	Applications
########################################
##	Applications
for ITEM_LIST in "${LIST_USER[@]}"; do
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Applications"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	##サブフォルダを作る
	LIST_SUB_DIR_NAME=("Demos" "Desktop" "Developer" "Documents" "Downloads" "Favorites" "Groups" "Library" "Movies" "Music" "Pictures" "Public" "Shared" "Sites" "System" "Users" "Utilities")
	##リストの数だけ処理
	for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
		/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH/$ITEM_DIR_NAME"
		/bin/chmod 700 "$STR_CHECK_DIR_PATH/${ITEM_DIR_NAME}"
		/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/$ITEM_DIR_NAME/.localized"
	done
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

#################################
#インストール基本
#################################
###ここだけ変えればなんでいけるか？
STR_URL="https://go.microsoft.com/fwlink/?linkid=2093504"
###
STR_APP_NAME="Microsoft Edge"

LOCAL_TMP_DIR=$(/usr/bin/sudo -u "$CONSOLE_USER" /usr/bin/mktemp -d)
/bin/echo "TMPDIR：" "$LOCAL_TMP_DIR"

###ファイル名を取得
PKG_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
/bin/echo "PKG_FILE_NAME" "$PKG_FILE_NAME"

###ファイル名指定してダウンロード
/usr/bin/sudo -u "$CONSOLE_USER" /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$PKG_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20

###コンソールユーザーにのみ処理する
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
/bin/echo "CONSOLE_USER:$CONSOLE_USER"
if [ -z "$CONSOLE_USER" ]; then
	/bin/echo "コンソールユーザーが無い=電源入れてログインウィンドウ状態"
else
	#####OSAスクリプトはエラーすることも多い(初回インストール時はエラーになる)
	if ! /usr/bin/osascript -e "tell application id \"com.microsoft.edgemac\" to quit"; then
		##念の為　KILLもする
		/usr/bin/killall "$STR_APP_NAME" 2>/dev/null
		/usr/bin/killall "$STR_APP_NAME Helper" 2>/dev/null
		/usr/bin/killall "$STR_APP_NAME Helper (GPU)" 2>/dev/null
		/usr/bin/killall "$STR_APP_NAME Helper (Renderer)" 2>/dev/null
	fi
fi
/bin/sleep 2

### インストール（上書き）を実行する
/usr/sbin/installer -pkg "$LOCAL_TMP_DIR/$PKG_FILE_NAME" -target / -dumplog -allowUntrusted -lang ja

################################################
###設定項目
STR_BUNDLEID="com.microsoft.edgemac"
STR_APP_PATH="/Applications/Microsoft Edge.app"
###アプリケーション名を取得
STR_APP_NAME=$(/usr/bin/defaults read "$STR_APP_PATH/Contents/Info.plist" CFBundleDisplayName)
if [ -z "$STR_APP_NAME" ]; then
	STR_APP_NAME=$(/usr/bin/defaults read "$STR_APP_PATH/Contents/Info.plist" CFBundleName)
fi
/bin/echo "アプリケーション名：$STR_APP_NAME"
################################################
### DOCKに登録済みかゴミ箱に入れる前に調べておく
##Dockの登録数を調べる
JSON_PERSISENT_APPS=$(/usr/bin/sudo -u "$CONSOLE_USER" /usr/bin/defaults read com.apple.dock persistent-apps)
NUN_CNT_ITEM=$(/bin/echo "$JSON_PERSISENT_APPS" | grep -o "tile-data" | wc -l)
/bin/echo "Dock登録数：$NUN_CNT_ITEM"

##Dockの登録数だけ繰り返し
NUM_CNT=0           #カウンタ初期化
NUM_POSITION="NULL" #ポジション番号にNULL文字を入れる
###対象のバンドルIDがDockに登録されているか順番に調べる
while [ $NUM_CNT -lt "$NUN_CNT_ITEM" ]; do
	##順番にバンドルIDを取得して
	STR_CHK_BUNDLEID=$(/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "Print:persistent-apps:"$NUM_CNT":tile-data:bundle-identifier" "$HOME/Library/Preferences/com.apple.dock.plist")
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
	PLIST_DICT="<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>"$STR_APP_PATH"</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/bin/defaults write com.apple.dock persistent-apps -array-add "$PLIST_DICT"
else
	##すでに登録済みの場合は一旦削除
	/bin/echo "Dockの$NUM_POSITION に登録済み　削除してから同じ場所に登録しなおします"
	##削除して
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "Delete:persistent-apps:"$NUM_POSITION"" "$HOME/Library/Preferences/com.apple.dock.plist"
	##保存
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "Save" "$HOME/Library/Preferences/com.apple.dock.plist"
	###同じ内容を作成する
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION" dict" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":GUID integer "$RANDOM$RANDOM"" "$HOME/Library/Preferences/com.apple.dock.plist"
	## 想定値 file-tile directory-tile
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":tile-type string file-tile" "$HOME/Library/Preferences/com.apple.dock.plist"
	###↑この親Dictに子要素としてtile-dataをDictで追加
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":tile-data dict" "$HOME/Library/Preferences/com.apple.dock.plist"
	###↑子要素のtile-dataにキーと値を入れていく
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":tile-data:showas integer 0" "$HOME/Library/Preferences/com.apple.dock.plist"
	## 想定値 2：フォルダ　41：アプリケーション 169 Launchpad とMission Control
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":tile-data:file-type integer 41" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":tile-data:displayas integer 0" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":tile-data:parent-mod-date integer $(date '+%s')" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":tile-data:file-mod-date integer $(date '+%s')" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":tile-data:file-label string $STR_APP_NAME" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":tile-data:is-beta bool false" "$HOME/Library/Preferences/com.apple.dock.plist"
	###↑この子要素のtile-dataに孫要素でfile-dataをDictで追加
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":tile-data:file-data dict" "$HOME/Library/Preferences/com.apple.dock.plist"
	###値を入れていく
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":tile-data:file-data:_CFURLStringType integer 15" "$HOME/Library/Preferences/com.apple.dock.plist"
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:"$NUM_POSITION":tile-data:file-data:_CFURLString string file://"$STR_APP_PATH"" "$HOME/Library/Preferences/com.apple.dock.plist"
	##保存
	/usr/bin/sudo -u "$CONSOLE_USER" /usr/libexec/PlistBuddy -c "Save" "$HOME/Library/Preferences/com.apple.dock.plist"
fi
###
/bin/echo "処理終了 DOCKを再起動します"
/usr/bin/sudo -u "$CONSOLE_USER" /usr/bin/killall "Dock"

################################################
###
for ITEM_LIST in "com.microsoft.EdgeUpdater.update-internal" "com.microsoft.EdgeUpdater.update.system" "com.microsoft.EdgeUpdater.wake" "com.microsoft.EdgeUpdater"
do
/bin/launchctl stop -wF "$ITEM_LIST"
done
function STOP_LAUNCH_CTL() {
	if [ -e "$1" ]; then
	/bin/launchctll unload -wF $1
	fi
}
STOP_LAUNCH_CTL /Library/LaunchDaemons/com.microsoft.EdgeUpdater.update-internal*
STOP_LAUNCH_CTL /Library/LaunchDaemons/com.microsoft.EdgeUpdater.update.system*
STOP_LAUNCH_CTL /Library/LaunchDaemons/com.microsoft.EdgeUpdater.wake*
STOP_LAUNCH_CTL /Library/LaunchDaemons/com.microsoft.EdgeUpdater*

STOP_LAUNCH_CTL /Library/LaunchAgents/com.microsoft.EdgeUpdater.update-internal*
STOP_LAUNCH_CTL /Library/LaunchAgents/com.microsoft.EdgeUpdater.update.system*
STOP_LAUNCH_CTL /Library/LaunchAgents/com.microsoft.EdgeUpdater.wake*
STOP_LAUNCH_CTL /Library/LaunchAgents/com.microsoft.EdgeUpdater*

################################################
### クリーニング  ローカルドメイン
#####不要なファイルをゴミ箱に
function DO_MOVE_TO_TRASH_SUDO() {
	if [ -e "$1" ]; then
		/bin/mkdir -p "/private/tmp/Cleanup At Startup/Trash"
		TRASH_DIR=$(/usr/bin/mktemp -d "/private/tmp/Cleanup At Startup/Trash/Edge.XXXXXXXX")

		/usr/bin/sudo /bin/chmod 777 "$TRASH_DIR"
		/usr/bin/sudo /bin/mv "$1" "$TRASH_DIR"
	fi
}
DO_MOVE_TO_TRASH_SUDO "/Library/Application Support/Microsoft/EdgeUpdater"
DO_MOVE_TO_TRASH_SUDO "/Library/Microsoft/EdgeUpdater"

DO_MOVE_TO_TRASH_SUDO /Library/LaunchDaemons/com.microsoft.EdgeUpdater.update-internal*
DO_MOVE_TO_TRASH_SUDO /Library/LaunchDaemons/com.microsoft.EdgeUpdater.update.system*
DO_MOVE_TO_TRASH_SUDO /Library/LaunchDaemons/com.microsoft.EdgeUpdater.wake*
DO_MOVE_TO_TRASH_SUDO /Library/LaunchDaemons/com.microsoft.EdgeUpdater*

DO_MOVE_TO_TRASH_SUDO /Library/LaunchAgents/com.microsoft.EdgeUpdater.update-internal*
DO_MOVE_TO_TRASH_SUDO /Library/LaunchAgents/com.microsoft.EdgeUpdater.update.system*
DO_MOVE_TO_TRASH_SUDO /Library/LaunchAgents/com.microsoft.EdgeUpdater.wake*
DO_MOVE_TO_TRASH_SUDO /Library/LaunchAgents/com.microsoft.EdgeUpdater*

################################################
### クリーニング　ユーザードメイン
### 対象ファイルを起動時に削除する項目へ入れる
function DO_MOVE_TO_TRASH_USER() {
	local STR_DO_FILE_PATH="$1"
	local STR_DO_USERID="$2"

	if [ -e "$STR_DO_FILE_PATH" ]; then
		USER_TRASH_DIR=$(/usr/bin/sudo -u "$STR_DO_USERID" /usr/bin/mktemp -d "/private/tmp/Cleanup At Startup/.Trash/$STR_DO_USERID/Edge.XXXXXXXX")
		/bin/chmod 777 "$USER_TRASH_DIR"
		/bin/mv "$STR_DO_FILE_PATH" "$USER_TRASH_DIR"
	fi
}

for ITEM_LIST in "${LIST_USER[@]}"; do
	/bin/mkdir -p "/private/tmp/Cleanup At Startup/.Trash/${ITEM_LIST}"
	/bin/chmod 777 "/private/tmp/Cleanup At Startup/.Trash/${ITEM_LIST}"
	DO_MOVE_TO_TRASH_USER "/Users/${ITEM_LIST}/Library/Microsoft/EdgeUpdater" "${ITEM_LIST}"
	DO_MOVE_TO_TRASH_USER "/Users/${ITEM_LIST}/Library/Caches/Microsoft Edge" "${ITEM_LIST}"
	DO_MOVE_TO_TRASH_USER "/Users/${ITEM_LIST}/Library/Caches/com.microsoft.edgemac" "${ITEM_LIST}"
	DO_MOVE_TO_TRASH_USER "/Users/${ITEM_LIST}/Library/Caches/com.microsoft.EdgeUpdater" "${ITEM_LIST}"
	DO_MOVE_TO_TRASH_USER "/Users/${ITEM_LIST}Library/Application Support/Microsoft/EdgeUpdater" "${ITEM_LIST}"
	DO_MOVE_TO_TRASH_USER "/Users/${ITEM_LIST}/Library/Application Support/Microsoft Edge/ShaderCache" "${ITEM_LIST}"
	DO_MOVE_TO_TRASH_USER "/Users/${ITEM_LIST}Library/Application Support/Microsoft Edge/Guest Profile" "${ITEM_LIST}"
	DO_MOVE_TO_TRASH_USER "/Users/${ITEM_LIST}/Library/Application Support/Microsoft Edge/GrShaderCache" "${ITEM_LIST}"
	DO_MOVE_TO_TRASH_USER "/Users/${ITEM_LIST}/Library/Application Support/Microsoft Edge/GraphiteDawnCache" "${ITEM_LIST}"
	DO_MOVE_TO_TRASH_USER "/Users/${ITEM_LIST}/Library/Application Support/Microsoft Edge/extensions_crx_cache" "${ITEM_LIST}"
	DO_MOVE_TO_TRASH_USER "/Users/${ITEM_LIST}/Library/Application Support/Microsoft Edge/Crashpad" "${ITEM_LIST}"
	DO_MOVE_TO_TRASH_USER "/Users/${ITEM_LIST}/Library/Application Support/Microsoft Edge/component_crx_cache" "${ITEM_LIST}"

done



/bin/launchctl stop -wF com.microsoft.update.agent
/bin/launchctll unload -wF "/Library/LaunchAgents/com.microsoft.update.agent.plist"

exit 0
