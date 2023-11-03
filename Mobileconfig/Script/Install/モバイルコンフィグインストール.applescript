#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#登録にはNSWorkspaceを利用
#macOS14対応
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application


###システム設定はいちど終了させる（macOS14対策）
tell application id "com.apple.systempreferences" to quit

####ダイアログで使うデフォルトロケーション
tell application "Finder"
	set aliasDefaultLocation to (path to documents folder from user domain) as alias
end tell

####UTIリスト PDFのみ
set listUTI to {"com.apple.mobileconfig"}

set strMes to ("モバイルコンフィグファイルを選んでください") as text
set strPrompt to ("モバイルコンフィグファイルを選んでください") as text

####ダイアログを出す
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
set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
###パス
set strFilePath to POSIX path of aliasFilePath
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

###起動はさせておく
tell application id "com.apple.systempreferences" to activate
tell application id "com.apple.systempreferences"
	activate
	reveal anchor "Main" of pane id "com.apple.Profiles-Settings.extension"
end tell

###FinderのURL
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set strBundleID to "com.apple.finder" as text
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
if ocidAppBundle is not (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else
	set ocidAppPathURL to appShardWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
end if
###パネルのURL
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("x-apple.systempreferences")
ocidURLComponents's setPath:("com.apple.preferences.configurationprofiles")
set ocidOpenAppURL to ocidURLComponents's |URL|
###ファイルURLとパネルのURLをArrayにしておく
set ocidOpenUrlArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidOpenUrlArray's insertObject:(ocidFilePathURL) atIndex:0
ocidOpenUrlArray's insertObject:(ocidOpenAppURL) atIndex:1
###FinderでファイルとURLを同時に開く
set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true)
appShardWorkspace's openURLs:({ocidFilePathURL, ocidOpenAppURL}) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)
###システム設定を前面に
set ocidRunningApp to refMe's NSRunningApplication
set ocidAppArray to (ocidRunningApp's runningApplicationsWithBundleIdentifier:("com.apple.systempreferences"))
set ocidApp to ocidAppArray's firstObject()
ocidApp's active