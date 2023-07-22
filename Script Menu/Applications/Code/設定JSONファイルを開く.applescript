#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

########################
### 開くファイル
########################
set strFilePath to "~/Library/Application Support/Code/User/settings.json"
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false
########################
###処理分岐
########################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		set aliasFilePathURL to ocidFilePathURL as alias
		set aliasAppPath to path to application "Visual Studio Code" as alias
		activate
		open aliasFilePathURL using aliasAppPath
	end tell
else
	tell current application
		activate
	end tell
end if
##########################################
###なにもわざわざNSWorkspace使う事もなかろうに
##########################################

###ワークスペース初期化
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()

###オープンするアプリケーションのUTI
set strBundleID to "com.microsoft.VSCode" as text
###バンドル取得
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
###アプリケーションのパスURLを取る
if ocidAppBundle is not (missing value) then
	set ocidAppBundlePath to ocidAppBundle's bundlePath()
	set ocidAppPath to ocidAppBundlePath's stringByStandardizingPath
	set ocidAppBundlePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAppPath) isDirectory:false
else
	set ocidAppBundlePathURL to appShardWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
end if
#####オープンコンフィク
set ocidOpenConfiguration to refMe's NSWorkspaceOpenConfiguration's configuration()
ocidOpenConfiguration's setHides:(refMe's NSNumber's numberWithBool:false)
ocidOpenConfiguration's setHidesOthers:(refMe's NSNumber's numberWithBool:false)
ocidOpenConfiguration's setRequiresUniversalLinks:(refMe's NSNumber's numberWithBool:false)
ocidOpenConfiguration's setActivates:(refMe's NSNumber's numberWithBool:true)
ocidOpenConfiguration's setForPrinting:(refMe's NSNumber's numberWithBool:false)
ocidOpenConfiguration's setAddsToRecentItems:(refMe's NSNumber's numberWithBool:false)
ocidOpenConfiguration's setCreatesNewApplicationInstance:(refMe's NSNumber's numberWithBool:false)
####URLをArrayに入れて
set ocidOpenURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidOpenURLArray's addObject:(ocidFilePathURL)
####開く
appShardWorkspace's openURLs:(ocidOpenURLArray) withApplicationAtURL:(ocidAppBundlePathURL) configuration:(ocidOpenConfiguration) completionHandler:(missing value)
#####終了
return



