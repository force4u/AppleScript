#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
###NSPasteboardはAppkitなので必須
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


################################
######ペーストボード初期化
################################
set the clipboard to "" as text
##初期化
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
ocidPasteboard's clearContents()
delay 0.1
####パス取得を試みる
doCopyPathVsCode()
delay 0.1
################################
######ペーストボード取得
################################
##可変テキストとして受け取る
set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSMutableString}) options:(missing value)
##シングルARRAYが空ならペーストボードの中身が画像とか他のものなのでエラーで終了
if (count of ocidPasteboardArray) = 0 then
	delay 0.1
	###失敗したら再度トライ
	doCopyPathVsCode()
	delay 0.1
	set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSMutableString}) options:(missing value)
	###ペーストボードの中身をテキストで確定
	set strPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
else
	###ペーストボードの中身をテキストで確定
	set strPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
end if

if (strPasteboardStrings starts with "/") = false then
	###パスの取得に失敗したのでもう一度トライする
	delay 0.1
	####パス取得を試みる
	doCopyPathVsCode()
	delay 0.1
	set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSMutableString}) options:(missing value)
	###ペーストボードの中身をテキストで確定
	set strPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
end if

set ocidFilePathStr to refMe's NSString's stringWithString:(strPasteboardStrings)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
set listResult to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLContentTypeKey) |error|:(missing value))
if (item 1 of listResult) is false then
	return "取得に失敗しました"
else
	###UTTypeと言われたらこれ
	set ocidContentType to (item 2 of listResult)
	###これはUTIでUTTypeではない
	set ocidUTI to (ocidContentType's identifier)
	log ocidUTI as text
end if
################################
######パスを渡すことが可能なアプリのURL
################################
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidURLArray to appShardWorkspace's URLsForApplicationsToOpenContentType:(ocidContentType)
###ダイアログ用のアプリケーション名リスト
set listAppName to {} as list
###アプリケーションのURLを参照させるためのレコード
set ocidAppDictionary to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
repeat with itemURLArray in ocidURLArray
	###アプリケーションの名前
	set listResponse to (itemURLArray's getResourceValue:(reference) forKey:(refMe's NSURLNameKey) |error|:(missing value))
	set strAppName to (item 2 of listResponse) as text
	log "ブラウザの名前は：" & strAppName & "です"
	copy strAppName to end of listAppName
	set listSerArray to {} as list
	####パス
	set aliasAppPath to itemURLArray's absoluteURL() as alias
	log "ブラウザのパスは：" & aliasAppPath & "です"
	####バンドルID取得
	set ocidAppBunndle to (refMe's NSBundle's bundleWithURL:(itemURLArray))
	set ocidBunndleID to ocidAppBunndle's bundleIdentifier
	set strBundleID to ocidBunndleID as text
	set listSerArray to {itemURLArray, strBundleID} as list
	
	log "ブラウザのBunndleIDは：" & strBundleID & "です"
	(ocidAppDictionary's setObject:(listSerArray) forKey:(strAppName))
	
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
	set listResponse to (choose from list listAppName with title "選んでください" with prompt "URLを開くアプリケーションを選んでください" default items (item 1 of listAppName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed)
on error
	log "エラーしました"
	return "エラーしました"
end try
if listResponse is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text


################################
##URLを開く
################################
###アプリケーションのURLを取り出す
set listChooseApp to ocidAppDictionary's objectForKey:(strResponse)
log listChooseApp as list
set strOpenAppUTI to (item 2 of listChooseApp) as text
set aliasOpenFileURL to ocidFilePathURL's absoluteURL() as alias
###開く
tell application id strOpenAppUTI
	activate
	open file aliasOpenFileURL
end tell

(* この方法はうまくいかなかった
###オプション
ocidOpenConfiguration's setActivates:(true as boolean)
ocidOpenConfiguration's setHides:(false as boolean)
###開く
set ocidOpenURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidOpenURLArray's addObject:ocidFilePathURL
###openURLsはArrayで渡さないとクラッシュする
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
appShardWorkspace's openURLs:(ocidOpenURLArray) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfiguration) completionHandler:(missing value)
*)

return


################################
######パスコピーVScode
################################

to doCopyPathVsCode()
	###前面に出して
	tell application "System Events"
		launch
	end tell
	tell application "System Events"
		activate
	end tell
	tell application id "com.microsoft.VSCode"
		activate
	end tell
	delay 0.1
	###パス取得
	tell application "System Events"
		key down {command}
		keystroke "k"
		key up {command}
		delay 0.1
		key down {option, command}
		keystroke "c"
		key up {option, command}
	end tell
	
end doCopyPathVsCode
