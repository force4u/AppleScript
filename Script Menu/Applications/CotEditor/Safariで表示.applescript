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

####設定項目
##UTI
set strUTI to "com.apple.Safari" as text
###APP名
set strAppName to "Safari" as text


tell application "CotEditor"
	set numCntActvDoc to (count of document) as integer
	if numCntActvDoc = 0 then
		return "ドキュメントがありません"
	end if
	tell front document
		log "処理開始"
	end tell
	set aliasFilePath to (file of front document) as alias
end tell
set strFilePath to POSIX path of aliasFilePath as text

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

####拡張子がHTMLなら
if strExtensionName is "html" then
	####UTIからアプリケーションのパスを求める
	set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:strUTI
	if ocidAppBundle is (missing value) then
		####この方法は予備
		set aliasAppPath to path to application strAppName as alias
		set strAppBundlePath to POSIX path of aliasAppPath as text
		set ocidAppBundlePath to (refMe's NSString's stringWithString:strAppBundlePath)
	else
		set ocidAppBundlePath to ocidAppBundle's bundlePath()
	end if
	####アプリケーションのパスをURLに
	set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidAppBundlePath
	log ocidAppPathURL's |path| as text
	
	###開くURLを格納用のArrayを作成して
	set ocidOpenURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
	###開くURLをArrayに格納
	ocidOpenURLArray's addObject:ocidFilePathURL
	
	####NSWorkspaceの初期化
	set objNSWorkspace to refMe's NSWorkspace's sharedWorkspace()
	####コンフィグレーション
	set ocidOpenConfiguration to refMe's NSWorkspaceOpenConfiguration's configuration()
	ocidOpenConfiguration's setHides:(false as boolean)
	ocidOpenConfiguration's setRequiresUniversalLinks:(false as boolean)
	####開く
	###objNSWorkspace's openURLs:ocidOpenURLArray withApplicationAtURL:ocidAppPathURL configuration:ocidOpenConfiguration completionHandler:(missing value)
	#####
	set aliasAppPathURL to ocidAppPathURL as alias
	set aliasFilePathURL to ocidFilePathURL as alias
	tell application "Finder"
		open file aliasFilePathURL using aliasAppPathURL
	end tell
	
end if

