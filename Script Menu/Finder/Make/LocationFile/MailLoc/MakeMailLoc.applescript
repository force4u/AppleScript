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


##デフォルトクリップボードから
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
try
	set ocidPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
on error
	set ocidPasteboardStrings to "" as text
end try
set strDefaultAnswer to ocidPasteboardStrings as text
if strDefaultAnswer contains "@" then
	set strEmailAdd to strDefaultAnswer as text
else
	set strEmailAdd to "foo@hoge.com"
end if


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
	set recordResponse to (display dialog "メールアドレスを入力してください" with title "メールアドレスを入力してください" default answer strEmailAdd buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
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

if strResponse contains "@" then
	set strEmailAdd to strResponse as text
else
	return "エラーEmailアドレス専用です"
end if
###タブと改行の除去
set ocidEmailAdd to refMe's NSString's stringWithString:(strEmailAdd)
set ocidEmailAddM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidEmailAddM's appendString:(ocidEmailAdd)
##行末の改行
set ocidEmailAddM to ocidEmailAddM's stringByReplacingOccurrencesOfString:("\n") withString:("")
set ocidEmailAddM to ocidEmailAddM's stringByReplacingOccurrencesOfString:("\r") withString:("")
##タブ除去
set ocidEmailAddM to ocidEmailAddM's stringByReplacingOccurrencesOfString:("\t") withString:("")
set strEmailAdd to ocidEmailAddM as text
##ファイル名
set strFileName to (strEmailAdd & ".mailloc") as text
##############################
## 保存先ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidDocumentDirPathURL's URLByAppendingPathComponent:("Contacts.localized") isDirectory:(true)
##ディレクトリ作成
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
####localizedフォルダ
set ocidLocalizedDirPathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:".localized"
####フォルダを作る
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
set listlResults to appFileManager's createDirectoryAtURL:(ocidLocalizedDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
####localized strings PLIST作成
set ocidLocalizedFilePathURL to ocidLocalizedDirPathURL's URLByAppendingPathComponent:"ja.strings"
set strEnName to "Contacts" as text
set strJpName to "連絡先" as text
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setObject:strJpName forKey:strEnName
set ocidPlistFormat to refMe's NSPropertyListBinaryFormat_v1_0
set ocidPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidPlistFormat) options:0 |error|:(reference)
set ocidPlistEditData to item 1 of ocidPlistEditDataArray
set listlResults to ocidPlistEditData's writeToURL:ocidLocalizedFilePathURL options:0 |error|:(reference)
##保存ファイルパス
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:(false)
set aliasSaveDirPath to (ocidSaveDirPathURL's absoluteURL()) as alias
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
#########################
##############################
## PLIST maillocを作成
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###mailto
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("mailto")
ocidURLComponents's setPath:(strEmailAdd)
###PLISTにセットする値
set ocidMailToURL to ocidURLComponents's |URL|
set ocidMailToURLStr to (ocidMailToURL's absoluteString())
ocidPlistDict's setValue:(ocidMailToURLStr) forKey:"URL"
set strDateno to doGetDateNo("yyyyMMdd")
ocidPlistDict's setValue:(strDateno) forKey:("version")
ocidPlistDict's setValue:(strDateno) forKey:("productVersion")
##これは自分用
ocidPlistDict's setValue:(strDateno) forKey:("kMDItemFSCreationDate")
#########################
####weblocファイルを作る
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistData to item 1 of listPlistEditDataArray
set boolWritetoUrlArray to ocidPlistData's writeToURL:(ocidSaveFilePathURL) options:0 |error|:(reference)
(*
tell application "Finder"
	make new internet location file to strURL at aliasSaveDirPathURL with properties {name:"" & strName & "", creator type:"MACS", stationery:false, location:strURL}
end tell
*)
#########################

####保存先を開く
tell application "Finder"
	set aliasSaveFile to (file strFileName of folder aliasSaveDirPath) as alias
	set refNewWindow to make new Finder window
	tell refNewWindow
		set position to {10, 30}
		set bounds to {10, 30, 720, 480}
	end tell
	set target of refNewWindow to aliasSaveDirPath
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




