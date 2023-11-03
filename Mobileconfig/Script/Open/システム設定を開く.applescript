#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# NSWorkspace版
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()

###システム設定のバンドルID
set strBundleID to "com.apple.systempreferences" as text
###システム設定のNSBundle
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
if ocidAppBundle is not (missing value) then
	###URLを取得
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else
	###URLを取得
	set ocidAppPathURL to appShardWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
end if
##ワークスペースに渡すURLのリスト
set ocidOpenUrlArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
##com.apple.preferences.configurationprofilesのURL
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("x-apple.systempreferences")
ocidURLComponents's setPath:("com.apple.preferences.configurationprofiles")
set ocidOpenURL to ocidURLComponents's |URL|
set strPanelURL to (ocidOpenURL's absoluteString()) as text
##URLリストに追加
ocidOpenUrlArray's insertObject:(ocidOpenURL) atIndex:0
##OPENコンフィグ　アクティベートのみ設定
set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true)
## システム設定でプロファイルのURLを開く
##これでも良いし
appShardWorkspace's openURLs:(ocidOpenUrlArray) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)
##こっちでも同じ
appShardWorkspace's openURL:(ocidOpenURL)
