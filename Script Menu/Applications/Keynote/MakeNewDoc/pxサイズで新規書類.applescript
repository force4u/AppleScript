#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


set aliasIconPath to POSIX file "/Applications/Keynote.app/Contents/Resources/AppIcon.icns" as alias
set theResponse to "1280x720"
try
	set objResponse to (display dialog "書類サイズを幅x高さで入力" with title "数値入力" default answer theResponse buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 10 without hidden answer)
on error
	log "エラーしました"
	return
end try
if true is equal to (gave up of objResponse) then
	return "時間切れですやりなおしてください"
end if
if "OK" is equal to (button returned of objResponse) then
	set theResponse to (text returned of objResponse) as text
else
	return "キャンセル"
end if

set strName to theResponse as text


set strName to doReplace(strName, " × ", "x") as text
set strName to doReplace(strName, " ", "") as text
set strName to doReplace(strName, " ", "") as text
set strName to doReplace(strName, "×", "x") as text


####区切り文字xでリストにする
set AppleScript's text item delimiters to "x"
set listResponse to every text item of strName
set AppleScript's text item delimiters to ""

####各値を取得

set numPtHight to text item 2 of listResponse as text
set numPtWidth to text item 1 of listResponse as text

set numPtHight to numPtHight as number
set numPtWidth to numPtWidth as number

####キーノートはpx=pt
##set numPtHight to (round (numPtHight * 0.75))
##set numPtWidth to (round (numPtWidth * 0.75))


#####キーノートで新規書類を作成する
tell application "Keynote"
	launch
	activate
	
	set objNewDocument to (make new document with properties {name:"" & strName & "", height:"" & numPtHight & "", width:"" & numPtWidth & "", slide numbers showing:true, document theme:theme id "Application/21_BasicWhite/Standard"})
	
	tell window 1
		set bounds to {0, 25, 780, 720}
		properties
	end tell
	
end tell


to doReplace(theText, orgStr, newStr)
	set oldDelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to orgStr
	set tmpList to every text item of theText
	set AppleScript's text item delimiters to newStr
	set tmpStr to tmpList as text
	set AppleScript's text item delimiters to oldDelim
	return tmpStr
end doReplace



return


