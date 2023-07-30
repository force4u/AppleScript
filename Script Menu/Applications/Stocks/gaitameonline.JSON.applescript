#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#20230731作成
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

##########################################
###【１】URLをNSURL
set strURL to "http://www.gaitameonline.com/rateaj/getrate" as text
set ocidURLString to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)

##########################################
###【２】URLのコンテンツ（応答）をNSDATAに
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidURL) options:(refMe's NSDataReadingMappedIfSafe) |error|:(reference)
set coidReadData to item 1 of listReadData

##########################################
### 【３】JSON初期化
set listJSONSerialization to (refMe's NSJSONSerialization's JSONObjectWithData:(coidReadData) options:(refMe's NSJSONReadingMutableContainers) |error|:(reference))
set ocidJsonData to item 1 of listJSONSerialization
##########################################
####【４】アクセスした日時を取得しておく
set strDateNo to doGetDateNo("yyyy/MM/dd-hh:mm:ss")

##########################################
####【５】レコードに格納 (実際はここで色々処理したりデータ取得したりします)
set ocidJsonDict to refMe's NSDictionary's alloc()'s initWithDictionary:(ocidJsonData)
set ocidAllKeys to ocidJsonDict's allKeys()
--> quotes
##########################################
####【６】quotesのValue＝ARRAYを取得
set ocidJsonArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
ocidJsonArrayM's addObjectsFromArray:(ocidJsonData's objectForKey:(ocidAllKeys's firstObject()))

##########################################
####【７】Arrayの数だけ繰り返し
###ダイアログ用のリスト
set ocidDialogueArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
###quotesの数だけ繰り返し
repeat with itemJsonArrayM in ocidJsonArrayM
	set ocidQuotesDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidQuotesDict's setDictionary:(itemJsonArrayM))
	set ocidAllKeys to ocidQuotesDict's allKeys()
	##	log ocidAllKeys as list
	--> (*low, high, currencyPairCode, open, bid, ask*)
	###ペアコードを格納する
	set strPairCode to (ocidQuotesDict's valueForKey:("currencyPairCode")) as text
	(ocidDialogueArrayM's addObject:(strPairCode))
end repeat



##########################################
####【８】ダイアログ
###ABC順に並び替える
set ocidDescriptor to (refMe's NSSortDescriptor's sortDescriptorWithKey:("self") ascending:(true) selector:"localizedStandardCompare:")
ocidDialogueArrayM's sortUsingDescriptors:{ocidDescriptor}
set listDialogueArrayM to ocidDialogueArrayM as list

tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	###ダイアログを前面に出す
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
try
	set listResponse to (choose from list listDialogueArrayM with title "選んでください" with prompt "ペアコードを選んでください" default items (item 23 of listDialogueArrayM) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if

set strResponse to (item 1 of listResponse) as text

##########################################
####【８】情報を取得整理する

###quotesの数だけ繰り返し
repeat with itemJsonArrayM in ocidJsonArrayM
	set ocidQuotesDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidQuotesDict's setDictionary:(itemJsonArrayM))
	set ocidAllKeys to ocidQuotesDict's allKeys()
	###ペアコードを格納する
	set strPairCode to (ocidQuotesDict's valueForKey:("currencyPairCode")) as text
	if strPairCode is strResponse then
		set strlow to (ocidQuotesDict's valueForKey:("low"))
		set strhigh to (ocidQuotesDict's valueForKey:("high"))
		set stropen to (ocidQuotesDict's valueForKey:("open"))
		set strbid to (ocidQuotesDict's valueForKey:("bid"))
		set strask to (ocidQuotesDict's valueForKey:("ask"))
	end if
end repeat
set strMes to ("為替レート" & strResponse & "：" & strDateNo & "\r売値：" & strbid & "\r買値：" & strask & "") as text
set strDialogueText to ("為替レート" & strResponse & "：" & strDateNo & "\r売値：" & strbid & "\r買値：" & strask & "\r\r開始：" & stropen & "\r最高値：" & strhigh & "\r最安値：" & strlow & "") as text

##########################################
####【９】ダイアログに表示する
set strBundleID to ("com.apple.stocks") as text
####スクリプトメニューから実行したら
if strName is "osascript" then
	###ダイアログを前面に出す
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if

###ICON
set aliasIconPath to POSIX file "/System/Applications/Stocks.app/Contents/Resources/AppIcon.icns"

set strTitle to ("為替レート" & strResponse) as text

set recordResult to (display dialog strMes with title strTitle default answer strDialogueText buttons {"クリップボードにコピー", "中止", "再実行"} default button "再実行" cancel button "中止" giving up after 20 with icon aliasIconPath without hidden answer)

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
###自分自身を再実行
if button returned of recordResult is "再実行" then
	tell application "Finder"
		set aliasPathToMe to (path to me) as alias
	end tell
	run script aliasPathToMe
end if


##########################################
####日付のサブ
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
