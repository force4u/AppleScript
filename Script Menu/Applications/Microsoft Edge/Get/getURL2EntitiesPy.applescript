#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 　mobileconfig用
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
###アプリケーションのバンドルID
set strBundleID to "com.microsoft.edgemac"
###エラー処理
tell application id strBundleID
	set numWindow to (count of every window) as integer
end tell
if numWindow = 0 then
	return "Windowが無いので処理できません"
end if
###ダイアログの用意
set ocidAppPathURL to doGetAppPathURL(strBundleID)
set ocidIconFilePathURL to doGetIconPathURL(ocidAppPathURL)
set aliasIconFilePath to (ocidIconFilePathURL's absoluteURL()) as alias
###URLとタイトルを取得
tell application "Microsoft Edge"
	tell front window
		tell active tab
			activate
			set strURL to URL as text
			set strTITLE to title as text
		end tell
	end tell
end tell
################
set strDecodeURL to doHtmlEntities(strURL) as text
set strQrCodeURL to doGetQrcodeURL(strURL) as text

########################
## ダイアログ
########################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if

set strTITLE to ("リンクです") as text
set strMessage to ("リンクを生成しました") as text
set strDefaultAnswer to strDecodeURL as text
try
	set recordResponse to (display dialog strMessage with title strTITLE default answer strDefaultAnswer buttons {"QRコードを開く", "キャンセル", "クリップボードにコピー"} default button "QRコードを開く" cancel button "キャンセル" with icon aliasIconFilePath giving up after 20 without hidden answer) as record
on error strErrorMes number numErrorNO
	log strErrorMes
	log numErrorNO
	return (missing value)
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
else if false is equal to (recordResponse) then
	log "キャンセルしました"
	return "キャンセルしました"
else if "QRコードを開く" is equal to (button returned of recordResponse) then
	###
	tell application id strBundleID
		open location strQrCodeURL
	end tell
	
else if "クリップボードにコピー" is equal to (button returned of recordResponse) then
	try
		set strResponse to (text returned of recordResponse) as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strResponse))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strResponse as text
		end tell
	end try
else
	log "キャンセルしました"
	return (missing value)
end if

################################
## Entities
################################
on doHtmlEntitiesPy(argText)
	##エラーよけ
	set strHTMLText to doReplace(argText, "'", "&apos;")
	##クオトのエスケープ
	set strHTML to doReplace(strHTMLText, "\"", "\\\"")
	set strResponce to (do shell script "/usr/bin/python3 -c 'import html;[print(html.escape(\"" & strHTMLText & "\"))]'") as text
	return strResponce as text
end doHtmlEntitiesPy

################################
## 置換
################################
to doReplace(argOrignalText, argSearchText, argReplaceText)
	set strDelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to argSearchText
	set listDelim to every text item of argOrignalText
	set AppleScript's text item delimiters to argReplaceText
	set strReturn to listDelim as text
	set AppleScript's text item delimiters to strDelim
	return strReturn
end doReplace

################################
## Entities
################################
to doHtmlEntities(argHTML)
	###置換レコード
	##		set recordEntityMap to {|&|:"&amp;", |<|:"&lt;", |>|:"&gt;", |"|:"&quot;", |'|:"&apos;", |=|:"&#x3D;", |+|:"&#x2B;"} as record
	set recordEntityMap to {|&|:"&amp;"} as record
	###ディクショナリにして
	set ocidEntityMap to refMe's NSDictionary's alloc()'s initWithDictionary:(recordEntityMap)
	###キーの一覧を取り出します
	set ocidAllKeys to ocidEntityMap's allKeys()
	###選択中テキスト
	set ocidHTMLText to refMe's NSString's stringWithString:(argHTML)
	###可変テキストにして
	set ocidHtmlToEntities to refMe's NSMutableString's alloc()'s initWithCapacity:0
	ocidHtmlToEntities's setString:(ocidHTMLText)
	
	###取り出したキー一覧を順番に処理
	repeat with itemAllKey in ocidAllKeys
		##キーの値を取り出して
		set ocidMapValue to (ocidEntityMap's valueForKey:(itemAllKey))
		##置換
		set ocidHtmlToEntitiesText to (ocidHtmlToEntities's stringByReplacingOccurrencesOfString:(itemAllKey) withString:(ocidMapValue))
		##次の変換に備える
		set ocidHtmlToEntities to ocidHtmlToEntitiesText
	end repeat
	set strHtmlToEntities to ocidHtmlToEntities as text
	return strHtmlToEntities
end doHtmlEntities
################################
## Google QRコード
################################
to doGetQrcodeURL(argURL)
	###URL
	set strApiUrl to "https://chart.googleapis.com/chart?" as text
	set strCht to "qr" as text
	###サイズ
	set strChs to "540x540" as text
	set strChoe to "UTF-8" as text
	###クオリティ　L M Q R
	set strChld to "Q" as text
	set strQrUrl to ("" & strApiUrl & "&cht=" & strCht & "&chs=" & strChs & "&choe=" & strChoe & "&chld=" & strChld & "&chl=" & argURL & "") as text
	return strQrUrl
end doGetQrcodeURL

################################
## %エンコードをデコード
################################
on doUrlDecode(argText)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##デコード
	set ocidArgTextEncoded to ocidArgText's stringByRemovingPercentEncoding
	set strArgTextEncoded to ocidArgTextEncoded as text
	return strArgTextEncoded
end doUrlDecode


########################
## bundle to AppPathURL
########################
to doGetAppPathURL(argBundleiD)
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(argBundleiD))
	if ocidAppBundle ≠ (missing value) then
		set ocidAppPathURL to ocidAppBundle's bundleURL()
	else if ocidAppBundle = (missing value) then
		set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(argBundleiD))
	end if
	if ocidAppPathURL = (missing value) then
		tell application "Finder"
			try
				set aliasAppApth to (application file id strBundleID) as alias
			on error
				log "アプリケーションが見つかりませんでした"
				return (missing value)
			end try
		end tell
		set strAppPath to POSIX path of aliasAppApth as text
		set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
		set strAppPath to strAppPathStr's stringByStandardizingPath()
		set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true
	end if
	return ocidAppPathURL
end doGetAppPathURL


########################
## AppPathURL to AppIcon
########################
to doGetIconPathURL(argAppPathURL)
	###アイコン名をPLISTから取得
	set ocidPlistPathURL to argAppPathURL's URLByAppendingPathComponent:("Contents/Info.plist") isDirectory:false
	set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
	set strIconFileName to (ocidPlistDict's valueForKey:("CFBundleIconFile")) as text
	###ICONのURLにして
	set strPath to ("Contents/Resources/" & strIconFileName) as text
	set ocidIconFilePathURL to argAppPathURL's URLByAppendingPathComponent:(strPath) isDirectory:false
	###拡張子の有無チェック
	set strExtensionName to (ocidIconFilePathURL's pathExtension()) as text
	if strExtensionName is "" then
		set ocidIconFilePathURL to ocidIconFilePathURL's URLByAppendingPathExtension:"icns"
	end if
	###ICONファイルが実際にあるか？チェック
	set appFileManager to refMe's NSFileManager's defaultManager()
	set boolExists to appFileManager's fileExistsAtPath:(ocidIconFilePathURL's |path|)
	###ICONがみつかない時用にデフォルトを用意する
	if boolExists is false then
		set strIconPath to "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
		set ocidIconPathStr to refMe's NSString's stringWithString:(strIconPath)
		set ocidIconPath to ocidIconPathStr's stringByStandardizingPath()
		set ocidIconFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidIconPath) isDirectory:false)
	else
		return ocidIconFilePathURL
	end if
end doGetIconPathURL
