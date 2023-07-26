#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
https://quicktimer.cocolog-nifty.com/icefloe/2023/06/post-f91978.html
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

###アプリケーションのバンドルID
set strChkBundleID to "com.microsoft.edgemac"


#########################
tell application id strChkBundleID
	set numCntWindow to (count of every window) as integer
end tell
###Safariのウィンドウが無いならダイアログを出す
if numCntWindow < 1 then
	##デフォルトクリップボードから
	set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
	try
		set ocidPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
	on error
		set ocidPasteboardStrings to "" as text
	end try
	set strDefaultAnswer to ocidPasteboardStrings as text
	################################
	######ダイアログ
	################################
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
	set aliasIconPath to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns") as alias
	try
		set recordResponse to (display dialog "URLをペーストしてください" with title "入力してください" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	if true is equal to (gave up of recordResponse) then
		return "時間切れですやりなおしてください"
	end if
	if "OK" is equal to (button returned of recordResponse) then
		set strURL to (text returned of recordResponse) as text
	else
		log "キャンセルしました"
		return "キャンセルしました"
	end if
	
	
else
	tell application "Microsoft Edge"
		tell front window
			tell active tab
				set strURL to URL as text
				set strTITLE to title as text
			end tell
		end tell
	end tell
end if




###設定項目ドキュメントのURL
set strScheme to "https://" as text
###NSURL
set ocidScheme to refMe's NSURL's URLWithString:(strScheme)
###ワークスペース初期化
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
###URLタイプのデフォルトアプリケーション
set ocidAppURLArray to appShardWorkspace's URLsForApplicationsToOpenURL:(ocidScheme)

###ダイアログ用のアプリケーション名リスト
set listAppName to {} as list
###アプリケーションのURLを参照させるためのレコード
set ocidBrowserDictionary to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
####################################################
####httpがスキームとして利用可能なアプリケーション一覧を取得する
####################################################
repeat with itemAppPathURL in ocidAppURLArray
	###アプリケーションの名前
	set listResponse to (itemAppPathURL's getResourceValue:(reference) forKey:(refMe's NSURLNameKey) |error|:(missing value))
	set strAppName to (item 2 of listResponse) as text
	log "ブラウザの名前は：" & strAppName & "です"
	copy strAppName to end of listAppName
	####パス
	set aliasAppPath to itemAppPathURL's absoluteURL() as alias
	log "ブラウザのパスは：" & aliasAppPath & "です"
	####バンドルID取得
	set ocidAppBunndle to (refMe's NSBundle's bundleWithURL:(itemAppPathURL))
	set ocidBunndleID to ocidAppBunndle's bundleIdentifier
	set strBundleID to ocidBunndleID as text
	log "ブラウザのBunndleIDは：" & strBundleID & "です"
	(ocidBrowserDictionary's setObject:(ocidBunndleID) forKey:(strAppName))
end repeat
################################
##ダイアログ
################################
###ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
try
	set listResponse to (choose from list listAppName with title "選んでください" with prompt "URLを開くアプリケーションを選んでください" default items (item 1 of listAppName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
	
end if
set strResponse to (item 1 of listResponse) as text

################################
##アプリケーションのバンドルID
################################
###アプリケーションのURLを取り出す
set ocidOpenBundleID to ocidBrowserDictionary's valueForKey:(strResponse)
set strOpenBunndleID to ocidOpenBundleID as text

################################
## OPEN
################################
tell application id strOpenBunndleID
	open location strURL
end tell

