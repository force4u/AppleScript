#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#ユーザードメインにインストール

########################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行ユーザーは：$USER_WHOAMI"
if [ "$USER_WHOAMI" != "root" ]; then
	/bin/echo "このスクリプトを実行するには管理者権限が必要です。"
	/bin/echo "sudo で実行してください"
	### path to me
	SCRIPT_PATH="${BASH_SOURCE[0]}"
	/bin/echo "/usr/bin/sudo \"$SCRIPT_PATH\""
	/bin/echo "↑を実行してください"
	exit 1
else
	###実行しているユーザー名
	SUDO_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
	/bin/echo "実行したユーザー：" "$SUDO_USER"
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
###ダウンロード起動時に削除する項目
USER_TEMP_DIR=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/mktemp -d)
/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"

########################################
##デバイス
#起動ディスクの名前を取得する
/usr/bin/sudo -u "$SUDO_USER" /usr/bin/touch "$USER_TEMP_DIR/diskutil.plist"
/usr/bin/sudo -u "$SUDO_USER" /usr/sbin/diskutil info -plist / > "$USER_TEMP_DIR/diskutil.plist"
STARTUPDISK_NAME=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/defaults read "$USER_TEMP_DIR/diskutil.plist" VolumeName)
/bin/echo "ボリューム名：" "$STARTUPDISK_NAME"



########################################
###ダウンロード>>起動時に削除する項目
###CPUタイプでの分岐
ARCHITEC=$(/usr/bin/arch)
/bin/echo "Running on $ARCHITEC"
if [ "$ARCHITEC" == "arm64" ]; then
	###ARM用のダウンロードURL
STR_URL="https://www.adobe.com/go/dng_converter_mac"
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
STR_URL="https://www.adobe.com/go/dng_converter_mac"
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

############################################################
##基本メンテナンス
##ライブラリの不可視属性を解除
/usr/bin/chflags nohidden "/Users/$SUDO_USER/Library"
/usr/bin/SetFile -a v "/Users/$SUDO_USER/Library"

##　Managed Itemsフォルダを作る
/usr/bin/sudo -u "$SUDO_USER" /bin/mkdir -p "/Users/$SUDO_USER/Library/Managed Items"
/bin/chmod 755 "/Users/$SUDO_USER/Library/Managed Items"
/usr/sbin/chown "$SUDO_USER" "/Users/$SUDO_USER/Library/Managed Items"
/usr/bin/sudo -u "$SUDO_USER" /usr/bin/touch "/Users/$SUDO_USER/Library/Managed Items/.localized"

########################################
###アクアセス権　修正
STR_USER_DIR="/Users/$SUDO_USER"

LIST_SUB_DIR_NAME=("Desktop" "Developer" "Documents" "Downloads" "Groups" "Library" "Movies" "Music" "Pictures" "jpki" "bin" "Creative Cloud Files")

for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
/bin/chmod 700 "$STR_USER_DIR/${ITEM_DIR_NAME}"
/usr/sbin/chown "$SUDO_USER" "$STR_USER_DIR/${ITEM_DIR_NAME}"
done
/bin/chmod 755 "$STR_USER_DIR/Public"
/bin/chmod 755 "$STR_USER_DIR/Sites"
/bin/chmod 755 "$STR_USER_DIR/Library/Caches"

########################################
##ユーザーアプリケーションフォルダを作る
STR_USER_APP_DIR="/Users/$SUDO_USER/Applications"
/usr/bin/sudo -u "$SUDO_USER" /bin/mkdir -p "$STR_USER_APP_DIR"
/bin/chmod 700 "$STR_USER_APP_DIR"
/usr/bin/sudo -u "$SUDO_USER" /usr/bin/touch "$STR_USER_APP_DIR/.localized"
/usr/sbin/chown "$SUDO_USER" "$STR_USER_APP_DIR"

########################################
##サブフォルダを作る Applications
LIST_SUB_DIR_NAME=("Demos" "Desktop" "Developer" "Documents" "Downloads" "Favorites" "Groups" "Library" "Movies" "Music" "Pictures" "Public" "Shared" "Sites" "System" "Users" "Utilities")
STR_USER_APP_DIR="/Users/$SUDO_USER/Applications"
for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
/usr/bin/sudo -u "$SUDO_USER" /bin/mkdir -p "$STR_USER_APP_DIR/${ITEM_DIR_NAME}"
	/bin/chmod 755 "$STR_USER_APP_DIR/${ITEM_DIR_NAME}"
	/usr/sbin/chown "$SUDO_USER" "$STR_USER_APP_DIR/${ITEM_DIR_NAME}"
/usr/bin/sudo -u "$SUDO_USER" /usr/bin/touch "$STR_USER_APP_DIR/${ITEM_DIR_NAME}/.localized"

done
########################################
##サブフォルダを作る Public
LIST_SUB_DIR_NAME=("Documents" "Groups" "Shared Items" "Shared" "Favorites" "Drop Box")
STR_USER_PUB_DIR="/Users/$SUDO_USER/Public"
for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
/usr/bin/sudo -u "$SUDO_USER" /bin/mkdir -p "$STR_USER_PUB_DIR/${ITEM_DIR_NAME}"
	/usr/sbin/chown "$SUDO_USER" "$STR_USER_PUB_DIR/${ITEM_DIR_NAME}"
	/bin/chmod 755 "$STR_USER_PUB_DIR/${ITEM_DIR_NAME}"
/usr/bin/sudo -u "$SUDO_USER" /usr/bin/touch "$STR_USER_PUB_DIR/${ITEM_DIR_NAME}/.localized"
done
/bin/chmod 755 "$STR_USER_PUB_DIR/Documents"
/bin/chmod 770 "$STR_USER_PUB_DIR/Groups"
/bin/chmod 775 "$STR_USER_PUB_DIR/Shared Items"
/bin/chmod 777 "$STR_USER_PUB_DIR/Shared"
/bin/chmod 750 "$STR_USER_PUB_DIR/Favorites"
/bin/chmod 733 "$STR_USER_PUB_DIR/Drop Box"

########################################
##シンボリックリンクを作る
if [[ ! -e "/Users/$SUDO_USER/Applications/Applications" ]]; then
/usr/bin/sudo -u "$SUDO_USER" /bin/ln -s "/Applications" "/Users/$SUDO_USER/Applications/Applications"
fi
if [[ ! -e "/Users/$SUDO_USER//Applications/Utilities/Finder Applications" ]]; then
/usr/bin/sudo -u "$SUDO_USER" /bin/ln -s "/System/Library/CoreServices/Finder.app/Contents/Applications" "/Users/$SUDO_USER/Applications/Utilities/Finder Applications"
fi
if [[ ! -e "/Users/$SUDO_USER/Applications/Utilities/Finder Libraries" ]]; then
/usr/bin/sudo -u "$SUDO_USER" /bin/ln -s "/System/Library/CoreServices/Finder.app/Contents/Resources/MyLibraries" "/Users/$SUDO_USER/Applications/Utilities/Finder Libraries"
fi
if [[ ! -e "/Users/$SUDO_USER/Applications/Utilities/System Applications" ]]; then
/usr/bin/sudo -u "$SUDO_USER" /bin/ln -s "/System/Library/CoreServices/Applications" "/Users/$SUDO_USER/Applications/Utilities/System Applications"
fi
if [[ ! -e "/Users/$SUDO_USER/Applications/Utilities/System Utilities" ]]; then
/usr/bin/sudo -u "$SUDO_USER" /bin/ln -s "/Applications/Utilities" "/Users/$SUDO_USER/Applications/Utilities/System Utilities"
fi
if [[ ! -e "/Users/$SUDO_USER/Library/Managed Items/My Applications" ]]; then
/usr/bin/sudo -u "$SUDO_USER" /bin/ln -s "/Users/$SUDO_USER/Applications" "/Users/$SUDO_USER/Library/Managed Items/My Applications"
fi

########################################
###アプリケーションの終了
###コンソールユーザーにのみ処理する
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
/bin/echo "CONSOLE_USER:$CONSOLE_USER"
if [ -z "$CONSOLE_USER" ]; then
	/bin/echo "コンソールユーザーが無い=電源入れてログインウィンドウ状態"
else
	#####OSAスクリプトはエラーすることも多い(初回インストール時はエラーになる)
	if ! /usr/bin/osascript -e "tell application id \"com.adobe.DNGConverter\" to quit"; then
		##念の為　KILLもする
		/usr/bin/killall "Adobe DNG Converter" 2>/dev/null
	fi
fi
/bin/sleep 2

############################################################
######### インストール
/bin/echo "インストール開始:" "$SUDO_USER"
###ディスクをマウント
/usr/bin/hdiutil attach "$USER_TEMP_DIR/$DL_FILE_NAME" -noverify -nobrowse -noautoopen
sleep 2
####
STR_VOLUME_NAME=$(/bin/ls /Volumes | grep DNG)
/bin/echo "マウントボリューム:" "$STR_VOLUME_NAME"
STR_PKG_NAME="$STR_VOLUME_NAME.pkg"
/bin/echo "パッケージ:" "$STR_PKG_NAME"
/usr/sbin/installer -pkg "/Volumes/$STR_VOLUME_NAME/$STR_PKG_NAME" -target / -dumplog -allowUntrusted -lang ja

sleep 2
###ディスクをアンマウント
/usr/bin/hdiutil detach "/Volumes/$STR_VOLUME_NAME" -force


################################################
###設定項目
STR_BUNDLEID="com.adobe.DNGConverter"
STR_APP_PATH="/Applications/Adobe DNG Converter.app"
###アプリケーション名を取得
STR_APP_NAME=$(/usr/bin/defaults read "$STR_APP_PATH/Contents/Info.plist" CFBundleDisplayName)
if [ -z "$STR_APP_NAME" ]; then
	STR_APP_NAME=$(/usr/bin/defaults read "$STR_APP_PATH/Contents/Info.plist" CFBundleName)
fi
/bin/echo "アプリケーション名：$STR_APP_NAME"
################################################
### DOCKに登録済みかゴミ箱に入れる前に調べておく
##Dockの登録数を調べる
JSON_PERSISENT_APPS=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/defaults read com.apple.dock persistent-apps)
NUN_CNT_ITEM=$(/bin/echo "$JSON_PERSISENT_APPS" | grep -o "tile-data" | wc -l)
/bin/echo "Dock登録数：$NUN_CNT_ITEM"
##Dockの登録数だけ繰り返し
NUM_CNT=0           #カウンタ初期化
NUM_POSITION="NULL" #ポジション番号にNULL文字を入れる
###対象のバンドルIDがDockに登録されているか順番に調べる
while [ $NUM_CNT -lt "$NUN_CNT_ITEM" ]; do
	##順番にバンドルIDを取得して
	STR_CHK_BUNDLEID=$(/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "Print:persistent-apps:$NUM_CNT:tile-data:bundle-identifier" "$HOME/Library/Preferences/com.apple.dock.plist")
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
/usr/bin/sudo -u "$SUDO_USER" /usr/bin/defaults write com.apple.dock persistent-apps -array-add "$PLIST_DICT"
else
	##すでに登録済みの場合は一旦削除
	/bin/echo "Dockの$NUM_POSITION に登録済み　削除してから同じ場所に登録しなおします"
	##削除して
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "Delete:persistent-apps:$NUM_POSITION" "$HOME/Library/Preferences/com.apple.dock.plist"
	##保存
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "Save" "$HOME/Library/Preferences/com.apple.dock.plist"
	###同じ内容を作成する
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION dict" "$HOME/Library/Preferences/com.apple.dock.plist"
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:GUID integer $RANDOM$RANDOM" "$HOME/Library/Preferences/com.apple.dock.plist"
	## 想定値 file-tile directory-tile
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-type string file-tile" "$HOME/Library/Preferences/com.apple.dock.plist"
	###↑この親Dictに子要素としてtile-dataをDictで追加
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data dict" "$HOME/Library/Preferences/com.apple.dock.plist"
	###↑子要素のtile-dataにキーと値を入れていく
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:showas integer 0" "$HOME/Library/Preferences/com.apple.dock.plist"
	## 想定値 2：フォルダ　41：アプリケーション 169 Launchpad とMission Control
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:file-type integer 41" "$HOME/Library/Preferences/com.apple.dock.plist"
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:displayas integer 0" "$HOME/Library/Preferences/com.apple.dock.plist"
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:parent-mod-date integer $(date '+%s')" "$HOME/Library/Preferences/com.apple.dock.plist"
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:file-mod-date integer $(date '+%s')" "$HOME/Library/Preferences/com.apple.dock.plist"
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:file-label string $STR_APP_NAME" "$HOME/Library/Preferences/com.apple.dock.plist"
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:is-beta bool false" "$HOME/Library/Preferences/com.apple.dock.plist"
	###↑この子要素のtile-dataに孫要素でfile-dataをDictで追加
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:file-data dict" "$HOME/Library/Preferences/com.apple.dock.plist"
	###値を入れていく
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:file-data:_CFURLStringType integer 15" "$HOME/Library/Preferences/com.apple.dock.plist"
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "add:persistent-apps:$NUM_POSITION:tile-data:file-data:_CFURLString string file://$STR_APP_PATH" "$HOME/Library/Preferences/com.apple.dock.plist"
	##保存
/usr/bin/sudo -u "$SUDO_USER" /usr/libexec/PlistBuddy -c "Save" "$HOME/Library/Preferences/com.apple.dock.plist"
fi
###
/bin/echo "処理終了 DOCKを再起動します"
/usr/bin/killall "Dock"

exit 0
