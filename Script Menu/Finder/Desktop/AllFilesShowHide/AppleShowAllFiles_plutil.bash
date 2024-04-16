#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
###実行しているユーザー名
STAT_USR=$(/usr/bin/stat -f%Su /dev/console)
/bin/echo "STAT_USR(console): $STAT_USR"
###############
STR_PLIST_PATH="$HOME/Library/Preferences/com.apple.finder.plist"
#plutil
STR_BOOL_VALUE=$(/usr/bin/plutil -extract AppleShowAllFiles raw -expect bool "$STR_PLIST_PATH")
/bin/echo "plutil:ユーザー設定は $STR_BOOL_VALUE　です"

if [ "$STR_BOOL_VALUE" = "true" ]; then
	/usr/bin/plutil -replace AppleShowAllFiles -bool false "$STR_PLIST_PATH"
else
	/usr/bin/plutil -replace AppleShowAllFiles -bool true "$STR_PLIST_PATH"
fi

STR_BOOL_VALUE=$(/usr/bin/plutil -extract AppleShowAllFiles raw -expect bool "$STR_PLIST_PATH")
/bin/echo "plutil:ユーザー設定は $STR_BOOL_VALUE　に変わりました"

/usr/bin/killall cfprefsd
sleep 1
/usr/bin/killall Finder

exit 0
