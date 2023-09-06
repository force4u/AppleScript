#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "CoreImage"
use scripting additions

property refMe : a reference to current application

set objFileManager to refMe's NSFileManager's defaultManager()

###################################
#####ダイアログ
###################################
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###ダイアログのデフォルト
set ocidUserDesktopPath to (objFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set aliasDefaultLocation to ocidUserDesktopPath as alias
set listChooseFileUTI to {"public.image"}
set strPromptText to "QRコードファイルを選んでください" as text
set listAliasFilePath to (choose file with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with invisibles and showing package contents without multiple selections allowed) as list
###################################
#####パス処理
###################################
###エリアス
set aliasFilePath to item 1 of listAliasFilePath as alias
###UNIXパス
set strFilePath to POSIX path of aliasFilePath as text
###String
set ocidFilePath to refMe's NSString's stringWithString:strFilePath
###NSURL
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false
####ファイル名を取得
set ocidFileName to ocidFilePathURL's lastPathComponent()
####拡張子を取得
set ocidFileExtension to ocidFilePathURL's pathExtension()
####ファイル名から拡張子を取っていわゆるベースファイル名を取得
set ocidPrefixName to ocidFileName's stringByDeletingPathExtension
####コンテナ
set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()


###################################
#####　QRコードイメージファイル読み込み　
###################################
####CIイメージに読み込み
set ocidCiImageInput to (refMe's CIImage's imageWithContentsOfURL:(ocidFilePathURL) options:(missing value))
########################
####CIDetectorを定義 	CIDetectorTypeQRCode
set ocidDetector to refMe's CIDetector's detectorOfType:(refMe's CIDetectorTypeQRCode) context:(missing value) options:{CIDetectorAccuracy:(refMe's CIDetectorAccuracyHigh)}
#####ocidDetectorを通して結果をArrayに格納
set ocidFeaturesArray to ocidDetector's featuresInImage:(ocidCiImageInput)
if (count of ocidFeaturesArray) = 0 then
	return "読み取り不良"
end if
####messageString格納用のArray
set ocidOutPutArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
####Featuresの数だけ繰り返し
repeat with itemFeaturesArray in ocidFeaturesArray
	#####読み取り結果のテキスト messageString
	log itemFeaturesArray's type() as text
	log className() of itemFeaturesArray as text
	log itemFeaturesArray's |bounds|() as list
	set ocidMessageString to itemFeaturesArray's messageString()
	(ocidOutPutArrayM's addObject:(ocidMessageString))
end repeat
####複数見つかった場合はエラーで止める
if (ocidOutPutArrayM's |count|()) > 1 then
	return "読み取り結果が複数見つかりました"
else
	set ocidQRdecodeText to ocidOutPutArrayM's firstObject()
	set strQRdecodeText to ocidQRdecodeText as text
end if
log strQRdecodeText
###################################
#####　読み取り結果整形
###################################
if strQRdecodeText starts with "BEGIN:VCARD" then
	
	###拡張子
	set strFileExtension to "vcf" as text
	###ダイアログに出すファイル名
	set strDefaultName to ("VCARD" & "." & strFileExtension) as text
else if strQRdecodeText starts with "BEGIN:VEVENT" then
	set strQRdecodeText to "BEGIN:VCALENDAR\n" & strQRdecodeText & "\nEND:VCALENDAR" as text
	###拡張子
	set strFileExtension to "ics" as text
	###ダイアログに出すファイル名
	set strDefaultName to ("VEVENT" & "." & strFileExtension) as text
else if strQRdecodeText starts with "BEGIN:VCALENDAR" then
	
	
	###拡張子
	set strFileExtension to "ics" as text
	###ダイアログに出すファイル名
	set strDefaultName to ("VCALENDAR" & "." & strFileExtension) as text
else
	return "読み取り不良 バーコードが見つかりません"
end if


###################################
#####　ダイアログ
###################################
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
set aliasIconPath to POSIX file "/System/Applications/Preview.app/Contents/Resources/AppIcon.icns" as alias

try
	set recordResponse to (display dialog "コピーしてください" with title "QRコード読み取り結果" default answer strQRdecodeText buttons {"クリップボードにコピー", "終了", "ファイル出力"} default button "ファイル出力" cancel button "終了" with icon aliasIconPath giving up after 30 without hidden answer)
	
on error
	log "エラーしました"
	return "エラーしました"
	error number -128
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
	error number -128
end if

if "終了" is equal to (button returned of recordResponse) then
	return "処理終了"
else if button returned of recordResponse is "クリップボードにコピー" then
	try
		set strText to text returned of recordResponse as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
		return "処理終了"
	on error
		tell application "Finder"
			set the clipboard to strText as text
		end tell
		return "エラーしました"
	end try
	
end if

###################################
#####保存ダイアログ
###################################
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

set strPromptText to "名前を決めてください"
###選んだファイルの同階層をデフォルト
set aliasDefaultLocation to ocidContainerDirPathURL as alias
####ファイル名ダイアログ
####実在しない『はず』なのでas «class furl»で
set aliasSaveFilePath to (choose file name default location aliasDefaultLocation default name strDefaultName with prompt strPromptText) as «class furl»
####UNIXパス
set strSaveFilePath to POSIX path of aliasSaveFilePath as text
####ドキュメントのパスをNSString
set ocidSaveFilePath to refMe's NSString's stringWithString:strSaveFilePath
####ドキュメントのパスをNSURLに
set ocidSaveFilePathURL to refMe's NSURL's fileURLWithPath:ocidSaveFilePath
###拡張子取得
set strFileExtensionName to ocidSaveFilePathURL's pathExtension() as text
###ダイアログで拡張子を取っちゃった時対策
if strFileExtensionName is not strFileExtension then
	set ocidSaveFilePathURL to ocidSaveFilePathURL's URLByAppendingPathExtension:(strFileExtension)
end if

###################################
#####　ファイルに書き出し
###################################
set ocidContents to refMe's NSString's stringWithString:(strQRdecodeText)

set listDone to (ocidContents's writeToURL:(ocidSaveFilePathURL) atomically:false encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))

#####################
### Finderで保存先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's selectFile:(ocidSaveFilePathURL's |path|()) inFileViewerRootedAtPath:(ocidContainerDirPathURL's |path|())



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

