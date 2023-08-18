#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
# 要管理者権限
########################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行ユーザー：$USER_WHOAMI"
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
###デバイスUUIDを取得する
STR_DEVICE_UUID=$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID/{print $3}')
/bin/echo "デバイスUUID：" "$STR_DEVICE_UUID"
########################################
###USERのUUID
STR_USER_UUID=$(/usr/bin/dscl localhost -list /Local/Default/Users GeneratedUID | grep "$SUDO_USER" | /usr/bin/awk '/ / { print $2 }')
/bin/echo "ユーザーUUID：" "$STR_USER_UUID"

########################################
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###notbackedup 分
STR_DIR_PATH="/private/var/db/locationd/"
STR_FILE_NAME="clients.plist"
STR_PLIST_PATH="$STR_DIR_PATH$STR_FILE_NAME"
/bin/echo "PLISTファイルパス：$STR_PLIST_PATH"
STR_RESPONSE=$(/usr/bin/sudo -u _locationd /usr/bin/defaults read "$STR_PLIST_PATH")


#	STR_CNT=$(/bin/echo "$STR_RESPONSE" | /usr/bin/tr -d -c '}' | /usr/bin/wc -m)
STR_CNT=$(/bin/echo "$STR_RESPONSE" | /usr/bin/grep -o  '};' | /usr/bin/wc -l)
/bin/echo "登録されているアプリケーション数:$STR_CNT"
###主要リストを取得する場合
########################################
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###ユーザーが呼び出している項目
STR_KEY=$(/usr/libexec/PlistBuddy -c "Print :" "$STR_PLIST_PATH" |/usr/bin/grep Dict | /usr/bin/awk '{print $1}' | grep "$STR_USER_UUID")
/bin/echo "キーの一覧"
/bin/echo "$STR_KEY"
########################################
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###rootで呼び出している項目
STR_KEY=$(/usr/libexec/PlistBuddy -c "Print :" "$STR_PLIST_PATH" |/usr/bin/grep Dict | /usr/bin/awk '{print $1}' | grep root )
/bin/echo "$STR_KEY"


exit 0
