#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
########################################
#設定ファイルもゴミ箱に入ります
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

######################################################
#####

/usr/bin/sudo /bin/launchctl stop -w "/Library/LaunchAgents/com.google.keystone.agent.plist"
/usr/bin/sudo /bin/launchctl stop -w "/Library/LaunchAgents/com.google.keystone.xpcservice.plist"
/usr/bin/sudo /bin/launchctl stop -w "/Library/LaunchDaemons/com.google.keystone.daemon.plist"

/usr/bin/sudo /bin/launchctl bootout system "/Library/LaunchAgents/com.google.keystone.agent.plist"
/usr/bin/sudo /bin/launchctl bootout system "/Library/LaunchAgents/com.google.keystone.xpcservice.plist"
/usr/bin/sudo /bin/launchctl bootout system "/Library/LaunchDaemons/com.google.keystone.daemon.plist"

/bin/launchctl stop -w "$HOME/Library/LaunchAgents/com.google.keystone.agent.plist"
/bin/launchctl stop -w "$HOME/Library/LaunchAgents/com.google.keystone.xpcservice.plist"

/bin/launchctl disable gui/com.google.keystone.xpcservice
/bin/launchctl disable gui/com.google.keystone.agent

######################################################
#####古いファイルをゴミ箱に  AFTER
function DO_MOVE_TO_TRASH_AFTER() {
  if [ -e "$1" ]; then
    TRASH_DIR=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/mktemp -d "$HOME/.Trash/XXXXXXXX")
    /usr/bin/sudo /bin/mv "$1" "$TRASH_DIR"
    /usr/bin/sudo /bin/chmod 777 "$TRASH_DIR"
  fi
}
DO_MOVE_TO_TRASH_AFTER "/Applications/Google Drive.app"
DO_MOVE_TO_TRASH_AFTER "/Applications/Google Drive File Stream.app"

DO_MOVE_TO_TRASH_AFTER "/Applications/Google Sheets.app"
DO_MOVE_TO_TRASH_AFTER "/Applications/Google Docs.app"
DO_MOVE_TO_TRASH_AFTER "/Applications/Gooogle Slides.app"

DO_MOVE_TO_TRASH_AFTER "/Library/LaunchAgents/com.google.keystone.agent.plist"
DO_MOVE_TO_TRASH_AFTER "/Library/LaunchAgents/com.google.keystone.xpcservice.plist"
DO_MOVE_TO_TRASH_AFTER "/Library/LaunchDaemons/com.google.keystone.daemon.plist"

DO_MOVE_TO_TRASH_AFTER "/Library/Google"
DO_MOVE_TO_TRASH_AFTER "/Library/Application Support/Google"

DO_MOVE_TO_TRASH_AFTER "$HOME/Library/Preferences/com.google.drivefs.helper.renderer.plist"
DO_MOVE_TO_TRASH_AFTER "$HOME/Library/Preferences/com.google.drivefs.plist"
DO_MOVE_TO_TRASH_AFTER "$HOME/Library/Preferences/com.google.drivefs.settings.plist"

DO_MOVE_TO_TRASH_AFTER "$HOME/Library/Containers/com.google.drivefs.fpext"
DO_MOVE_TO_TRASH_AFTER "$HOME/Library/Containers/com.google.drivefs.finderhelper.findersync"
DO_MOVE_TO_TRASH_AFTER "$HOME/Library/Containers/com.google.drivefs.finderhelper"
DO_MOVE_TO_TRASH_AFTER "$HOME/Library/Containers/com.google.drivefs.helper.gpu"

DO_MOVE_TO_TRASH_AFTER "$HOME/Library/LaunchAgents/com.google.keystone.agent.plist"
DO_MOVE_TO_TRASH_AFTER "$HOME/Library/LaunchAgents/com.google.keystone.xpcservice.plist"

MKTEMP_DIR=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/mktemp -d)
TEMP_DIR_T="$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/dirname "$MKTEMP_DIR")"

DO_MOVE_TO_TRASH_AFTER "$TEMP_DIR_T/com.google.drivefs.finderhelper"
DO_MOVE_TO_TRASH_AFTER "$TEMP_DIR_T/com.google.drivefs.finderhelper.findersync"
DO_MOVE_TO_TRASH_AFTER "$TEMP_DIR_T/com.google.drivefs.fpext"
DO_MOVE_TO_TRASH_AFTER "$TEMP_DIR_T/com.google.drivefs.helper.gpu"

TEMP_DIR="$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/dirname "$TEMP_DIR_T")"
TEMP_DIR_C="${TEMP_DIR}/C"

DO_MOVE_TO_TRASH_AFTER "$TEMP_DIR_C/com.google.drivefs.finderhelper.findersync"
DO_MOVE_TO_TRASH_AFTER "$TEMP_DIR_C/com.google.drivefs.finderhelper"
DO_MOVE_TO_TRASH_AFTER "$TEMP_DIR_C/com.google.drivefs.fpext"
DO_MOVE_TO_TRASH_AFTER "$TEMP_DIR_C/com.google.drivefs.helper.gpu"

exit 0
