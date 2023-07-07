#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
macOS13.4限定
“プリンタの名前.app”から“デスクトップ”フォルダ内のファイルにアクセスしようとしています。
このダイアログは、許可しないでOK
postscriptをプリンタにドロップしたい人はOKで
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set ocidPrinterTypeArray to refMe's NSPrinter's printerTypes()
set listPrinterType to ocidPrinterTypeArray as list
set intCntArray to (count of listPrinterType) as integer

log intCntArray

###システム設定を開いて
tell application "System Settings" to launch
###起動確認１０秒
repeat 10 times
	tell application "System Settings" to activate
	###前面のアプリケーション
	tell application "System Events"
		set strAppName to (name of first application process whose frontmost is true) as text
	end tell
	####起動確認できたら抜ける
	if strAppName is "System Settings" then
		exit repeat
	else
		###起動に時間がかかっている場合は１秒まつ
		delay 1
	end if
end repeat

####パネルオープン確認
tell application "System Settings"
	activate
	repeat 10 times
		####ウィンドウの名前を取得する
		set strWindowName to (name of front window) as text
		###取得できなかったら１秒待つ
		if strWindowName is "" then
			delay 1
			###取得できたらリピート抜ける
		else if strWindowName is "外観" then
			exit repeat
			###すでに起動済みで外観以外を開いている場合
		else
			exit repeat
		end if
	end repeat
end tell

tell application "System Settings"
	set boolDone to reveal anchor "print" of pane id "com.apple.Print-Scan-Settings.extension"
end tell

if boolDone = (missing value) then
	"open終了"
end if

tell application "System Settings" to activate
####パネルオープン確認
tell application "System Settings"
	###起動確認　最大１０秒
	repeat 10 times
		activate
		####ウィンドウの名前を取得する
		set strWindowName to (name of front window) as text
		###取得できなかったら１秒待つ
		if strWindowName is "" then
			delay 1
			###取得できたらリピート抜ける
		else if strWindowName is "プリンタとスキャナ" then
			exit repeat
			###すでに起動済みで外観以外を開いている場合
		else
			delay 1
		end if
	end repeat
end tell



########


repeat with intCntNO from 1 to intCntArray by 1
	tell application "System Settings" to activate
	###前面のアプリケーション
	tell application "System Events"
		tell process "System Settings"
			click button intCntNO of group 2 of scroll area 1 of group 1 of group 2 of splitter group 1 of group 1 of window "プリンタとスキャナ"
			delay 2
			click button 1 of group 1 of scroll area 1 of group 1 of sheet 1 of window "プリンタとスキャナ"
			delay 2
			try
				click button 3 of group 1 of sheet 1 of window "プリンタとスキャナ"
			on error
				click button 2 of group 1 of sheet 1 of window "プリンタとスキャナ"
			end try
		end tell
	end tell
	
end repeat

####プリンタプロキシ終了
###NSRunningApplication
set ocidRunningApplication to refMe's NSRunningApplication
###起動中のすべてのリスト
set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:("com.apple.print.PrinterProxy"))
###複数起動時も順番に終了
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate()
end repeat
