#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
##使わなかった…苦笑
property strServerRootPath : "/Library/WebServer/Documents" as text
property strHostURL : "http://localhost" as text


on run (argAliasFilePath)
	set strFilePath to (POSIX path of argAliasFilePath) as text
	##ユーザーディレクトリ配下か？判定用
	set ocidUserName to refMe's NSUserName()
	set strUserName to ocidUserName as text
	##パスをリストにする
	##ローカルサイトの場合
	set AppleScript's text item delimiters to "/"
	set listPath to every text item of strFilePath as list
	set AppleScript's text item delimiters to ""
	##リストの数えて
	set numCntListItem to count of item of listPath
	
	if (strFilePath) contains (strUserName) then
		##ユーザーサイトの場合
		##オフセット値 / Users / ユーザー名 / Sites /  で５
		set numOffset to numCntListItem - (numCntListItem - 5) as integer
		##
		set listOpenPathItem to (items (numOffset) thru (last item) of listPath) as list
		set strOpenPath to ("") as text
		repeat with itemPath in listOpenPathItem
			set strOpenPath to (strOpenPath & "/" & itemPath) as text
		end repeat
		set strOpenURL to (strHostURL & "/" & strUserName & strOpenPath) as text
		
	else if (strFilePath) contains ("Shared") then
		##共有サイトの場合
		##オフセット値 / Users / Shared / Sites /  で５
		set numOffset to numCntListItem - (numCntListItem - 5) as integer
		##
		set listOpenPathItem to (items (numOffset) thru (last item) of listPath) as list
		set strOpenPath to ("") as text
		repeat with itemPath in listOpenPathItem
			set strOpenPath to (strOpenPath & "/" & itemPath) as text
		end repeat
		set strOpenURL to (strHostURL & "/" & "Shared" & strOpenPath) as text
		
	else
		##ローカルドキュメントの場合
		##オフセット値 / Library / WebServer / Documents /  で５
		set numOffset to numCntListItem - (numCntListItem - 5) as integer
		##
		set listOpenPathItem to (items (numOffset) thru (last item) of listPath) as list
		set strOpenPath to ("") as text
		repeat with itemPath in listOpenPathItem
			set strOpenPath to (strOpenPath & "/" & itemPath) as text
		end repeat
		set strOpenURL to (strHostURL & strOpenPath) as text
		
	end if
	log strOpenURL
	tell application "Finder"
		open location strOpenURL
	end tell
	
end run
