#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#	留意事項　検索条件は上書きされます
#	前面ウィンドウのパスで拡張子検索
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

##########################################
####【１】設定項目　拡張子リスト

set strBundleID to ("com.linearity.vn") as text

set listExList to {"curve", "vectornator", "sketch", "pdf", "jpg", "jpeg", "png", "gif", "ai", "psd", "svg"} as list

set listExecUTI to {"com.bohemiancoding.sketch.drawing", "public.svg-image", "com.vladidanila.vectornator", "com.adobe.pdf", "com.adobe.illustrator.ai-image", "public.png", "public.jpeg", "public.heic", "public.tiff", "org.webmproject.webp"} as list

set appFileManager to refMe's NSFileManager's defaultManager()
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()

##########################################
###デフォルトロケーション
set ocidForDirArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidForDirArray's firstObject()
set aliasDefaultLocation to (ocidDesktopPathURL's absoluteURL()) as alias
set strMes to ("イメージファイルを選んでください") as text
set strPrompt to ("イメージファイルを選んでください") as text

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
set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listExecUTI with invisibles without showing package contents and multiple selections allowed) as alias

set strFilePath to (POSIX path of aliasFilePath) as text
####ドキュメントのパスをNSString
set ocidFilePath to refMe's NSString's stringWithString:(strFilePath)
####ドキュメントのパスをNSURLに
set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath)
###Arrayにしておく
set ocidFilePathArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
ocidFilePathArray's addObject:(ocidFilePathURL)

##########################################
#### アプリケーションの起動
set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
if ocidAppBundle ≠ (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else if ocidAppBundle = (missing value) then
	set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
end if
if ocidAppPathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
		on error
			return "アプリケーションが見つかりませんでした"
		end try
	end tell
	set strAppPath to POSIX path of aliasAppApth as text
	set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
	set strAppPath to strAppPathStr's stringByStandardizingPath()
	set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true
end if
##############################
#####とりあえず起動
set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration()
#	(ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true))
(ocidOpenConfig's setActivates:(true))
###openApplicationAtURL はrun script  とか　log とか activate 応答を求める必要がある？
#	log (appSharedWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value))
#	 run script (appSharedWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value))
activate (appSharedWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value))
##############################
#####
if strName is "osascript" then
	tell application id strBundleID
		activate
		open aliasFilePath
	end tell
else
	activate (appSharedWorkspace's openURLs:(ocidFilePathArray) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value))
end if




