#!/bin/bash -p
#com.cocolog-nifty.quicktimer.icefloe
#	詳しくはこちら
#	https://quicktimer.cocolog-nifty.com/icefloe/2023/11/post-332015.html
#################################################
##ファイルを確認　エラーよけ
/usr/bin/touch "$HOME/Library/LaunchAgents/com.google.GoogleUpdater.wake.plist"
/usr/bin/touch "$HOME/Library/LaunchAgents/com.google.keystone.agent.plist"
/usr/bin/touch "$HOME/Library/LaunchAgents/com.google.keystone.xpcservice.plist"
##ロック解除
/usr/bin/chflags nouchg "$HOME/Library/LaunchAgents/com.google.GoogleUpdater.wake.plist"
/usr/bin/chflags nouchg "$HOME/Library/LaunchAgents/com.google.keystone.agent.plist"
/usr/bin/chflags nouchg "$HOME/Library/LaunchAgents/com.google.keystone.xpcservice.plist"
##ACL初期化
/bin/chmod -N "$HOME/Library/LaunchAgents/com.google.GoogleUpdater.wake.plist"
/bin/chmod -N "$HOME/Library/LaunchAgents/com.google.keystone.agent.plist"
/bin/chmod -N "$HOME/Library/LaunchAgents/com.google.keystone.xpcservice.plist"
##ファイルを削除
/bin/rm  "$HOME/Library/LaunchAgents/com.google.GoogleUpdater.wake.plist"
/bin/rm  "$HOME/Library/LaunchAgents/com.google.keystone.agent.plist"
/bin/rm  "$HOME/Library/LaunchAgents/com.google.keystone.xpcservice.plist"
##空のファイルを生成
/usr/bin/touch "$HOME/Library/LaunchAgents/com.google.GoogleUpdater.wake.plist"
/usr/bin/touch "$HOME/Library/LaunchAgents/com.google.keystone.agent.plist"
/usr/bin/touch "$HOME/Library/LaunchAgents/com.google.keystone.xpcservice.plist"
##アクセス権変更
/bin/chmod 644 "$HOME/Library/LaunchAgents/com.google.GoogleUpdater.wake.plist"
/bin/chmod 644 "$HOME/Library/LaunchAgents/com.google.keystone.agent.plist"
/bin/chmod 644 "$HOME/Library/LaunchAgents/com.google.keystone.xpcservice.plist"
##ロック
/usr/bin/chflags uchg "$HOME/Library/LaunchAgents/com.google.GoogleUpdater.wake.plist"
/usr/bin/chflags uchg "$HOME/Library/LaunchAgents/com.google.keystone.agent.plist"
/usr/bin/chflags uchg "$HOME/Library/LaunchAgents/com.google.keystone.xpcservice.plist"

exit 0
