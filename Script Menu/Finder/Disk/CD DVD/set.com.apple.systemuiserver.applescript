#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

###############################################
###イジェクトメニュー有効化
set strFilePath to ("/System/Library/CoreServices/Menu Extras/Eject.menu") as text
tell application "Finder"
	set aliasFilePath to POSIX file strFilePath as alias
	open aliasFilePath
end tell

###############################################
###Plist編集

##########################################
###【１】パスURL
set strFilePath to "~/Library/Preferences/com.apple.systemuiserver.plist"
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath)

##########################################
### 【２】PLISTを可変レコードとして読み込み
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL)

##########################################
### 【３】処理はここで
set ocidDoubleValue to (refMe's NSNumber's numberWithDouble:(410))
(ocidPlistDict's setValue:(ocidDoubleValue) forKey:("NSStatusItem Preferred Position com.apple.menuextra.eject"))

set ocidFalse to (refMe's NSNumber's numberWithBool:false)
(ocidPlistDict's setValue:(ocidFalse) forKey:("NSStatusItem Visible Item-0"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("NSStatusItem Visible Item-1"))

set ocidTrue to (refMe's NSNumber's numberWithBool:true)
(ocidPlistDict's setValue:(ocidTrue) forKey:("NSStatusItem Visible com.apple.menuextra.eject"))
(ocidPlistDict's setValue:(ocidTrue) forKey:("__NSEnableTSMDocumentWindowLevel"))

set ocidArrayValue to refMe's NSArray's arrayWithArray:({"/System/Library/CoreServices/Menu Extras/Eject.menu"})
(ocidPlistDict's setObject:(ocidArrayValue) forKey:("menuExtras"))

##########################################
####【４】保存 ここは上書き
set boolDone to ocidPlistDict's writeToURL:(ocidFilePathURL) atomically:true

log boolDone

return "処理終了"

