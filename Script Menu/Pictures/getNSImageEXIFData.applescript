#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

##############################
###入力ダイアログ
##############################
set ocidForDirArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidForDirArray's firstObject()
set aliasDefaultLocation to (ocidDesktopPathURL's absoluteURL()) as alias
####UTIリスト PDFのみ
set listUTI to {"public.image", "public.tiff", "public.jpeg", "public.png"} as list
set strMes to ("イメージファイルを選んでください") as text
set strPrompt to ("イメージファイルを選んでください") as text
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
set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias

##############################
###本処理
##############################
###パス
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
###イメージデータ読み込み
set ocidImageRep to (refMe's NSBitmapImageRep's imageRepWithContentsOfURL:(ocidFilePathURL))
###プロパティからNSImageEXIFDataを取り出し
set ocidExifDict to (ocidImageRep's valueForProperty:(refMe's NSImageEXIFData))
###NSImageEXIFDataが無い場合もある
if ocidExifDict = (missing value) then
	set strOutPut to "exifデータ無し" as text
else
	###NSImageEXIFDataのキー
	set ocidAllKeyArray to ocidExifDict's allKeys()
	set strOutPut to "" as text
	###NSImageEXIFDataのキーの数だけ繰り返し
	repeat with itemKey in ocidAllKeyArray
		set ocidValue to (ocidExifDict's valueForKey:(itemKey))
		set strClassName to (className() of ocidValue) as text
		###LIST形で値が入っている場合の処理
		if strClassName contains "Array" then
			set strValue to ""
			repeat with itemValue in ocidValue
				set strValue to strValue & "-" & itemValue as text
			end repeat
		else
			set strValue to ocidValue as text
		end if
		###出力用にテキストに
		set strOutPut to strOutPut & "\r" & (itemKey as text) & " : " & strValue as text
	end repeat
end if

##############################
###出力ダイアログ
##############################
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
set aliasIconPath to (POSIX file "/System/Applications/Preview.app/Contents/Resources/AppIcon.icns") as alias
set strMes to ("NSImageEXIFData戻り値です") as text
set recordResult to (display dialog strMes with title "NSImageEXIFData" default answer strOutPut buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 20 with icon aliasIconPath without hidden answer)

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

