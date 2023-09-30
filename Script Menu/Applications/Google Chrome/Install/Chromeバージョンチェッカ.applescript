#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

#################################
##
set strBundleID to "com.google.Chrome" as text
set strLocation to ("https://dl.google.com/dl/chrome/mac/universal/stable/gcea/googlechrome.dmg")

#################################
### element & node
set ocidRootElement to refMe's NSXMLElement's alloc()'s initWithName:("request")
set ocidNode to refMe's NSXMLNode's attributeWithName:("protocol") stringValue:("3.0")
ocidRootElement's addAttribute:(ocidNode)
set ocidNode to refMe's NSXMLNode's attributeWithName:("ismachine") stringValue:("1")
ocidRootElement's addAttribute:(ocidNode)
##
set ocidOsElement to refMe's NSXMLElement's elementWithName:("os")
set ocidNode to refMe's NSXMLNode's attributeWithName:("platform") stringValue:("mac")
ocidOsElement's addAttribute:(ocidNode)
set ocidNode to refMe's NSXMLNode's attributeWithName:("os_version") stringValue:("14.0")
ocidOsElement's addAttribute:(ocidNode)
set ocidNode to refMe's NSXMLNode's attributeWithName:("version") stringValue:("14.0")
ocidOsElement's addAttribute:(ocidNode)
set ocidNode to refMe's NSXMLNode's attributeWithName:("arch") stringValue:("arm")
ocidOsElement's addAttribute:(ocidNode)
##
set ocidAppElement to refMe's NSXMLElement's elementWithName:("app")
set ocidNode to refMe's NSXMLNode's attributeWithName:("appid") stringValue:(strBundleID)
ocidAppElement's addAttribute:(ocidNode)
set ocidNode to refMe's NSXMLNode's attributeWithName:("brand") stringValue:("gcea")
ocidAppElement's addAttribute:(ocidNode)
##
set ocidUpdateCheckElement to (refMe's NSXMLElement's elementWithName:("updatecheck"))
ocidAppElement's insertChild:(ocidUpdateCheckElement) atIndex:0
##
ocidRootElement's addChild:(ocidOsElement)
ocidRootElement's addChild:(ocidAppElement)

#################################
###NSXMLDocument を生成する
set ocidOutPutXML to refMe's NSXMLDocument's alloc()'s initWithRootElement:(ocidRootElement)
ocidOutPutXML's setVersion:"1.0"
ocidOutPutXML's setCharacterEncoding:"UTF-8"

set ocidSaveStrings to ocidOutPutXML's XMLString()
set strOutPutXML to ocidSaveStrings as text

#################################
##XML内のクオテーションをエスケープ
set strXML4Command to doReplace(strOutPutXML, "\"", "\\\"")
##コマンド整形
set strCommandText to ("/usr/bin/curl -X POST -d \"" & strXML4Command & "\" https://tools.google.com/service/update2") as text
log strCommandText
##コマンド実行
set strResponseXML to (do shell script strCommandText) as text

#################################
##戻り値XML
set ocidResponseXML to refMe's NSString's stringWithString:(strResponseXML)
set ocidXMLdata to ocidResponseXML's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
###NSXMLDocument's
set listXMLdoc to refMe's NSXMLDocument's alloc()'s initWithData:(ocidXMLdata) options:(0) |error|:(reference)
set ocidReadXMLDoc to (item 1 of listXMLdoc)
##rootElement
set ocidRootElement to ocidReadXMLDoc's rootElement()
set listManifest to ocidRootElement's nodesForXPath:("//response/app/updatecheck/manifest") |error|:(reference)
##NSXMLElement
set ocidManifest to (item 1 of listManifest)'s firstObject()
set strNewVersion to (ocidManifest's attributeForName:("version"))'s stringValue() as text


################################
###バンドルIDからアプリケーションのインストール先を求める
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
if ocidAppBundle is missing value then
	set appNSWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set ocidAppBundlePathURL to (appNSWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
else
	set ocidAppBundleStr to ocidAppBundle's bundlePath()
	set ocidAppBundlePath to ocidAppBundleStr's stringByStandardizingPath
	set ocidAppBundlePathURL to (refMe's NSURL's fileURLWithPath:(ocidAppBundlePath))
end if
if ocidAppBundlePathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
		on error
			return "アプリケーションが見つかりませんでした"
		end try
	end tell
	set strAppPath to POSIX path of aliasAppApth as text
	set ocidAppBundlePathStr to refMe's NSString's stringWithString:(strAppPath)
	set ocidAppBundlePath to ocidAppBundlePathStr's stringByStandardizingPath()
	set ocidAppBundlePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAppBundlePath) isDirectory:true
end if
###コマンドのあるディレクトリ
set ocidPlistPathURL to ocidAppBundlePathURL's URLByAppendingPathComponent:("Contents/Info.plist")
#####PLISTの内容を読み込んで
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set listReadPlistData to refMe's NSMutableDictionary's dictionaryWithContentsOfURL:(ocidPlistPathURL) |error|:(reference)
set ocidPlistDict to item 1 of listReadPlistData
set strCfbundleversionPlist to (ocidPlistDict's valueForKey:"CFBundleShortVersionString") as text
################################################
###### 	
if strNewVersion is strCfbundleversionPlist then
	set strTitle to ("最新版を利用中です") as text
	set strCom to ("最新版を利用中です\r" & strCfbundleversionPlist) as text
	set strMes to strCom
else
	set strTitle to ("アップデートがあります：" & strNewVersion) as text
	set strCom to ("アップデートがあります\r最新：" & strNewVersion & "\r使用中：" & strCfbundleversionPlist) as text
	set strMes to strCom
end if
################################################
###### ダイアログ
################################################
set appFileManager to refMe's NSFileManager's defaultManager()

####ダイアログに指定アプリのアイコンを表示する
###アイコン名をPLISTから取得
set strIconFileName to (ocidPlistDict's valueForKey:("CFBundleIconFile")) as text
###ICONのURLにして
set strPath to ("Contents/Resources/" & strIconFileName) as text
set ocidIconFilePathURL to ocidAppBundlePathURL's URLByAppendingPathComponent:(strPath) isDirectory:false
###拡張子の有無チェック
set strExtensionName to (ocidIconFilePathURL's pathExtension()) as text
if strExtensionName is "" then
	set ocidIconFilePathURL to ocidIconFilePathURL's URLByAppendingPathExtension:"icns"
end if
##-->これがアイコンパス
log ocidIconFilePathURL's absoluteString() as text
###ICONファイルが実際にあるか？チェック
set boolExists to appFileManager's fileExistsAtPath:(ocidIconFilePathURL's |path|)
###ICONがみつかない時用にデフォルトを用意する
if boolExists is false then
	set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
else
	set aliasIconPath to ocidIconFilePathURL's absoluteURL() as alias
	set strIconPath to ocidIconFilePathURL's |path|() as text
end if

set recordResult to (display dialog strCom with title strTitle default answer strMes buttons {"クリップボードにコピー", "終了", "ダウンロード"} default button "ダウンロード" cancel button "終了" giving up after 20 with icon aliasIconPath without hidden answer)

if button returned of recordResult is "ダウンロード" then
	tell application "Finder"
		open location strLocation
	end tell
end if
if button returned of recordResult is "クリップボードにコピー" then
	try
		set strText to text returned of recordResult as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strTitle as text
		end tell
	end try
end if


#################################
##クオテーションの置換用
to doReplace(argOrignalText, argSearchText, argReplaceText)
	set strDelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to argSearchText
	set listDelim to every text item of argOrignalText
	set AppleScript's text item delimiters to argReplaceText
	set strReturn to listDelim as text
	set AppleScript's text item delimiters to strDelim
	return strReturn
end doReplace
