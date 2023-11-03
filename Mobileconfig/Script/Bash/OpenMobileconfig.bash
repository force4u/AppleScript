#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#################################################
###bashでmobileconfigを開くサンプルmacOS14対応
###設定項目 パス
STR_FILE_PATH="$HOME/Documents/Mobileconfig/com.microsoft.edgemac.ManagedFavorites.mobileconfig"

###########################
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行ユーザー(whoami): $USER_WHOAMI"
### path to me
SCRIPT_PATH="${BASH_SOURCE[0]}"
/bin/echo "/usr/bin/sudo \"$SCRIPT_PATH\""
/bin/echo "↑を実行してください"
###実行しているユーザー名
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
/bin/echo "コンソールユーザー(scutil): $CONSOLE_USER"
###########################
###バックアップ
/bin/mkdir -p "$HOME/Documents/Mobileconfig/Bakup"
STR_DATE=$(/bin/date +'%Y%m%d')
STR_SAVE_FILE_PATH="$HOME/Documents/Mobileconfig/Bakup/$STR_DATE"".plist"
/usr/bin/profiles show -user "$CONSOLE_USER" -type configuration -output "$STR_SAVE_FILE_PATH"
##システム設定でmobileconfigプロファイルを開きます
/usr/bin/open "$STR_FILE_PATH" | /usr/bin/open  "x-apple.systempreferences:com.apple.preferences.configurationprofiles"



exit
