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
	/bin/echo "↑を実行してください"
	exit 1
else
	###実行しているユーザー名
	SUDO_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
	/bin/echo "実行ユーザー：" "$SUDO_USER"
fi

#################################
#インストール基本
#################################
###
STR_URL="https://go.microsoft.com/fwlink/?linkid=869428"
###
STR_APP_NAME="Microsoft Teams.app"
###
STR_PLIST_PATH="/Applications/$STR_APP_NAME/Contents/Info.plist"
STR_BUNDLE_ID=$(/usr/bin/defaults read "$STR_PLIST_PATH" CFBundleIdentifier)
###アプリケーション終了
/usr/bin/sudo -u "$SUDO_USER" /usr/bin/osascript -e "tell application id \"$STR_BUNDLE_ID\" to quit"

##念の為　KILLもする
/usr/bin/killall "Teams" 2>/dev/null
/usr/bin/killall "Microsoft Teams" 2>/dev/null
/usr/bin/killall "Microsoft Teams Helper"
/usr/bin/killall "Microsoft Teams Helper (GPU)"
/usr/bin/killall "Microsoft Teams Helper (Renderer)"
/bin/echo "アプリケーション終了"
/bin/sleep 2
#################################
#以下定型
#################################
###起動時に削除される項目
LOCAL_TMP_DIR=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/mktemp -d)
/bin/echo "TMPDIR：" "$LOCAL_TMP_DIR"
###ファイル名を取得
PKG_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
/bin/echo "PKG_FILE_NAME" "$PKG_FILE_NAME"

###ファイル名指定してダウンロード
/usr/bin/sudo -u "$SUDO_USER" /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$PKG_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20
/bin/echo "インストーラーダウンロードDone"

### インストール（上書き）を実行する
/usr/sbin/installer -pkg "$LOCAL_TMP_DIR/$PKG_FILE_NAME" -target / -dumplog -allowUntrusted -lang ja
/bin/echo "インストールDone"

################################################
###設定項目
STR_BUNDLEID="com.microsoft.teams"
STR_APP_PATH="/Applications/Microsoft Teams.app"
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
/usr/bin/sudo -u "$SUDO_USER" /usr/bin/killall "Dock"

exit 0


