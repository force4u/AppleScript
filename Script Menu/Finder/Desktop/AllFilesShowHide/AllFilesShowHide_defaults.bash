#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
###実行しているユーザー名
STAT_USR=$(/usr/bin/stat -f%Su /dev/console)
/bin/echo "STAT_USR(console): $STAT_USR"
###############
STR_PLIST_PATH="$HOME/Library/Preferences/com.apple.finder.plist"
#defaults
STR_BOOL_VALUE=$(/usr/bin/defaults read com.apple.finder AppleShowAllFiles)
/bin/echo "defaults:ユーザー設定は $STR_BOOL_VALUE　です"
#今の設定の逆を設定する
if [ "$STR_BOOL_VALUE" = "1" ]; then
	/usr/bin/defaults write com.apple.finder AppleShowAllFiles -bool false
else
	/usr/bin/defaults write com.apple.finder AppleShowAllFiles -bool true
fi
sleep 1
#確認
STR_BOOL_VALUE=$(/usr/bin/defaults read com.apple.finder AppleShowAllFiles)
/bin/echo "defaults:ユーザー設定は $STR_BOOL_VALUE　に変わりました"
#反映
/usr/bin/killall cfprefsd
sleep 1
#Finder再起動
/usr/bin/killall Finder

exit 0
