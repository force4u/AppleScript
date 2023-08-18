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
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###notbackedup 分
STR_DIR_PATH="/private/var/db/locationd/Library/Preferences/ByHost/"
STR_FILE_NAME="com.apple.locationd.notbackedup.$STR_DEVICE_UUID.plist"
STR_PLIST_PATH="$STR_DIR_PATH$STR_FILE_NAME"
/bin/echo "PLISTファイルパス：$STR_PLIST_PATH"
STR_RESPONSE=$(/usr/bin/sudo -u _locationd /usr/bin/defaults read "$STR_PLIST_PATH" LocationServicesEnabled -boolean)
/bin/echo "/usr/bin/sudo -u _locationd  /usr/bin/defaults read $STR_PLIST_PATH LocationServicesEnabled -boolean"
/bin/echo "↑ 実行したコマンド ↓ 結果"
if [ "$STR_RESPONSE" = "1" ]; then
	/bin/echo "notbackedup設定値：$STR_RESPONSE 有効"
elif [ "$STR_RESPONSE" = "0" ]; then
	/bin/echo "notbackedup設定値：$STR_RESPONSE 無効"
fi

########################################
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###通常分
STR_DIR_PATH="/private/var/db/locationd/Library/Preferences/ByHost/"
STR_FILE_NAME="com.apple.locationd.$STR_DEVICE_UUID.plist"
STR_PLIST_PATH="$STR_DIR_PATH$STR_FILE_NAME"
/bin/echo "PLISTファイルパス：$STR_PLIST_PATH"
STR_RESPONSE=$(/usr/bin/sudo -u _locationd /usr/bin/defaults read "$STR_PLIST_PATH" LocationServicesEnabled -boolean)
/bin/echo "/usr/bin/sudo -u _locationd  /usr/bin/defaults read $STR_PLIST_PATH LocationServicesEnabled -boolean"
/bin/echo "↑ 実行したコマンド ↓ 結果"
if [ "$STR_RESPONSE" = "1" ]; then
	/bin/echo "com.apple.locationd設定値：$STR_RESPONSE 有効"
elif [ "$STR_RESPONSE" = "0" ]; then
	/bin/echo "com.apple.locationd設定値：$STR_RESPONSE 無効"
fi

########################################
/bin/echo "設定変更処理:開始"
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###notbackedup 分
STR_DIR_PATH="/private/var/db/locationd/Library/Preferences/ByHost/"
STR_FILE_NAME="com.apple.locationd.notbackedup.$STR_DEVICE_UUID.plist"
STR_PLIST_PATH="$STR_DIR_PATH$STR_FILE_NAME"
/bin/echo "PLISTファイルパス：$STR_PLIST_PATH"
STR_RESPONSE=$(/usr/bin/sudo -u _locationd /usr/bin/defaults write "$STR_PLIST_PATH" LocationServicesEnabled -boolean true)
/bin/echo "/usr/bin/sudo -u _locationd  /usr/bin/defaults write $STR_PLIST_PATH LocationServicesEnabled -boolean true"
/bin/echo "↑ 実行したコマンド ↓ 結果"
/bin/echo "$STR_RESPONSE"

########################################
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###通常分
STR_DIR_PATH="/private/var/db/locationd/Library/Preferences/ByHost/"
STR_FILE_NAME="com.apple.locationd.$STR_DEVICE_UUID.plist"
STR_PLIST_PATH="$STR_DIR_PATH$STR_FILE_NAME"
/bin/echo "PLISTファイルパス：$STR_PLIST_PATH"
STR_RESPONSE=$(/usr/bin/sudo -u _locationd /usr/bin/defaults write "$STR_PLIST_PATH" LocationServicesEnabled -boolean true)
/bin/echo "/usr/bin/sudo -u _locationd  /usr/bin/defaults write $STR_PLIST_PATH LocationServicesEnabled -boolean true"
/bin/echo "↑ 実行したコマンド ↓ 結果"
/bin/echo "$STR_RESPONSE"


/bin/echo "設定変更処理:終了"
########################################
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###notbackedup 分
STR_DIR_PATH="/private/var/db/locationd/Library/Preferences/ByHost/"
STR_FILE_NAME="com.apple.locationd.notbackedup.$STR_DEVICE_UUID.plist"
STR_PLIST_PATH="$STR_DIR_PATH$STR_FILE_NAME"
/bin/echo "PLISTファイルパス：$STR_PLIST_PATH"
STR_RESPONSE=$(/usr/bin/sudo -u _locationd /usr/bin/defaults read "$STR_PLIST_PATH" LocationServicesEnabled -boolean)
/bin/echo "/usr/bin/sudo -u _locationd  /usr/bin/defaults read $STR_PLIST_PATH LocationServicesEnabled -boolean"
/bin/echo "↑ 実行したコマンド ↓ 結果"
if [ "$STR_RESPONSE" = "1" ]; then
	/bin/echo "notbackedup設定値：$STR_RESPONSE 有効"
elif [ "$STR_RESPONSE" = "0" ]; then
	/bin/echo "notbackedup設定値：$STR_RESPONSE 無効"
fi

########################################
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###通常分
STR_DIR_PATH="/private/var/db/locationd/Library/Preferences/ByHost/"
STR_FILE_NAME="com.apple.locationd.$STR_DEVICE_UUID.plist"
STR_PLIST_PATH="$STR_DIR_PATH$STR_FILE_NAME"
/bin/echo "PLISTファイルパス：$STR_PLIST_PATH"
STR_RESPONSE=$(/usr/bin/sudo -u _locationd /usr/bin/defaults read "$STR_PLIST_PATH" LocationServicesEnabled -boolean)
/bin/echo "/usr/bin/sudo -u _locationd  /usr/bin/defaults read $STR_PLIST_PATH LocationServicesEnabled -boolean"
/bin/echo "↑ 実行したコマンド ↓ 結果"
if [ "$STR_RESPONSE" = "1" ]; then
	/bin/echo "com.apple.locationd設定値：$STR_RESPONSE 有効"
elif [ "$STR_RESPONSE" = "0" ]; then
	/bin/echo "com.apple.locationd設定値：$STR_RESPONSE 無効"
fi
########################################
/bin/echo "アクセス権メンテナンス"
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###アクセス権メンテナンス
STR_DIR_PATH="/private/var/db/locationd/Library/Preferences"
/bin/echo "メンテナンスディレクトリ：$STR_DIR_PATH"
STR_RESPONSE=$(/usr/sbin/chown -R _locationd "$STR_DIR_PATH")
/bin/echo "/usr/sbin/chown -R _locationd $STR_DIR_PATH"
/bin/echo "↑ 実行したコマンドライン ↓ 結果"
/bin/echo "$STR_RESPONSE"
########################################
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###アクセス権メンテナンス
STR_DIR_PATH="/private/var/db/locationd/Library/Preferences"
/bin/echo "メンテナンスディレクトリ：$STR_DIR_PATH"
STR_RESPONSE=$(/usr/bin/chgrp -R _locationd "$STR_DIR_PATH")
/bin/echo "/usr/bin/chgrp -R _locationd $STR_DIR_PATH"
/bin/echo "↑ 実行したコマンドライン ↓ 結果"
/bin/echo "$STR_RESPONSE"

########################################
/bin/echo "locationd再起動"
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###
STR_RESPONSE=$(/usr/bin/killall -HUP locationd)
/bin/echo "/usr/bin/killall -HUP locationd"
/bin/echo "↑ 実行したコマンド "
/bin/echo "$STR_RESPONSE"




exit 0


