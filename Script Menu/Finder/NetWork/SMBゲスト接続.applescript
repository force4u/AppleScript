#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

###接続用のURL
set strURL to ("smb://guest:guest@192.168.0.40:445/Shared") as text
###クリップボードに入れておいて
set appPasteboard to refMe's NSPasteboard's generalPasteboard()
appPasteboard's clearContents()
appPasteboard's setString:(strURL) forType:(refMe's NSPasteboardTypeString)

#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
##表示プロトコル
set listURL to {"_afpovertcp._tcp", "_smb._tcp", "_cifs_tcp"} as list
##ダイアログ
set strResults to choose URL strURL showing listURL with editable URL
###NSWorkspaceで開く
###そう、ダイアログいらないよね…笑
set ocidURLstr to refMe's NSString's stringWithString:(strResults)
set ocidUrlComponents to refMe's NSURLComponents's alloc()'s initWithString:(ocidURLstr)
set strScheme to (ocidUrlComponents's |scheme|()) as text

if strScheme is "afp" then
	###認証無しの場合	
	ocidUrlComponents's setUser:(";AUTH=NO USER AUTHENT")
	###ゲストユーザーで接続する場合
	##	ocidUrlComponents's setUser:("guest")
	##	ocidUrlComponents's setPassword:("guest")
else if strScheme is "smb" then
	ocidUrlComponents's setUser:("guest")
	ocidUrlComponents's setPassword:("guest")
end if
set ocidURL to ocidUrlComponents's |URL|()
###ゲスト用のURL
log (ocidUrlComponents's |string|()) as text
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
appShardWorkspace's openURL:(ocidURL)

return
