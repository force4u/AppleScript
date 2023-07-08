#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# 
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "PDFKit"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

set ocidFalse to (refMe's NSNumber's numberWithBool:false)
set ocidTrue to (refMe's NSNumber's numberWithBool:true)

tell application id "com.apple.Preview"
	set numCntWindow to count of every window
end tell
if numCntWindow = 0 then
	display alert "エラー:pdfを開いていません" buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 10
	return "エラー:pdfを開いていません"
end if

tell application id "com.apple.Preview"
	tell front window
		set strFileName to name as text
	end tell
end tell
if strFileName ends with ".pdf" then
	tell application id "com.apple.Preview"
		tell front document
			set strFilePath to path as text
			set boolMode to modified
		end tell
	end tell
else
	display alert "エラー:pdfを開いていません" buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 10
	return "エラー:pdfを開いていません"
end if


set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

set ocidActivDoc to (refMe's PDFDocument's alloc()'s initWithURL:ocidFilePathURL)
set ocidActivPage to (ocidActivDoc's pageAtIndex:0)

set ocidRotation to ocidActivPage's |rotation|()
set strRotation to ocidRotation as text
set ocidMedeiaBox to ocidActivPage's boundsForBox:(refMe's kPDFDisplayBoxMediaBox)
set ocidBleedBox to ocidActivPage's boundsForBox:(refMe's kPDFDisplayBoxBleedBox)
set ocidTrimBox to ocidActivPage's boundsForBox:(refMe's kPDFDisplayBoxTrimBox)
set ocidCropBox to ocidActivPage's boundsForBox:(refMe's kPDFDisplayBoxCropBox)

set listMedeiaOrigin to item 1 of ocidMedeiaBox
set listMedeiaSize to item 2 of ocidMedeiaBox

set listBleedOrigin to item 1 of ocidBleedBox
set listBleedSize to item 2 of ocidBleedBox

set listTrimOrigin to item 1 of ocidTrimBox
set listTrimSize to item 2 of ocidTrimBox

set listCropOrigin to item 1 of ocidCropBox
set listCropSize to item 2 of ocidCropBox


set numMediaWpt to ((round ((item 1 of listMedeiaSize) * 100)) / 100) as number
set numMediaWmm to ((round ((numMediaWpt / 2.8346) * 100)) / 100) as text
set numMediaHpt to ((round ((item 2 of listMedeiaSize) * 100)) / 100) as number
set numMediaHmm to ((round ((numMediaHpt / 2.8346) * 100)) / 100) as text

set numBleedWpt to ((round ((item 1 of listBleedSize) * 100)) / 100) as number
set numBleedWmm to ((round ((numBleedWpt / 2.8346) * 100)) / 100) as text
set numBleedHpt to ((round ((item 2 of listBleedSize) * 100)) / 100) as number
set numBleedHmm to ((round ((numBleedHpt / 2.8346) * 100)) / 100) as text

set numTrimWpt to ((round ((item 1 of listTrimSize) * 100)) / 100) as number
set numTrimWmm to ((round ((numTrimWpt / 2.8346) * 100)) / 100) as text
set numTrimHpt to ((round ((item 2 of listTrimSize) * 100)) / 100) as number
set numTrimHmm to ((round ((numTrimHpt / 2.8346) * 100)) / 100) as text

set numCropWpt to ((round ((item 1 of listCropSize) * 100)) / 100) as number
set numCropWmm to ((round ((numCropWpt / 2.8346) * 100)) / 100) as text
set numCropHpt to ((round ((item 2 of listCropSize) * 100)) / 100) as number
set numCropHmm to ((round ((numCropHpt / 2.8346) * 100)) / 100) as text


set strMediaText to ("MediaPT: " & numMediaWpt & "x" & numMediaHpt & "\rMediaMM: " & numMediaWmm & "x" & numMediaHmm & "\r") as text
set strBleedText to ("BleedPT: " & numBleedWpt & "x" & numBleedHpt & "\rBleedMM: " & numBleedWmm & "x" & numBleedHmm & "\r") as text
set strTrimText to ("TrimPT: " & numTrimWpt & "x" & numTrimHpt & "\rTrimMM: " & numTrimWmm & "x" & numTrimHmm & "\r") as text
set strCropText to ("CropPT: " & numCropWpt & "x" & numCropHpt & "\rCropMM: " & numCropWmm & "x" & numCropHmm & "\r") as text
set strRotationText to ("Rotation: " & strRotation & "\r") as text


set strMes to (strMediaText & strBleedText & strTrimText & strCropText & strRotationText) as text

if ((item 1 of listMedeiaOrigin) + (item 2 of listMedeiaOrigin)) > 0 then
	set strMes to strMes & "表示外の領域があります（Mediaサイズ）\r" as text
end if
if ((item 1 of listBleedOrigin) + (item 2 of listBleedOrigin)) > 0 then
	set strMes to strMes & "表示外の領域があります（BleedBoxサイズ）\r" as text
end if
if ((item 1 of listTrimOrigin) + (item 2 of listTrimOrigin)) > 0 then
	set strMes to strMes & "表示外の領域があります（Trimサイズ）\r" as text
end if
if ((item 1 of listCropOrigin) + (item 2 of listCropOrigin)) > 0 then
	set strMes to strMes & "表示外の領域があります（Cropサイズ）\r" as text
end if





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
	set recordResponse to (display dialog strMes with title "ページサイズです" default answer strMes buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
	
on error
	log "エラーしました"
	return "エラーしました"
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
	
	###クリップボードコピー
else if button returned of recordResponse is "クリップボードにコピー" then
	set strText to text returned of recordResponse as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
else
	log "キャンセルしました"
	return "キャンセルしました"
end if


return
