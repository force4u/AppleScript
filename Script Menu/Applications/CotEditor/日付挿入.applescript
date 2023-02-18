#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
property refNSDate : a reference to refMe's NSDate
property refNSCalendar : a reference to refMe's NSCalendar
property refNSTimeZone : a reference to refMe's NSTimeZone
property refNSDateFormatter : a reference to NSDateFormatter

###日付フォーマットは<http://nsdateformatter.com>参照
set listDateFormat to {"AD yyyyMMdd", "AD yyyy年MM月dd日", "AD yyyy年MM月dd日EEEE", "AD Gyyyy年MM月dd日EEEE", "JE yyMMdd", "JE Gyyyy年MM月dd日", "JE Gyyyy年MM月dd日 EEEE", "MMM.dd,yyyy", "EEEE MMMM dd yyyy"} as list

##############################
#### 選択範囲のテキストを取得
##############################
tell application "CotEditor"
	activate
	set numCntActvDoc to (count of document) as integer
	if numCntActvDoc = 0 then
		return "ドキュメントがありません"
	end if
	tell front document
		set strSelectionContents to contents of selection
	end tell
end tell
set strChkText to strSelectionContents as text

############################
####ダイアログを出す
############################
try
	tell current application
		activate
		set listResponse to (choose from list listDateFormat with title "選んでください" with prompt "日付フォーマット" default items (item 1 of listDateFormat) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
	end tell
on error
	log "エラーしました"
	return "エラーしました"
	error "エラーしました" number -200
end try

if (item 1 of listResponse) is false then
	return "キャンセルしました"
	error "キャンセルしました" number -200
end if
############################
####戻り値が複数選択の本処理
############################
###ペーストボードに戻すテキストの初期化
set strOutPutText to "" as text
###繰り返し
repeat with itemResponse in listResponse
	####テキストで確定
	set strResponse to itemResponse as text
	####戻り値の最初がADから始まる場合は
	if strResponse starts with "AD" then
		set strDateFormat to doReplace(strResponse, "AD ", "")
		####英語モード書式での日付を取得
		set strDateText to doGetDateNo(strDateFormat) as text
	else if strResponse starts with "JE" then
		####戻り値の最初がJEから始まる場合は
		set strDateFormat to doReplace(strResponse, "JE ", "")
		####日本語モード書式での日付を取得
		set strDateText to doGetDateNoJP(strDateFormat) as text
	else
		###無印は英語モード
		set strDateText to doGetDateNo(strResponse) as text
	end if
	####戻り値
	set strOutPutText to strDateText & "" as text
end repeat
############################
####日本語書式
############################

if strChkText is "" then
	tell application "CotEditor"
		tell front document
			properties
			set contents of selection to strOutPutText
		end tell
	end tell
else
	tell application "CotEditor"
		tell front document
			properties
			set contents of selection to strOutPutText & strSelectionContents
		end tell
	end tell
end if


############################
####日本語書式
############################
to doGetDateNoJP(strDateFormat)
	####日付情報の取得
	set ocidDate to refNSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to refNSDateFormatter's alloc()'s init()
	set ocidJPCalendar to refNSCalendar's alloc()'s initWithCalendarIdentifier:(refMe's NSCalendarIdentifierJapanese)
	set ocidNStimezoneJP to refNSTimeZone's alloc()'s initWithName:"Asia/Tokyo"
	ocidNSDateFormatter's setTimeZone:ocidNStimezoneJP
	ocidNSDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"ja_JP")
	ocidNSDateFormatter's setCalendar:ocidJPCalendar
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNoJP

############################
####英語書式
############################
to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to refNSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to refNSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"en_US")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo

############################
####文字の置換
############################
to doReplace(argOrignalText, argSearchText, argReplaceText)
	set ocidOrignalText to refMe's NSString's stringWithString:argOrignalText
	set ocidReplasetText to ocidOrignalText's stringByReplacingOccurrencesOfString:argSearchText withString:argReplaceText
	set strReplasetText to ocidReplasetText as text
	return strReplasetText
end doReplace
