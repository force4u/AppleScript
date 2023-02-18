#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


set listChooser to {"com.apple.Safari", "com.google.Chrome", "com.microsoft.edgemac", "org.mozilla.firefox", "com.operasoftware.Opera", "com.vivaldi.Vivaldi", "com.brave.Browser", "org.chromium.Chromium"} as list

set listAppName to {"Safari", "Google Chrome", "Microsoft Edge", "Firefox", "Opera", "Vivaldi", "Brave Browser", "Chromium"} as list

try
	tell current application
		activate
		set listResponse to (choose from list listChooser with title "選んでください" with prompt "複数可" default items (item 1 of listChooser) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed and empty selection allowed) as list
	end tell
on error
	log "エラーしました"
	return "エラーしました"
	error "エラーしました" number -200
end try
if (count of listResponse) = 0 then
	log "選択無しの場合の処理"
	return "選択無し"
else if (item 1 of listResponse) is false then
	return "キャンセルしました"
	error "キャンセルしました" number -200
end if


tell application "Jedit Ω"
	tell front document
		set strFilePath to path as text
	end tell
end tell

#####パスのString
set ocidFilePathStr to (refMe's NSString's stringWithString:strFilePath)
#####パスにして
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
###URLに
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath
#####拡張子を取得
set ocidExtensionName to ocidFilePath's pathExtension()
#####小文字にして
set ocidExtensionNameLC to ocidExtensionName's lowercaseString()
####テキストで確定しておく
set strExtensionName to ocidExtensionNameLC as text

################################
######アプリケーションを指定して開く
################################

####拡張子がHTMLなら
if strExtensionName is "html" then
	repeat with itemResponse in listResponse
		####テキストで確定
		set strUTI to itemResponse as text
		####UTIからアプリケーションのパスを求める
		set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:strUTI)
		if ocidAppBundle is (missing value) then
			set numAppNo to doOffsetInList(strUTI, listChooser) as integer
			set strAppName to (item numAppNo of listAppName) as text
			####この方法は予備
			try
				set aliasAppPath to path to application strAppName as alias
			on error
				log "未インストールのアプリです"
				error "未インストールのアプリです" number -200
			end try
			set strAppBundlePath to POSIX path of aliasAppPath as text
			set ocidAppBundlePath to (refMe's NSString's stringWithString:strAppBundlePath)
		else
			set ocidAppBundlePath to ocidAppBundle's bundlePath()
		end if
		####アプリケーションのパスをURLに
		set ocidAppPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidAppBundlePath)
		###開くURLを格納用のArrayを作成して
		set ocidOpenURLArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
		###開くURLをArrayに格納
		(ocidOpenURLArray's addObject:ocidFilePathURL)
		####NSWorkspaceの初期化
		set objNSWorkspace to refMe's NSWorkspace's sharedWorkspace()
		####コンフィグレーション
		set ocidOpenConfiguration to refMe's NSWorkspaceOpenConfiguration's configuration()
		(ocidOpenConfiguration's setHides:(false as boolean))
		(ocidOpenConfiguration's setRequiresUniversalLinks:(false as boolean))
		####開く
		set boolResponse to (objNSWorkspace's openURLs:ocidOpenURLArray withApplicationAtURL:ocidAppPathURL configuration:ocidOpenConfiguration completionHandler:(missing value))
	end repeat
end if


################################
######リストの何番目？サブ
################################

to doOffsetInList(argText, argList)
	set numCntPosition to 1 as integer
	repeat with itemChooser in argList
		set strItemChooser to itemChooser as text
		if strItemChooser is argText then
			set numCntOffset to numCntPosition as integer
		end if
		set numCntPosition to numCntPosition + 1 as integer
	end repeat
	return numCntOffset
end doOffsetInList
