#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#
#################################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行ユーザー(whoami): $USER_WHOAMI"
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
#################################################
###
USER_MKTMP_DIR=$(/usr/bin/mktemp -d)
USR_TMP_DIR_T=$(/usr/bin/dirname "$USER_MKTMP_DIR")
USR_TMP_DIR=$(/usr/bin/dirname "$USR_TMP_DIR_T")
###
STR_GO2_TRASH_DIR="$USR_TMP_DIR""/T/us.zoom.xos"
/bin/mkdir -p "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$USR_TMP_DIR""/C/us.zoom.xos"
/bin/mkdir -p "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

#################################################
###
STR_GO2_TRASH_DIR="/Applications/ZoomOutlookPlugin"
/bin/mkdir -p "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Caches/us.zoom.xos"
/bin/mkdir -p "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Application Scripts/BJ4HAAB9B3.ZoomClient3rd"
/bin/mkdir -p "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/WebKit/us.zoom.xos"
/bin/mkdir -p "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME//Library/Logs/zoom.us"
/bin/mkdir -p "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Logs/ZoomPhone"
/bin/mkdir -p "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/HTTPStorages/us.zoom.xos"
/bin/mkdir -p "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Group Containers/BJ4HAAB9B3.ZoomClient3rd"
/bin/mkdir -p "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Application Support/zoom.us/data/WaitingRoom"
/bin/mkdir -p "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Application Support/zoom.us/data/VideoClips"
/bin/mkdir -p "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

###############
STR_GO2_TRASH_DIR="$HOME/Library/Receipts/ZoomMacOutlookPlugin.pkg.plist"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Receipts/ZoomMacOutlookPlugin.pkg.bom"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Receipts/us.zoom.pkg.videomeeting.bom"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Receipts/us.zoom.pkg.videomeeting.plist"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Logs/zoomusinstall.log"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/HTTPStorages/us.zoom.xos.binarycookies"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Application Support/zoom.us/data/zoomus.enc.db.malformed"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Application Support/zoom.us/data/meetingpaaplog.bin"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Application Support/zoom.us/data/ptpaaplog.bin"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"
###
STR_GO2_TRASH_DIR="$HOME/Library/Application Support/zoom.us/data/zmonitorlog.bin"
/usr/bin/touch "$STR_GO2_TRASH_DIR"
USER_TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/ZOOM.XXXXXXXX")
/bin/mv "$STR_GO2_TRASH_DIR" "$USER_TRASH_DIR"

#####
#
/usr/bin/touch "$HOME/Library/Application Support/zoom.us/ZoomClips.app"

/bin/rm "$HOME/Library/Application Support/zoom.us/ZoomClips.app"

/bin/ln -s "$HOME/Library/Application Support/zoom.us/Plugins/Frameworks/ZoomClips.app" "$HOME/Library/Application Support/zoom.us/ZoomClips.app"

/bin/echo "Done"
exit 0
