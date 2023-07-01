#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#アーカイブユーティリティの推奨設定
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

###UTI
set strBundleID to "com.apple.archiveutility" as text

	tell application id strBundleID to quit

##########################################
###【１】ドキュメントのパスをNSString
set strFilePath to "~/Library/Preferences/com.apple.archiveutility.plist"

set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath)

##########################################
### 【２】PLISTを可変レコードとして読み込み
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL)

##########################################
### 【３】処理はここで
set ocidStringValue to refMe's NSString's stringWithString:(".")
(ocidPlistDict's setObject:(ocidStringValue) forKey:("dearchive-into"))

set ocidStringValue to refMe's NSString's stringWithString:(".")
(ocidPlistDict's setObject:(ocidStringValue) forKey:("archive-info -string"))

set ocidStringValue to refMe's NSString's stringWithString:("~/.Trash")
(ocidPlistDict's setObject:(ocidStringValue) forKey:("dearchive-move-after"))

set ocidStringValue to refMe's NSString's stringWithString:(".")
(ocidPlistDict's setObject:(ocidStringValue) forKey:("archive-move-after"))

set ocidStringValue to refMe's NSString's stringWithString:("zip")
(ocidPlistDict's setObject:(ocidStringValue) forKey:("archive-format"))

set ocidBoolValue to (refMe's NSNumber's numberWithBool:true)
(ocidPlistDict's setObject:(ocidBoolValue) forKey:("dearchive-recursively"))

set ocidBoolValue to (refMe's NSNumber's numberWithBool:true)
(ocidPlistDict's setObject:(ocidBoolValue) forKey:("archive-reveal-after"))

set ocidBoolValue to (refMe's NSNumber's numberWithBool:true)
(ocidPlistDict's setObject:(ocidBoolValue) forKey:("dearchive-reveal-after"))

##########################################
####【４】保存  ここは上書き
set boolDone to ocidPlistDict's writeToURL:(ocidFilePathURL) atomically:true
-->システムファイルなの書き込めないので書き込み失敗でfalseが返る
log boolDone

set strCommandText to "/usr/bin/killall cfprefsd" as text
do shell script strCommandText

return "処理終了"
