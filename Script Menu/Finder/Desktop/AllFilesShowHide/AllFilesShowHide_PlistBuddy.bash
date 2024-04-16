#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
###実行しているユーザー名
STAT_USR=$(/usr/bin/stat -f%Su /dev/console)
/bin/echo "STAT_USR(console): $STAT_USR"
###############
STR_PLIST_PATH="$HOME/Library/Preferences/com.apple.finder.plist"
#PlistBuddy
STR_BOOL_VALUE=$(/usr/libexec/PlistBuddy -c "Print:AppleShowAllFiles:"  "$STR_PLIST_PATH")
/bin/echo "PlistBuddy:ユーザー設定は $STR_BOOL_VALUE　です"

if [ "$STR_BOOL_VALUE" = "true" ]; then
	/usr/libexec/PlistBuddy -c "Set:AppleShowAllFiles false" "$STR_PLIST_PATH"
else
	/usr/libexec/PlistBuddy -c "Set:AppleShowAllFiles true" "$STR_PLIST_PATH"
fi
STR_BOOL_VALUE=$(/usr/libexec/PlistBuddy -c "Save" "$STR_PLIST_PATH")
sleep 1
STR_BOOL_VALUE=$(/usr/libexec/PlistBuddy -c "Print:AppleShowAllFiles:"  "$STR_PLIST_PATH")
/bin/echo "PlistBuddy:ユーザー設定は $STR_BOOL_VALUE　に変わりました"

/usr/bin/killall cfprefsd
sleep 1
/usr/bin/killall Finder

exit 0
