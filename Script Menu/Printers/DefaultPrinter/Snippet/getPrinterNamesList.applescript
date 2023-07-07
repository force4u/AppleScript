#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	プリンターキューの名前
#lpadmin -p で設定した名称でのリスト
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

set ocidPrinterNameArray to refMe's NSPrinter's printerNames()
set listPrinterName to ocidPrinterNameArray as list
try
	set listResponse to (choose from list listPrinterName with title "選んでください" with prompt "印刷するプリンタを選んでね" default items (item 1 of listPrinterName) OK button name "印刷する" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if

set strPrinterName to (item 1 of listResponse) as text
