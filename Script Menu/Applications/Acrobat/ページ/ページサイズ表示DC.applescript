#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

## 		"com.adobe.Acrobat.Pro" 
##		"com.adobe.Reader" 

tell application id "com.adobe.Acrobat.Pro"
	##activate
	tell active doc
		tell front PDF Window
			try
				set numAllPages to count of every page
			on error
				display alert "エラー:pdfを開いていません" buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 10
				return
			end try
		end tell
	end tell
end tell

#####表示中のページの回転
tell application id "com.adobe.Acrobat.Pro"
	##activate
	tell active doc
		tell front PDF Window
			tell front page
				set numRotation to rotation
			end tell
		end tell
	end tell
end tell


tell application id "com.adobe.Acrobat.Pro"
	##activate
	tell active doc
		tell front page
			#Crop Boxトリミングサイズ 表示サイズ
			set listCropBoxSize to crop box as list
			#Media Box	ページサイズ
			set listMediaBoxSize to media box as list
			#Bleed Box	裁ち落としサイズ
			set listBleedBoxSize to bleed box as list
			#Trim Box	仕上がりサイズ
			set listTrimBoxSize to trim box as list
			#Art Box	アートサイズ
			set listArtBoxSize to art box as list
		end tell
	end tell
end tell


set numMediaWpt to ((round (((item 3 of listMediaBoxSize) - (item 1 of listMediaBoxSize)) * 100)) / 100) as number
set numMediaWmm to ((round ((numMediaWpt / 2.8346) * 100)) / 100) as text
set numMediaHpt to ((round (((item 2 of listMediaBoxSize) - (item 4 of listMediaBoxSize)) * 100)) / 100) as number
set numMediaHmm to ((round ((numMediaHpt / 2.8346) * 100)) / 100) as text

set numBleedWpt to ((round (((item 3 of listBleedBoxSize) - (item 1 of listBleedBoxSize)) * 100)) / 100) as number
set numBleedWmm to ((round ((numBleedWpt / 2.8346) * 100)) / 100) as text
set numBleedHpt to ((round (((item 2 of listBleedBoxSize) - (item 4 of listBleedBoxSize)) * 100)) / 100) as number
set numBleedHmm to ((round ((numBleedHpt / 2.8346) * 100)) / 100) as text

set numTrimWpt to ((round (((item 3 of listTrimBoxSize) - (item 1 of listTrimBoxSize)) * 100)) / 100) as number
set numTrimWmm to ((round ((numTrimWpt / 2.8346) * 100)) / 100) as text
set numTrimHpt to ((round (((item 2 of listTrimBoxSize) - (item 4 of listTrimBoxSize)) * 100)) / 100) as number
set numTrimHmm to ((round ((numTrimHpt / 2.8346) * 100)) / 100) as text

set numCropWpt to ((round (((item 3 of listCropBoxSize) - (item 1 of listCropBoxSize)) * 100)) / 100) as number
set numCropWmm to ((round ((numCropWpt / 2.8346) * 100)) / 100) as text
set numCropHpt to ((round (((item 2 of listCropBoxSize) - (item 4 of listCropBoxSize)) * 100)) / 100) as number
set numCropHmm to ((round ((numCropHpt / 2.8346) * 100)) / 100) as text


set strMediaText to ("MediaPT: " & numMediaWpt & "x" & numMediaHpt & "\rMediaMM: " & numMediaWmm & "x" & numMediaHmm & "\r") as text
set strBleedText to ("BleedPT: " & numBleedWpt & "x" & numBleedHpt & "\rBleedMM: " & numBleedWmm & "x" & numBleedHmm & "\r") as text
set strTrimText to ("TrimPT: " & numTrimWpt & "x" & numTrimHpt & "\rTrimMM: " & numTrimWmm & "x" & numTrimHmm & "\r") as text
set strCropText to ("CropPT: " & numCropWpt & "x" & numCropHpt & "\rCropMM: " & numCropWmm & "x" & numCropHmm & "\r") as text
set strRotationText to ("Rotation: " & numRotation & "\r") as text


set strMes to (strMediaText & strBleedText & strTrimText & strCropText & strRotationText) as text

if ((item 1 of listMediaBoxSize) + (item 4 of listMediaBoxSize)) > 0 then
	set strMes to strMes & "表示外の領域があります（Mediaサイズ）\r" as text
end if
if ((item 1 of listBleedBoxSize) + (item 4 of listBleedBoxSize)) > 0 then
	set strMes to strMes & "表示外の領域があります（BleedBoxサイズ）\r" as text
end if
if ((item 1 of listTrimBoxSize) + (item 4 of listTrimBoxSize)) > 0 then
	set strMes to strMes & "表示外の領域があります（Trimサイズ）\r" as text
end if
if ((item 1 of listCropBoxSize) + (item 4 of listCropBoxSize)) > 0 then
	set strMes to strMes & "表示外の領域があります（Trimサイズ）\r" as text
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
