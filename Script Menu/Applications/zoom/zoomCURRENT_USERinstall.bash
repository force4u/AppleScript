#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#ユーザードメインにインストール

########################################
##事前チェック

CHK_APP_PATH="/Applications/zoom.us.app"
if [ -e "$CHK_APP_PATH" ]; then
	/bin/echo "【エラー】$CHK_APP_PATHが存在します以下のコマンドをターミナルで実行してください"
	/bin/echo "/usr/bin/sudo /bin/mv \"/Applications/zoom.us.app\" \"$HOME/.Trash\""
	exit 1
fi
CHK_APP_PATH="/Applications/ZoomOutlookPlugin"
TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/chmod 777 "$TRASH_DIR"
/bin/mv "$CHK_APP_PATH" "$TRASH_DIR"

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
##OS
PLIST_PATH="/System/Library/CoreServices/SystemVersion.plist"
STR_OS_VER=$(/usr/bin/defaults read "$PLIST_PATH" ProductVersion)
/bin/echo "OS VERSION ：" "$STR_OS_VER"
STR_MAJOR_VERSION="${STR_OS_VER%%.*}"
/bin/echo "STR_MAJOR_VERSION ：" "$STR_MAJOR_VERSION"
STR_MINOR_VERSION="${STR_OS_VER#*.}"
/bin/echo "STR_MINOR_VERSION ：" "$STR_MINOR_VERSION"
#	STR_MAJOR_VERSION=$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d '.' -f 1,1)
#	STR_MINOR_VERSION=$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d '.' -f 2,2)

########################################
##ユーザー
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"
CURRENT_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
/bin/echo "実行中ユーザー：" "$CURRENT_USER"

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
/bin/chmod 777 "$STR_USER_DIR/Library/Caches"

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

##全ローカルユーザーに対して実施したい処理があれば追加する
/bin/echo "ユーザーディレクトリチェックDONE"

#######################################
##	本処理　ダウンロードディレクトリ
DOWNLOADS_DIR_PATH=$(/usr/bin/mktemp -d)
/bin/chmod 777 "$DOWNLOADS_DIR_PATH"
/bin/echo "ダウンロードディレクトリ：" "$DOWNLOADS_DIR_PATH"
#######################################
##プロセス終了
/usr/bin/killall "zoom.us" 2>/dev/null
/usr/bin/killall "caphost" 2>/dev/null

#######################################
##古いファイルをゴミ箱に  USER
function DO_MOVE_TO_TRASH() {
	if [ -e "$1" ]; then
		TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$CURRENT_USER/.Trash/ZOOM.XXXXXXXX")
		/bin/chmod 777 "$TRASH_DIR"
		/bin/mv "$1" "$TRASH_DIR"
	fi
}
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Applications/zoom.us.app"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Applications/ZoomOutlookPlugin"

DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Applications/Groups/zoom.us.app"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Applications/Groups/ZoomOutlookPlugin"

DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Caches/us.zoom.xos"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/WebKit/us.zoom.xos"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Saved Application State/us.zoom.xos.savedState"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Receipts/ZoomMacOutlookPlugin.pkg.plist"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Receipts/ZoomMacOutlookPlugin.pkg.bom"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Logs/ZoomPhone"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/Logs/zoom.us"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/HTTPStorages/us.zoom.xos.binarycookies"
DO_MOVE_TO_TRASH "/Users/$CURRENT_USER/Library/HTTPStorages/us.zoom.xos"

#######################################
##	本処理　ダウンロード
ARCHITEC=$(/usr/bin/arch)
/bin/echo "Running on $ARCHITEC"
if [ "$ARCHITEC" == "arm64" ]; then

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

################################################
###設定項目
STR_BUNDLEID="us.zoom.xos"
STR_APP_PATH="$HOME/Applications/zoom.us.app"
###アプリケーション名を取得
STR_APP_NAME=$(/usr/bin/defaults read "$STR_APP_PATH/Contents/Info.plist" CFBundleDisplayName)
if [ -z "$STR_APP_NAME" ]; then
	STR_APP_NAME=$(/usr/bin/defaults read "$STR_APP_PATH/Contents/Info.plist" CFBundleName)
fi
/bin/echo "アプリケーション名：$STR_APP_NAME"
################################################
### DOCKに登録済みかゴミ箱に入れる前に調べておく
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
/bin/echo "処理終了 DOCKを再起動します"
/usr/bin/killall "Dock"

exit 0
