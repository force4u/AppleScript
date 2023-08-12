#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 　favicon.ico　アイコンイメージ付きのWEBLOCファイルを作成する
# 作成途中　いちおう動作はする　エラーになる場合もある…
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

#########################
tell application "Safari"
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
		set recordResponse to (display dialog "詳しく" with title "入力してください" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	if true is equal to (gave up of recordResponse) then
		return "時間切れですやりなおしてください"
	end if
	if "OK" is equal to (button returned of recordResponse) then
		set strResponse to (text returned of recordResponse) as text
	else
		log "キャンセルしました"
		return "キャンセルしました"
	end if
	tell application "Safari"
		open location strResponse
		####タイトル　と　URLを取得
		every document
		set numWindowID to id of front window
		tell window id numWindowID
			set objCurrentTab to current tab
			tell objCurrentTab
				set strURL to URL
				set strName to name
			end tell
		end tell
	end tell
else
	tell application "Safari"
		####タイトル　と　URLを取得
		every document
		set numWindowID to id of front window
		tell window id numWindowID
			set objCurrentTab to current tab
			tell objCurrentTab
				set strURL to URL
				set strName to name
			end tell
		end tell
	end tell
end if
#########################
##URL
set strURL to strURL as text
set ocidURLString to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
set ocidHostName to ocidURL's |host|()
set strURL to ocidURL's absoluteString() as text
##保存先
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirURL to ocidURLsArray's firstObject()
set ocidSafariDirPathURL to ocidDocumentDirURL's URLByAppendingPathComponent:("Safari/Webloc/")
set ocidSaveDirPathURL to ocidSafariDirPathURL's URLByAppendingPathComponent:(ocidHostName)
##フォルダ作る
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set aliasSaveDirPathURL to (ocidSaveDirPathURL's absoluteURL()) as alias
#########################
##保存ファイル名

try
	####WEBページのタイトルを１０文字で取得
	set strFileName to (ocidURL's lastPathComponent()) as text
	
	if strFileName = "" then
		set strFileName to ocidHostName as text
	else if strFileName = "/" then
		set strFileName to ocidHostName as text
	end if
on error
	####１０文字以下の場合はホスト名にする
	set strFileName to ocidHostName as text
end try
set strWeblocFileName to (strFileName & ".webloc") as text
set strUrlFileName to (strFileName & ".url") as text
#########################
##保存先パス
set ocidWeblocFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strWeblocFileName)
set ocidUrlFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strUrlFileName)
#########################
##WEBLOC　内容
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(strURL) forKey:("URL")
ocidPlistDict's setValue:(strName) forKey:("title")
set strDateno to doGetDateNo("yyyyMMdd")
ocidPlistDict's setValue:(strDateno) forKey:("version")
ocidPlistDict's setValue:(strDateno) forKey:("productVersion")
##これは自分用
ocidPlistDict's setValue:(strDateno) forKey:("kMDItemFSCreationDate")

#########################
####weblocファイルを作る
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistEditData to item 1 of listPlistEditDataArray
set boolWritetoUrlArray to ocidPlistEditData's writeToURL:(ocidWeblocFilePathURL) options:0 |error|:(reference)
(*
tell application "Finder"
	make new internet location file to strURL at aliasSaveDirPathURL with properties {name:"" & strName & "", creator type:"MACS", stationery:false, location:strURL}
end tell
*)
#########################
####URLファイルを作る
set strShortCutFileString to ("[InternetShortcut]\r\nURL=" & strURL & "\r\n") as text
set ocidShortCutFileString to refMe's NSMutableString's alloc()'s initWithCapacity:0
ocidShortCutFileString's setString:(strShortCutFileString)
##保存
set boolDone to ocidShortCutFileString's writeToURL:(ocidUrlFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)


#################################
###URLからFaviconの存在を確認する
#################################
set ocidURLString to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
set ocidHostName to ocidURL's |host|()
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("https")
ocidURLComponents's setHost:(ocidHostName)
ocidURLComponents's setPath:("/favicon.ico")
set ocidFaviconURL to ocidURLComponents's |URL|()
log ocidFaviconURL's absoluteString() as text

set ocidURLRequest to refMe's NSMutableURLRequest's requestWithURL:(ocidFaviconURL)
ocidURLRequest's setHTTPMethod:"GET"

set listResponse to refMe's NSURLConnection's sendSynchronousRequest:(ocidURLRequest) returningResponse:(reference) |error|:(reference)

log className() of item 1 of listResponse as text
set ocidHTTPURLResponse to (item 2 of listResponse)
set strStatusCode to ocidHTTPURLResponse's statusCode() as text
log strStatusCode
if strStatusCode = "200" then
	################################
	### アイコンデータ取得
	################################
	set ocidIconData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidFaviconURL))
	
	#########################
	####アイコン付与
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set boolAddIcon to appSharedWorkspace's setIcon:(ocidIconData) forFile:(ocidUrlFilePathURL's |path|) options:(refMe's NSExclude10_4ElementsIconCreationOption)
	set boolAddIcon to appSharedWorkspace's setIcon:(ocidIconData) forFile:(ocidWeblocFilePathURL's |path|) options:(refMe's NSExclude10_4ElementsIconCreationOption)
end if


#########################
####保存先を開く
tell application "Finder"
	set aliasSaveFile to (folder aliasSaveDirPathURL) as alias
	set refNewWindow to make new Finder window
	tell refNewWindow
		set position to {10, 30}
		set bounds to {10, 30, 720, 480}
	end tell
	set target of refNewWindow to aliasSaveDirPathURL
	set selection to aliasSaveFile
end tell

#########################
####バージョンで使う日付
to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
