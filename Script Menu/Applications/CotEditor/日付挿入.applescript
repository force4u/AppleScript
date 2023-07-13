#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


##############################
#### 選択範囲のテキストを取得
##############################
tell application "CotEditor"
	set numCntActvDoc to (count of document) as integer
	if numCntActvDoc = 0 then
		return "ドキュメントがありません"
	end if
	tell front document
		set strSelectionContents to contents of selection
	end tell
end tell
set strChkText to strSelectionContents as text

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


############################
####
############################

tell application "CotEditor"
	tell front document
		properties
		set contents of selection to strChkText & strText
	end tell
end tell


