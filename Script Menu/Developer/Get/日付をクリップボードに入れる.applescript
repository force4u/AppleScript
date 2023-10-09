#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
###日付フォーマットは都合で増やしてね
set recordDateFormat to {|西暦2023年08月03日木曜日|:"GGyyyy年MM月dd日EEEE", |西暦2023年08月03日|:"GGyyyy年MM月dd日", |2023年08月03日木曜日|:"GGyyyy年MM月dd日EEEE", |2023年08月03日|:"GGyyyy年MM月dd日", |令和5年08月03日木曜日|:"GGyy年MM月dd日EEEE", |令和5年08月03日|:"GGyy年MM月dd日", |20230803|:"yyyyMMdd", |2023:08:03|:"yyyy:MM:dd", |2023/08/03|:"yyyy/MM/dd", |2023-08-03|:"yyyy-MM-dd"} as record
###
set ocidDateFormatDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidDateFormatDict's setDictionary:(recordDateFormat)
###↑のDICTのキーリストを取得
set ocidAllKeyArray to ocidDateFormatDict's allKeys()
###並び替える
set ocidDescriptor to refMe's NSSortDescriptor's sortDescriptorWithKey:("self") ascending:(true) selector:("localizedStandardCompare:")
set ocidDescriptorArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
ocidDescriptorArray's addObject:(ocidDescriptor)
set ocidSortedKey to (ocidAllKeyArray's sortedArrayUsingDescriptors:(ocidDescriptorArray))
###ダイアログ用にリスト
set listAllKeyArray to ocidSortedKey as list
###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listAllKeyArray with title "選んでください" with prompt "日付フォーマット選択" default items (item 6 of listAllKeyArray) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set theResponse to (item 1 of listResponse) as text
##戻り値からレコードにきいてフォーマットを取得
set ocidFormat to ocidDateFormatDict's valueForKey:(theResponse)
set strFormat to ocidFormat as text
###年号が４桁なら西暦な分岐
if strFormat contains "yyyy" then
	set strDateText to doGetDateNo({strFormat, 1})
else
	set strDateText to doGetDateNo({strFormat, 2})
end if

try
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strDateText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
on error
	tell application "Finder"
		set the clipboard to strTitle as text
	end tell
end try

################################
# 和暦ゼロサプレス
################################
################################
# 日付 doGetDateNo(argDateFormat,argCalendarNO)
# argCalendarNO 1 NSCalendarIdentifierGregorian 西暦
# argCalendarNO 2 NSCalendarIdentifierJapanese 和暦
################################
to doGetDateNo({argDateFormat, argCalendarNO})
	##渡された値をテキストで確定させて
	set strDateFormat to argDateFormat as text
	set intCalendarNO to argCalendarNO as integer
	###日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義（日本語）
	set ocidFormatterJP to current application's NSDateFormatter's alloc()'s init()
	###和暦　西暦　カレンダー分岐
	if intCalendarNO = 1 then
		set ocidCalendarID to (current application's NSCalendarIdentifierGregorian)
	else if intCalendarNO = 2 then
		set ocidCalendarID to (current application's NSCalendarIdentifierJapanese)
	else
		set ocidCalendarID to (current application's NSCalendarIdentifierISO8601)
	end if
	set ocidCalendarJP to current application's NSCalendar's alloc()'s initWithCalendarIdentifier:(ocidCalendarID)
	set ocidTimezoneJP to current application's NSTimeZone's alloc()'s initWithName:("Asia/Tokyo")
	set ocidLocaleJP to current application's NSLocale's alloc()'s initWithLocaleIdentifier:("ja_JP_POSIX")
	###設定
	ocidFormatterJP's setTimeZone:(ocidTimezoneJP)
	ocidFormatterJP's setLocale:(ocidLocaleJP)
	ocidFormatterJP's setCalendar:(ocidCalendarJP)
	# ocidFormatterJP's setDateStyle:(current application's NSDateFormatterNoStyle)
	# ocidFormatterJP's setDateStyle:(current application's NSDateFormatterShortStyle)
	# ocidFormatterJP's setDateStyle:(current application's NSDateFormatterMediumStyle)
	# ocidFormatterJP's setDateStyle:(current application's NSDateFormatterLongStyle)
	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterFullStyle)
	###渡された値でフォーマット定義
	ocidFormatterJP's setDateFormat:(strDateFormat)
	###フォーマット適応
	set ocidDateAndTime to ocidFormatterJP's stringFromDate:(ocidDate)
	###テキストで戻す
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
