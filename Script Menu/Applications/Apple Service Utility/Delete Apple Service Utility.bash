#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#
#################################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行ユーザー(whoami): $USER_WHOAMI"
if [ "$USER_WHOAMI" != "root" ]; then
  /bin/echo "このスクリプトを実行するには管理者権限が必要です。"
  /bin/echo "sudo で実行してください"
  ### path to me
  SCRIPT_PATH="${BASH_SOURCE[0]}"
  /bin/echo "/usr/bin/sudo \"$SCRIPT_PATH\""
  /bin/echo "↑を実行してください"
  ###実行しているユーザー名
  CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
  /bin/echo "コンソールユーザー(scutil): $CONSOLE_USER"
  exit 1
else
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
fi

STR_GO2_TRASH_DIR="/usr/local/libexec/repaird"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Users/Shared/AppleServiceUtility"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Applications/Apple Service Utility.app"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Library/Preferences/com.apple.fielddiagnostics.appleserviceutility.updaterd.plist"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Library/Preferences/com.apple.RepairKit.repaird.plist"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Library/Preferences/com.apple.RepairKit.Diagnostic-8155.plist"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Users/$STAT_USR/Library/Preferences/com.apple.fielddiagnostics.MacConfigurationUtility.plist"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Users/$STAT_USR/Library/Preferences/com.apple.fielddiagnostics.appleserviceutility.uiapp.plist"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Users/$STAT_USR/Library/Preferences/com.apple.fielddiagnostics.appleserviceutility.uiapp.plist"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Users/$STAT_USR/Library/Preferences/com.apple.MobileDeviceUpdater.plist"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Library/LaunchDaemons/com.apple.fielddiagnostics.appleserviceutility.updaterXPCService.plist"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Library/LaunchDaemons/com.apple.repaird.plist"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Users/Shared/AppleInternal"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Users/Shared/Library/Preferences/Logging"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"


STR_GO2_TRASH_DIR="/var/log/ASUUXPCService.log"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

STR_GO2_TRASH_DIR="/Library/PrivilegedHelperTools/com.apple.fielddiagnostics.appleserviceutility.updaterd"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "/Users/$STAT_USR/.Trash/AppleServiceUtility.XXXXXXXX")
/bin/chmod 777 "$USER_TRASH_DIR"
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

exit 0
