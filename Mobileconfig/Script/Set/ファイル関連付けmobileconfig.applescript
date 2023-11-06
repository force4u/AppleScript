#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 他のスクリプトの流用なのでちょっと面倒な処理になっています
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###設定項目 ファイルタイプUTI
set strUTI to "com.apple.mobileconfig" as text

###UTTypに変換
set ocidUTType to refMe's UTType's typeWithIdentifier:(strUTI)
###ワークスペース初期化
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
###UTTypeタイプのデフォルトアプリケーション
set ocidAppPathURL to appShardWorkspace's URLsForApplicationsToOpenContentType:(ocidUTType)

################################################
###起動ボリュームにあるURLのみにする
###URL格納用の可変ARRAY
set ocidChooseArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidChooseArray's setArray:ocidAppPathURL
###収集したURLの個数
set numCntArray to count of ocidAppPathURL
###収集したURLから外部ボリュームのものを削除
###起動ボリュームの名前
set strFilePath to "/System/Library/CoreServices/Finder.app" as text
set ocidFinderFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFinderFilePath to ocidFinderFilePathStr's stringByStandardizingPath()
set ocidFinderFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFinderFilePath) isDirectory:false)
set listVolumeNameKey to (ocidFinderFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLVolumeNameKey) |error|:(reference))
set strVolumeName to (item 2 of listVolumeNameKey) as text
####収集したURLの数だけ繰り返し
repeat numCntArray times
	###Arrayの削除なので後ろから処理
	set itemAppPathURL to ocidChooseArray's objectAtIndex:(numCntArray - 1)
	###ボリューム名を取得して
	set listPathVolumeName to (itemAppPathURL's getResourceValue:(reference) forKey:(refMe's NSURLVolumeNameKey) |error|:(reference))
	set strPathVolumeName to (item 2 of listPathVolumeName) as text
	###外部ボリュームのものは削除
	if strPathVolumeName is "Preboot" then
		log strPathVolumeName
	else if strPathVolumeName is not strVolumeName then
		ocidChooseArray's removeObjectAtIndex:(numCntArray - 1)
	end if
	set numCntArray to numCntArray - 1
end repeat

set strOpenContentPath to (item 1 of ocidChooseArray)'s |path| as text

if strOpenContentPath contains "ProfileHelper.app" then
	return "設定変更必要ありません"
end if

################################
##アプリケーションのURLを取得する
################################
set ocidAppPath to "/System/Library/CoreServices/ProfileHelper.app" as text
set ocidAppPathStr to refMe's NSString's stringWithString:(ocidAppPath)
set ocidAppPath to ocidAppPathStr's stringByStandardizingPath()
set ocidAppPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAppPath) isDirectory:false)

###選んだアプリケーションのバンドルID
set ocidAppBunndle to (refMe's NSBundle's bundleWithURL:(ocidAppPathURL))
set ocidBunndleID to ocidAppBunndle's bundleIdentifier
###IF用にテキストにしておく
set strBunndleID to ocidBunndleID as text
## com.apple.mcx.ProfileHelper
log strBunndleID

################################
##デフォルトに設定する
################################
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
appShardWorkspace's setDefaultApplicationAtURL:(ocidAppPathURL) toOpenContentType:(ocidUTType) completionHandler:(missing value)


################################
##設定後に 値の確定
################################

set strFilePath to "~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
### PLISTを読み込む
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL)
###LSHandlers Array
set ocidLSHandlersArray to ocidPlistDict's objectForKey:"LSHandlers"
###項目数の数だけ繰り返し
repeat with itemLSHandlers in ocidLSHandlersArray
	###コンテンツタイプを取得して
	set ocidLSHandlerContentType to (itemLSHandlers's valueForKey:"LSHandlerContentType")
	###設定項目のコンテンツタイプと同じなら
	set strLSHandlerContentType to ocidLSHandlerContentType as text
	if strLSHandlerContentType is strUTI then
		###変更前の値
		set ocidRoleViewer to (itemLSHandlers's valueForKey:"LSHandlerRoleViewer")
		set ocidRoleAll to (itemLSHandlers's valueForKey:"LSHandlerRoleAll")
		set ocidRoleAll to (itemLSHandlers's valueForKey:"LSHandlerRoleEditor")
		set ocidRoleShell to (itemLSHandlers's valueForKey:"LSHandlerRoleShell")
		log ocidRoleViewer as text
		log ocidRoleAll as text
		log ocidRoleAll as text
		log ocidRoleShell as text
		####値を変更する
		(itemLSHandlers's setValue:(strBunndleID) forKey:"LSHandlerRoleViewer")
		(itemLSHandlers's setValue:(strBunndleID) forKey:"LSHandlerRoleAll")
		(itemLSHandlers's setValue:(strBunndleID) forKey:"LSHandlerRoleEditor")
		(itemLSHandlers's setValue:(strBunndleID) forKey:"LSHandlerRoleShell")
		####変更後の値
		log (itemLSHandlers's valueForKey:"LSHandlerRoleViewer") as text
		log (itemLSHandlers's valueForKey:"LSHandlerRoleAll") as text
		log (itemLSHandlers's valueForKey:"LSHandlerRoleEditor") as text
		log (itemLSHandlers's valueForKey:"LSHandlerRoleShell") as text
	end if
	
end repeat
###保存
set boolDone to ocidPlistDict's writeToURL:(ocidFilePathURL) atomically:true
log boolDone as boolean


#############################
###CFPreferencesを再起動
#############################
#####CFPreferencesを再起動させて変更後の値をロードさせる
set strCommandText to "/usr/bin/killall cfprefsd" as text
do shell script strCommandText


#############################
###LaunchServicesを再起動
#############################
####lsregister初期化
(*#色々やってみたが不具合の方が多いので停止
set strCommandText to "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -seed" as text
do shell script strCommandText
*)
