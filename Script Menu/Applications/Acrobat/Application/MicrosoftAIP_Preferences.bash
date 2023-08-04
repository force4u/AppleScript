#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#ユーザードメインにインストール

########################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"
###
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
	CURRENT_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
	/bin/echo "実行ユーザー：" "$CURRENT_USER"
fi
########################################
###コンソールユーザー ログイン中のユーザー
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
/bin/echo "ログイン中のユーザー:$CONSOLE_USER"

########################################
###ローカルのユーザーアカウントを取得
STR_RESULT=$(/usr/bin/dscl localhost -list /Local/Default/Users PrimaryGroupID | /usr/bin/awk '$2 == 20 { print $1 }')
###リストにする
read -d '\\n' -r -a LIST_USER <<<"$STR_RESULT"
###リスト内の項目数=ユーザー数
NUM_CNT=${#LIST_USER[@]}
/bin/echo "ユーザー数：" "$NUM_CNT"
########################################
##リストの内容を順番に処理
for ITEM_LIST in "${LIST_USER[@]}"; do
	/bin/echo "LIST_USER:MKDIR:" "$ITEM_LIST"
done
########################################
##リストの内容を順番に処理　　ユーザー設定
for ITEM_LIST in "${LIST_USER[@]}"; do
	/usr/bin/sudo -u "$ITEM_LIST" /usr/libexec/PlistBuddy -c "Delete :DC:MicrosoftAIP:ShowDMB" "/Users/$ITEM_LIST/Library/Preferences/com.adobe.Acrobat.Pro.plist"

	/usr/bin/sudo -u "$ITEM_LIST" /usr/libexec/PlistBuddy -c "Add :DC:MicrosoftAIP:ShowDMB array" "/Users/$ITEM_LIST/Library/Preferences/com.adobe.Acrobat.Pro.plist"
	/usr/bin/sudo -u "$ITEM_LIST" /usr/libexec/PlistBuddy -c "Add :DC:MicrosoftAIP:ShowDMB:item1 bool true" "/Users/$ITEM_LIST/Library/Preferences/com.adobe.Acrobat.Pro.plist"
	/usr/bin/sudo -u "$ITEM_LIST" /usr/libexec/PlistBuddy -c "Add :DC:MicrosoftAIP:ShowDMB:item0 integer 0" "/Users/$ITEM_LIST/Library/Preferences/com.adobe.Acrobat.Pro.plist"
done
/bin/echo "DONE:User設定"
########################################
##ローカル設定
/usr/bin/sudo /usr/bin/touch "/Library/Preferences/com.adobe.Acrobat.Pro.plist"
/usr/bin/sudo /usr/libexec/PlistBuddy -c "Delete :DC:FeatureLockdown:bMIPLabelling" "/Library/Preferences/com.adobe.Acrobat.Pro.plist"
/usr/bin/sudo /usr/libexec/PlistBuddy -c "Add :DC:FeatureLockdown:bMIPLabelling bool true" "/Library/Preferences/com.adobe.Acrobat.Pro.plist"
/bin/echo "DONE:Local設定"
