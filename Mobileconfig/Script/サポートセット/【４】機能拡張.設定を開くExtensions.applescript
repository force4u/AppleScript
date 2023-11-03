#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application
set strBundleID to "com.apple.systempreferences" as text
###URLにする
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
###スキーム
ocidURLComponents's setScheme:("x-apple.systempreferences")
###パネルIDをパスにセット
ocidURLComponents's setPath:("com.apple.ExtensionsPreferences")
###アンカーをクエリーとして追加
ocidURLComponents's setQuery:("Extensions")
set ocidOpenAppURL to ocidURLComponents's |URL|
set strOpenAppURL to ocidOpenAppURL's absoluteString() as text
###ワークスペースで開く
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appShardWorkspace's openURL:(ocidOpenAppURL)
log boolDone
if boolDone is false then
tell application id "com.apple.systempreferences" to activate
tell application id "com.apple.systempreferences"
reveal anchor "Extensions" of pane id "com.apple.ExtensionsPreferences"
end tell
tell application id "com.apple.finder"
open location "x-apple.systempreferences:com.apple.ExtensionsPreferences?Extensions"
end tell
tell application id "com.apple.systempreferences" to activate
end if
return
