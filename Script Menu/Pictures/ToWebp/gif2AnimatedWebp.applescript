#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 現時点ではSafariでの表示に問題があるため、非推奨の形式
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
property refNSString : a reference to refMe's NSString
property refNSMutableArray : a reference to refMe's NSMutableArray



tell application "Finder"
	set aliasDefaultLocation to container of (path to me) as alias
	set aliasDesktopFolder to (path to desktop folder from user domain) as alias
end tell


set listChooseFile to (choose file with prompt "フォントファイルを選んでください" default location aliasDefaultLocation of type {"com.compuserve.gif"} with invisibles and multiple selections allowed without showing package contents) as list


repeat with objFilePath in listChooseFile
	###コマンド基本
	set strCommandText to ("$HOME/bin/libwebp/bin/gif2webp -q 100 ") as text
	tell application "Finder"
		set aliasFilePath to objFilePath as alias
		###ファイルパスを取得
		set strFilePath to POSIX path of aliasFilePath as text
	end tell
	###コマンド行に追加して
	set strWebpFilePath to ("\"" & strFilePath & "\" -o \"" & strFilePath & ".webp\"") as text
	####最終的なコマンド行整形
	set strCommandText to strCommandText & strWebpFilePath as text
	####実行
	tell application "Terminal"
		launch
		activate
		set objWindowID to (do script "\n\n")
		delay 2
		do script strCommandText in objWindowID
	end tell
	
	####処理が終わるのをまってから次にかかる
	repeat
		tell application "Terminal"
			set boolTabStatus to busy of objWindowID
		end tell
		if boolTabStatus is false then
			exit repeat
			--->このリピートを抜けて次の処理へ
		else if boolTabStatus is true then
			delay 3
			--->busyなのであと３秒まつ
		end if
	end repeat
	
	
end repeat

