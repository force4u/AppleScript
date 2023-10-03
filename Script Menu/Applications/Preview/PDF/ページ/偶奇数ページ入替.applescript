#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#	com.apple.Preview
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "PDFKit"
use framework "Quartz"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

##################################
###スクリプトメニューから実行したら
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
##################################
###起動
tell application "Preview" to launch
###前面に
tell application id "com.apple.Preview"
	set boolFrontMost to frontmost as boolean
end tell
###最大５秒待つ
repeat 10 times
	if boolFrontMost is false then
		exit repeat
	else
		tell application "Preview" to activate
		delay 0.5
	end if
end repeat
##################################
### ウィンドウがあるか？
tell application "Preview"
	set numCntDoc to (count of every window) as integer
end tell
if numCntDoc = 0 then
	display alert "エラー:pdfを開いていません" buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 10
	return "ウィンドウがありませんPDFを開いてね"
end if
##################################
### インスペクタを表示
tell application "Preview"
	activate
	tell application "System Events"
		tell process "Preview"
			try
				click menu item "インスペクタを表示" of menu 1 of menu bar item "ツール" of menu bar 1
			on error
				log "たぶん、インスペクタを表示済み"
			end try
		end tell
	end tell
end tell
##################################
### PDF文書を開いているか？
tell application "Preview"
	tell front document
		set strFileName to name as text
	end tell
end tell
if strFileName does not contain "PDF" then
	display alert "エラー:pdfを開いていません" buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 10
	return "ウィンドウがありませんPDFを開いてね"
else
	###PDFを開いているならパスを取得する
	tell application "Preview"
		tell front document
			set strFilePath to path as text
		end tell
	end tell
end if
##################################
###変更箇所があるなら保存して閉じる
tell application "Preview"
	tell front document
		set boolMode to modified
		###変更箇所があるなら保存する
		if boolMode is true then
			close saving yes
		else
			close saving no
		end if
	end tell
end tell
#################################
### 本処理
###パス処理
set ocidFilePathStr to (refMe's NSString's stringWithString:strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
##########################
####PDFファイルを格納
set ocidPDFDocument to (refMe's PDFDocument's alloc()'s initWithURL:(ocidFilePathURL))
####ページ数
set numPageCnt to ocidPDFDocument's pageCount() as integer

if numPageCnt = 1 then
	log "１ページの場合は処理できない"
	return "１ページの場合は処理できない"
else
	###ページ数カウンター
	set numCntPageNo to 0 as number
	repeat numPageCnt times
		####偶数奇数判定 mod=割った時に小数点以下があるか？
		set numChkPageOddEven to (numCntPageNo mod 2) as number
		###０なら奇数
		if numChkPageOddEven = 0 then
			ocidPDFDocument's exchangePageAtIndex:(numCntPageNo) withPageAtIndex:(numCntPageNo + 1)
		else if numChkPageOddEven = 1 then
			###０なら奇数処理は奇数ページで行い偶数ページは操作しない
			log "偶数ページ"
		end if
		set numCntPageNo to numCntPageNo + 1 as number
	end repeat
end if
#################################
###保存する
ocidPDFDocument's writeToURL:(ocidFilePathURL)
#################################
set aliasFilePath to (POSIX file strFilePath) as alias
###開く
tell application "Preview"
	open file aliasFilePath
end tell

return
