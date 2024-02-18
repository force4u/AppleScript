#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

####主要な用紙サイズ
set listPaperSizeAndName to {"A3x1191x842", "A4x842x595", "A5x595x420", "A6x420x297", "はがきx419x283", "長形3号封筒x666x340", "長形4号封筒x581x255", "洋形4号封筒x666x298", "洋長3号封筒x666x340", "角形2号封筒x941x680", "B4x1032x729", "B5x729x516", "B6x516x363", "SRA3x1276x907", "SRA4x907x638", "横A3x842x1191", "横A4x595x842", "横A5x420x595", "横A6x297x420", "横はがきx283x419", "横長形3号封筒x340x666", "横長形4号封筒x255x581", "横洋形4号封筒x298x666", "横洋長3号封筒x666x340", "横角形2号封筒x680x941", "横B4x729x1032", "横B5x516x729", "横B6x363x516", "横SRA3x907x1276", "横SRA4x638x907"}
###ダイアログを出す
try
	set objResponse to (choose from list listPaperSizeAndName with title "用紙サイズ選択" with prompt "キーノートの書類をサイズ指定して作成します" default items (item 1 of listPaperSizeAndName) OK button name "OK" cancel button name "キャンセル" without empty selection allowed and multiple selections allowed)
on error
	log "エラーしました"
	return
end try
if objResponse is false then
	return
end if
set theResponse to (objResponse) as text

####区切り文字xでリストにする
set AppleScript's text item delimiters to "x"
set listResponse to every text item of theResponse
set AppleScript's text item delimiters to ""

####各値を取得
set strPaperName to text item 1 of listResponse as text
set numPtHight to text item 2 of listResponse as text
set numPtWidth to text item 3 of listResponse as text

#####キーノートで新規書類を作成する
tell application "Keynote"
	launch
	activate
	
	set objNewDocument to (make new document with properties {name:"" & strPaperName & "", height:"" & numPtHight & "", width:"" & numPtWidth & "", slide numbers showing:true, document theme:theme id "Application/21_BasicWhite/Standard"})
	
	tell window 1
		set bounds to {0, 25, 780, 720}
		properties
	end tell
	tell objNewDocument
		properties
	end tell
end tell


return


