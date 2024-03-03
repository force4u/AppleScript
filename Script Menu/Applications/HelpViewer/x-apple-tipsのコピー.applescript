#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

set strBundleID to "com.apple.helpviewer" as text

set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
##バンドルからアプリケーションのURLを取得
set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
if ocidAppBundle ≠ (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else if ocidAppBundle = (missing value) then
	set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
end if
##予備（アプリケーションのURL）
if ocidAppPathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
			set strAppPath to POSIX path of aliasAppApth as text
			set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
			set strAppPath to strAppPathStr's stringByStandardizingPath()
			set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
		on error
			return "アプリケーションが見つかりませんでした"
		end try
	end tell
end if

##ワークスペースに渡すURLのリスト
set ocidOpenUrlArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0

##com.apple.preferences.configurationprofilesのURL
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("help")
#	ocidURLComponents's setScheme:("x-apple-helpbasic")
#	ocidURLComponents's setScheme:("x-apple-tips")
#	ocidURLComponents's setScheme:("com.apple.ActivityMonitor.help")

#	ocidURLComponents's setScheme:("x-help-action")
#	ocidURLComponents's setPath:("openApp")
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("bundleId") value:("com.apple.ActivityMonitor.help")
#	ocidURLComponents's setQueryItems:({ocidQueryItem})
set ocidOpenURL to ocidURLComponents's |URL|
set strPanelURL to (ocidOpenURL's absoluteString()) as text

##URLリストに追加
ocidOpenUrlArray's insertObject:(ocidOpenURL) atIndex:0
##OPENコンフィグ　アクティベートのみ設定
set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true)
## システム設定でプロファイルのURLを開く
##これでも良いし
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()

appShardWorkspace's openURLs:(ocidOpenUrlArray) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)
##こっちでも同じ
appShardWorkspace's openURL:(ocidOpenURL)

