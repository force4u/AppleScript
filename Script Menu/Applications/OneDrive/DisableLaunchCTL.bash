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
#
#################################
ITEM_UTI="com.microsoft.OneDriveStandaloneUpdaterDaemon"
/bin/echo "$ITEM_UTI"
STR_FILE_PATH="/Library/LaunchDaemons/$ITEM_UTI.plist"
if [ -f "$STR_FILE_PATH" ]; then
/usr/bin/sudo /bin/launchctl stop -w "$STR_FILE_PATH"
#/usr/bin/sudo /bin/launchctl unload -w "$STR_FILE_PATH"
/usr/bin/sudo /bin/launchctl disable system "$STR_FILE_PATH"
/usr/bin/sudo /bin/launchctl bootout system "$STR_FILE_PATH"
#	/bin/launchctl kill -w "$STR_FILE_PATH"
#	/bin/rm "$STR_FILE_PATH"
fi

ITEM_UTI="com.microsoft.OneDriveUpdaterDaemon"
/bin/echo "$ITEM_UTI"
STR_FILE_PATH="/Library/LaunchDaemons/$ITEM_UTI.plist"
if [ -f "$STR_FILE_PATH" ]; then
/usr/bin/sudo	/bin/launchctl stop -w "$STR_FILE_PATH"
#/usr/bin/sudo	/bin/launchctl unload -w "$STR_FILE_PATH"
/usr/bin/sudo /bin/launchctl disable system "$STR_FILE_PATH"
/usr/bin/sudo /bin/launchctl bootout system "$STR_FILE_PATH"
#	/bin/launchctl kill -w "$STR_FILE_PATH"
#	/bin/rm "$STR_FILE_PATH"
fi


ITEM_UTI="com.microsoft.OneDriveStandaloneUpdater"
/bin/echo "$ITEM_UTI"
STR_FILE_PATH="/Library/LaunchAgents/$ITEM_UTI.plist"
if [ -f "$STR_FILE_PATH" ]; then
/usr/bin/sudo	/bin/launchctl stop -w "$STR_FILE_PATH"
#/usr/bin/sudo	/bin/launchctl unload -w "$STR_FILE_PATH"
/usr/bin/sudo /bin/launchctl disable system "$STR_FILE_PATH"
/usr/bin/sudo /bin/launchctl bootout system "$STR_FILE_PATH"
#	/bin/launchctl kill -w "$STR_FILE_PATH"
#	/bin/rm "$STR_FILE_PATH"
fi


exit 0
