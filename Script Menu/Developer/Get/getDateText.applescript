#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


set appFileManager to refMe's NSFileManager's defaultManager()

####ICONがキャッシュされているか？確認
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSCachesDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidCachesURL to ocidURLsArray's firstObject()
###キャッシュディレクトリ
set ocidSaveDirPathURL to ocidCachesURL's URLByAppendingPathComponent:("com.cocolog-nifty.quicktimer")
###ダウンロードするURLから
set strIconURL to "https://raw.githubusercontent.com/force4u/AppleScript/main/Script%20Menu/Applications/Calendar/Icon/Calendar.icns" as text
###ファイル名を取得して
set ocidURL to refMe's NSURL's URLWithString:(strIconURL)
set ocidFileName to ocidURL's lastPathComponent()
###保存先のURLにしておく
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidFileName)
set ocidSaveFilePath to ocidSaveFilePathURL's |path|
set boolFileExsists to appFileManager's fileExistsAtPath:(ocidSaveFilePath)
####ICONがキャッシュされていなければダウンロード
if boolFileExsists is false then
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 777-->511 755-->493 700-->448 766-->502 
	ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	set listIconData to refMe's NSData's dataWithContentsOfURL:(ocidURL) options:(refMe's NSDataReadingMappedIfSafe) |error|:(reference)
	if (item 1 of listIconData) = (missing value) then
		###ダウンロードに失敗したのでデフォルトで別のICONを用意
		set strIconPath to "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Clock.icns" as text
		set aliasIconPath to (POSIX file strIconPath) as alias
	else
		set ocidIconData to item 1 of listIconData
		set listDone to ocidIconData's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference)
		set aliasIconPath to (ocidSaveFilePathURL's absoluteURL()) as alias
	end if
end if


##ダイアログ用のArray
set ocidArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
###今日
set ocidDate to refMe's NSDate's |date|()
####################################
###フォーマット初期化日本語
####################################
set ocidFormatterJP to refMe's NSDateFormatter's alloc()'s init()
set ocidCalendarJP to refMe's NSCalendar's alloc()'s initWithCalendarIdentifier:(refMe's NSCalendarIdentifierJapanese)
set ocidTimezoneJP to refMe's NSTimeZone's alloc()'s initWithName:("Asia/Tokyo")
set ocidLocaleJP to refMe's NSLocale's alloc()'s initWithLocaleIdentifier:("ja_JP_POSIX")
###フォーマットをセット
ocidFormatterJP's setTimeZone:(ocidTimezoneJP)
ocidFormatterJP's setLocale:(ocidLocaleJP)
ocidFormatterJP's setCalendar:(ocidCalendarJP)
ocidFormatterJP's setDateFormat:("Gyy")
###今日の日付にフォーマットを適応
set ocidDateStringEra to ocidFormatterJP's stringFromDate:(ocidDate)
ocidFormatterJP's setDateFormat:("年MM月dd日")
set ocidDateString to ocidFormatterJP's stringFromDate:(ocidDate)
ocidArrayM's addObject:((ocidDateStringEra as text) & (ocidDateString as text))
###フォーマットをセット
ocidFormatterJP's setTimeZone:(ocidTimezoneJP)
ocidFormatterJP's setLocale:(ocidLocaleJP)
ocidFormatterJP's setCalendar:(ocidCalendarJP)
ocidFormatterJP's setDateFormat:("Gyy")
###今日の日付にフォーマットを適応
set ocidDateStringEra to ocidFormatterJP's stringFromDate:(ocidDate)
ocidFormatterJP's setDateFormat:("年MM月dd日EEEE")
set ocidDateString to ocidFormatterJP's stringFromDate:(ocidDate)
ocidArrayM's addObject:((ocidDateStringEra as text) & (ocidDateString as text))
####################################
###フォーマット初期化通常
####################################
set ocidFormatter to refMe's NSDateFormatter's alloc()'s init()
ocidFormatter's setTimeStyle:(refMe's NSDateFormatterNoStyle)
##
ocidFormatter's setDateStyle:(refMe's NSDateFormatterLongStyle)
set ocidDateString to ocidFormatter's stringFromDate:(ocidDate)
ocidArrayM's addObject:(ocidDateString)
##
ocidFormatter's setDateStyle:(refMe's NSDateFormatterShortStyle)
set ocidDateString to ocidFormatter's stringFromDate:(ocidDate)
ocidArrayM's addObject:(ocidDateString)
##
ocidFormatter's setDateFormat:("yyyyMMdd")
set ocidDateString to ocidFormatter's stringFromDate:(ocidDate)
ocidArrayM's addObject:(ocidDateString)
##
ocidFormatter's setDateFormat:("yyyy年MM月dd日EEEE")
set ocidDateString to ocidFormatter's stringFromDate:(ocidDate)
ocidArrayM's addObject:(ocidDateString)
###########ダイアログ用にリストに
set listDate to ocidArrayM as list
###ダイアログを前面に出す
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
	set listResponse to (choose from list listDate with title "選んでください" with prompt "クリップボードにコピーします" default items (item 1 of listDate) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
else
	set strText to (item 1 of listResponse) as text
end if


set recordResult to (display dialog "date の戻り値です" with title "UUID gen" default answer strText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 20 with icon aliasIconPath without hidden answer)

if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if
