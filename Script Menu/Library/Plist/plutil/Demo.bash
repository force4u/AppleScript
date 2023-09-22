#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
/bin/mkdir -p "$HOME/Desktop/PlutilDemo"
#################################################
/usr/bin/plutil -help > "$HOME/Desktop/PlutilDemo/help.txt"
##正常性確認
/usr/bin/plutil -lint "$HOME/Library/Preferences/com.apple.archiveutility.plist"
##画面表示
/usr/bin/plutil -p "$HOME/Library/Preferences/com.apple.archiveutility.plist"
##新規作成
/usr/bin/plutil -create xml1 "$HOME/Desktop/PlutilDemo/some.plist"
##値を入れる
/usr/bin/plutil -insert someKey -string someValue "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -insert boolKeyA -bool 1 "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -insert boolKeyB -bool false "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -insert intKey -integer 100 "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -insert intKey -float 0.25 "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -insert arrayKey -array "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -insert arrayKey.0 -string someArray1 "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -insert arrayKey.1 -string someArray2 "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -insert arrayKey.2 -string someArray3 "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -insert dictKey -dictionary "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -insert dictKey.someKey1 -integer 1 "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -insert dictKey.someKey2 -integer 2 "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -insert dictKey.someKey3 -integer 3 "$HOME/Desktop/PlutilDemo/some.plist"
###タイプを調べる
/usr/bin/plutil -type dictKey "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -type arrayKey "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -type intKey "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -type boolKeyA "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -type boolKeyB "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -type someKey "$HOME/Desktop/PlutilDemo/some.plist"
###削除
/usr/bin/plutil -remove arrayKey.2 "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -remove dictKey.someKey3 "$HOME/Desktop/PlutilDemo/some.plist"
###値変更
/usr/bin/plutil -replace arrayKey.0 -string someArrayA "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -replace arrayKey.1 -string someArrayB "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -replace dictKey.someKey1 -integer 1 "$HOME/Desktop/PlutilDemo/some.plist"
/usr/bin/plutil -replace dictKey.someKey2 -integer 2 "$HOME/Desktop/PlutilDemo/some.plist"
##フォーマット変換
/usr/bin/plutil -convert xml1 "$HOME/Desktop/PlutilDemo/some.plist" -o "$HOME/Desktop/PlutilDemo/xml.plist"
/usr/bin/plutil -convert binary1 "$HOME/Desktop/PlutilDemo/xml.plist" -o "$HOME/Desktop/PlutilDemo/bin.plist"
/usr/bin/plutil -convert objc "$HOME/Desktop/PlutilDemo/some.plist" -o "$HOME/Desktop/PlutilDemo/some.h"
/usr/bin/plutil -convert swift "$HOME/Desktop/PlutilDemo/some.plist" -o "$HOME/Desktop/PlutilDemo/some.swift"
/usr/bin/plutil -convert json "$HOME/Desktop/PlutilDemo/bin.plist" -o "$HOME/Desktop/PlutilDemo/bin.json"
/usr/bin/plutil -convert json "$HOME/Desktop/PlutilDemo/some.plist" -o "$HOME/Desktop/PlutilDemo/some.json"
/usr/bin/plutil -convert xml1 "$HOME/Desktop/PlutilDemo/some.json" -o "$HOME/Desktop/PlutilDemo/some.json.plist"
exit 0
