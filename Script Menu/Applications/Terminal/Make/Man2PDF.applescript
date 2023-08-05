#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# Acrobat PPD は
# https://quicktimer.cocolog-nifty.com/icefloe/2023/05/post-3e373c.html
# からどうぞ
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set strPPDsFilePath to ("/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Versions/A/Resources/Generic.ppd") as text

## set strPPDsFilePath to ("/Users/Shared/Library/Printers/PPDs/Contents/Resources/Acrobat/ADPDF9J.PPD") as text


##############################
#####ダイアログを前面に
##############################
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
##############################
#####クリップボードの内容取得
##############################
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to ocidPasteboard's types
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	set strReadString to (the clipboard as text)
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strReadString to ocidReadString as text
	else
		log "テキストなし"
		set strReadString to "COMMAND" as text
	end if
end if
set aliasIconPath to (POSIX file "/System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns") as alias
try
	set objResponse to (display dialog "コマンド名を入力してください" with title "入力してください" default answer strReadString buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 10 without hidden answer)
on error
	log "エラーしました"
	return "エラーしました"
	error number -128
end try
if true is equal to (gave up of objResponse) then
	return "時間切れですやりなおしてください"
	error number -128
end if
if "OK" is equal to (button returned of objResponse) then
	set theResponse to (text returned of objResponse) as text
else
	log "エラーしました"
	return "エラーしました"
	error number -128
end if

##############################
##  Save PS dir URL
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
### Make SaveDir
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###Save PS
set strFileName to (theResponse & ".ps") as text
set ocidPsFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
set strPsFilePath to ocidPsFilePathURL's |path|() as text

##############################
##  PS書き出して
set strCommandText to ("/usr/bin/man -t " & theResponse & " > \"" & strPsFilePath & "\"") as text
do shell script strCommandText

##############################
##PDF にする
####出力ファイル名
set strPdfFileName to (theResponse & ".pdf") as text
###デスクトップ
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirURL to ocidURLsArray's firstObject()
set strDesktopDirPath to ocidDesktopDirURL's |path|() as text
set ocidPdfFilePathURL to ocidDesktopDirURL's URLByAppendingPathComponent:(strPdfFileName)
###存在チェック
set boolFileExist to (ocidPdfFilePathURL's checkResourceIsReachableAndReturnError:(missing value)) as boolean
if boolFileExist is true then
	####日付情報の取得
	set ocidDate to refMe's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to refMe's NSDateFormatter's alloc()'s init()
	(ocidNSDateFormatter's setDateFormat:"yyyyMMdd-hhmm")
	set ocidDateAndTime to (ocidNSDateFormatter's stringFromDate:(ocidDate))
	set strDateAndTime to ocidDateAndTime as text
	####ファイル名に日付を入れる
	set strPdfFilePath to (strDesktopDirPath & "/" & strPdfFileName & "." & strDateAndTime & ".pdf") as text
else
	####出力ファイルパス
	set strPdfFilePath to (strDesktopDirPath & "/" & strPdfFileName & "") as text
end if

################################################
####コマンドパス	
set strBinPath to "/usr/sbin/cupsfilter"
#####コマンド整形
set strCommandText to ("\"" & strBinPath & "\" -f \"" & strPsFilePath & "\" -m \"application/pdf\" -p \"" & strPPDsFilePath & "\" -e -t \"" & theResponse & "\"  > \"" & strPdfFilePath & "\"")
####ターミナルで開く
tell application "Terminal"
	launch
	activate
	set objWindowID to (do script "\n\n")
	delay 1
	do script strCommandText in objWindowID
end tell
