#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#
#################################################
### path to me
SCRIPT_PATH="${BASH_SOURCE[0]}"
/bin/echo "スクリプトパス: \"$SCRIPT_PATH\""
###実行しているユーザー名
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
/bin/echo "コンソールユーザー(scutil): $CONSOLE_USER"
###実行しているユーザー名
HOME_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
/bin/echo "実行ユーザー(HOME): $HOME_USER"
###logname
LOGIN_NAME=$(/usr/bin/logname)
/bin/echo "ログイン名(logname): $LOGIN_NAME"
###UID
USER_NAME=$(/usr/bin/id -un)
/bin/echo "ユーザー名(id): $USER_NAME"
###STAT
STAT_USR=$(/usr/bin/stat -f%Su /dev/console)
/bin/echo "STAT_USR(console): $STAT_USR"
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行ユーザー(whoami): $USER_WHOAMI"
########################################
#デバイスシリアル
#IOREG
STR_SAVE_DIR_PATH="/Users/$STAT_USR/Documents/Apple/IOreg"
/bin/mkdir -p "$STR_SAVE_DIR_PATH"
STR_SAVE_FILE_PATH="$STR_SAVE_DIR_PATH/IOPlatformExpertDevice.plist"
/usr/sbin/ioreg -c IOPlatformExpertDevice -a > "$STR_SAVE_FILE_PATH"
STR_IOPlatformSerialNumber=$(/usr/libexec/PlistBuddy -c "Print:IORegistryEntryChildren:0:IOPlatformSerialNumber" "$STR_SAVE_FILE_PATH")
/bin/echo "IOPlatformSerialNumber: $STR_IOPlatformSerialNumber"

#system_profiler
STR_SAVE_DIR_PATH="/Users/$STAT_USR/Documents/Apple/system_profiler"
/bin/mkdir -p "$STR_SAVE_DIR_PATH"
STR_SAVE_FILE_PATH="$STR_SAVE_DIR_PATH/SPHardwareDataType.plist"
/usr/sbin/system_profiler SPHardwareDataType -xml > "$STR_SAVE_FILE_PATH"
STR_serial_number=$(/usr/libexec/PlistBuddy -c "Print:0:_items:0:serial_number" "$STR_SAVE_FILE_PATH")
/bin/echo "STR_model_number: $STR_serial_number"

########################################
#コンフィグコード取得
#シリアル番号の後ろ４桁を取得して
STR_CONFIG_CODE="${STR_serial_number: -4}"
/bin/echo "configCode: $STR_CONFIG_CODE"
#XML取得
STR_URL="https://support-sp.apple.com/sp/product?cc=$STR_CONFIG_CODE&lang=ja_JP"
STR_XML=$(/usr/bin/curl "$STR_URL")
/bin/echo "XML: $STR_XML"
#XMLからモデル名を取得
STR_MODEL_NAME=$(/bin/echo "$STR_XML" | /usr/bin/xmllint --xpath 'string(//configCode)' -)
/bin/echo "モデル名: $STR_MODEL_NAME"


exit 0
