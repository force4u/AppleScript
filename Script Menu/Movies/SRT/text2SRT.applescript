#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#　テキストファイルを字幕用のSRTファイル形式に変換します
(*
DaVinci Resolveのタイムコード形式　カンマ区切りの
01:00:00,000 をやめて
一般的な形式の
01:00:00.000　に変更しました
DaVinci Resolveへの読み込みもOKです

*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

########################
##設定項目
########################
##時間を01:00:00.000でスタートする場合は１
set numStartH to 0 as integer
###カウントアップ値（１０分の１秒）　
#例＝3.0だと行毎で３秒間隔で作成
set numTimeInterval to 3.0 as number

########################
##時間の初期化
########################
set ocidDateComponents to refMe's NSDateComponents's alloc()'s init()
##時間を１でスタートする場合は１
ocidDateComponents's setHour:(numStartH)
ocidDateComponents's setMinute:(0)
ocidDateComponents's setSecond:(0)
###カレンダー初期化
set ocidCalendar to refMe's NSCalendar's currentCalendar()
###↑の時間をセット
set ocidTime to ocidCalendar's dateFromComponents:(ocidDateComponents)
###日付時間の書式設定
set ocidDateFormatter to refMe's NSDateFormatter's alloc()'s init()
(ocidDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"en_US"))
##一般的なフォーマット
(ocidDateFormatter's setDateFormat:"HH:mm:ss.SSS")
##DaVinci Resolve式のカンマ区切り
#(ocidDateFormatter's setDateFormat:"HH:mm:ss,SSS")
########################
##ダイアログ
########################
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
#
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
#
set listUTI to {"public.text"} as list
set strMes to ("ファイルを選んでください") as text
set strPrompt to ("ファイルを選んでください") as text
try
	set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
#入力パス
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
#出力パス
set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
set ocidSaveFilePathURL to ocidBaseFilePathURL's URLByAppendingPathExtension:("srt")
########################
##テキスト処理
########################
#テキスト読み込み
set listResponse to refMe's NSMutableString's alloc()'s initWithContentsOfURL:(ocidFilePathURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "initWithContentsOfURL 正常処理"
	set ocidReadString to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	log (item 2 of listResponse)'s code() as text
	log (item 2 of listResponse)'s localizedDescription() as text
	return "initWithContentsOfURL　エラーしました"
end if
#改行コードをUNIXに強制
set ocidReplacedStrings to (ocidReadString's stringByReplacingOccurrencesOfString:("\r\n") withString:("\n"))
set ocidReplacedStrings to (ocidReplacedStrings's stringByReplacingOccurrencesOfString:("\r") withString:("\n"))
#空行削除しないなら↓この行を削除
set ocidReplacedStrings to (ocidReplacedStrings's stringByReplacingOccurrencesOfString:("\n\n") withString:("\n"))
#改行区切りでリストに
set ocidLineTextArray to ocidReplacedStrings's componentsSeparatedByString:("\n")
#リストの数
set numCntArray to (ocidLineTextArray's |count|()) as integer
########################
##本処理
########################
#出力用のテキスト
set ocidOutPutString to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
#読み込んだテキストの行数だけ繰り返し
repeat with itemNo from 0 to (numCntArray - 1) by 1
	#SRT用のカウント
	set strLineNo to (itemNo + 1) as text
	(ocidOutPutString's appendString:(strLineNo))
	(ocidOutPutString's appendString:("\n"))
	###時間を書式でテキスト化　開始時間
	set ocidStartStrings to (ocidDateFormatter's stringFromDate:(ocidTime))
	#出力用テキストにセット
	(ocidOutPutString's appendString:(ocidStartStrings))
	(ocidOutPutString's appendString:(" --> "))
	###タイムインターバルをセット
	set ocidNewTime to (ocidTime's dateByAddingTimeInterval:(numTimeInterval))
	###インターバル分追加した時間をテキストにして　終了時間
	set ocidEndStrings to (ocidDateFormatter's stringFromDate:(ocidNewTime))
	#出力用テキストにセット
	(ocidOutPutString's appendString:(ocidEndStrings))
	(ocidOutPutString's appendString:("\n"))
	##加算された時間を次のリピートの開始時間とするためにセット
	set ocidTime to ocidNewTime
	##リストから対象の行のテキスト読み込み
	set ocidLineText to (ocidLineTextArray's objectAtIndex:(itemNo))
	#出力用テキストにセット
	(ocidOutPutString's appendString:(ocidLineText))
	(ocidOutPutString's appendString:("\n"))
	(ocidOutPutString's appendString:("\n"))
end repeat
########################
##保存
########################
set listDone to (ocidOutPutString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
if (item 1 of listDone) is true then
	return "writeToURL　正常終了"
else if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s code() as text
	log (item 2 of listDone)'s localizedDescription() as text
	return "writeToURL　エラーしました"
end if









