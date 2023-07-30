#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
##
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

##ファイル名
set strFileName to doGetDateNo("yyyyMMddhhmmss")
set strFileName to (strFileName & ".applescript") as text
set strDateNO to doGetDateNo("yyyyMMdd")

set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirURL to ocidURLsArray's firstObject()
set ocidSaveFilePathURL to ocidDesktopDirURL's URLByAppendingPathComponent:(strFileName)

#################################
###ダイアログ用に値を用意
#################################
set strScript to "#!/usr/bin/env osascript\r----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\r#com.cocolog-nifty.quicktimer.icefloe\r#" & strDateNO & "作成\r----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\ruse AppleScript version \"2.8\"\ruse framework \"Foundation\"\ruse framework \"AppKit\"\ruse scripting additions\r\rproperty refMe : a reference to current application\r\r\r"
#################################
###【３】ダイアログを前面に
#################################
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###ダイアログ
set strIconPath to ("/System/Applications/Utilities/Script Editor.app/Contents/Resources/AppIcon.icns") as text
set aliasIconPath to (POSIX file strIconPath) as alias
set recordResult to (display dialog "スクリプト戻り値です" with title "スクリプト" default answer strScript buttons {"クリップボードにコピー", "キャンセル", "スクリプトエディタで開く"} default button "スクリプトエディタで開く" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)
###クリップボードにコピー
if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if


###OK押したらスクリプト生成
if button returned of recordResult is "スクリプトエディタで開く" then
	###スクリプトをテキストで保存
	set ocidScript to refMe's NSString's stringWithString:(strScript)
	set listDone to ocidScript's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF16LittleEndianStringEncoding) |error|:(reference)
	delay 0.5
	set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
	###保存したスクリプトを開く
	tell application "Script Editor"
		open aliasSaveFilePath
	end tell
end if


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
