#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#	選択する画像は　縦横サイズ　解像度が同一である必要があります
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
property refNSString : a reference to refMe's NSString
property refNSMutableArray : a reference to refMe's NSMutableArray

###コマ間隔 1000=1秒
set numDuration to 1000 as number
###出力ファイル名
set strOutPutFileName to "AnimatedWebp.webp"
###img2webpへのパス
set strCommandText to ("$HOME/bin/libwebp/bin/img2webp  -loop 0 ") as text


tell application "Finder"
	set aliasDefaultLocation to container of (path to me) as alias
	set aliasDesktopFolder to (path to desktop folder from user domain) as alias
end tell
set strDesktopFolderPath to POSIX path of aliasDesktopFolder as text

###デスクトップに出力
set strOutPutFilePath to ("" & strDesktopFolderPath & strOutPutFileName & "") as text


####ファイル選択ダイアログ
set listChooseFile to (choose file with prompt "イメージファイルを選んでください" default location aliasDefaultLocation of type {"public.png"} with invisibles and multiple selections allowed without showing package contents) as list

###並び替え用のアレーの初期化
set ocidNewArrayM to refNSMutableArray's alloc()'s initWithCapacity:0

###選択したファイルパスをUNIXファイルパスに変換してリストに格納
repeat with objFilePath in listChooseFile
	set aliasFilePath to objFilePath as alias
	set strFilePath to POSIX path of aliasFilePath as text
	(ocidNewArrayM's addObject:strFilePath)
end repeat

####ファイルパスを名前順に並び替え
set ocidSelf to refNSString's stringWithString:"self"
set ocidDescriptor to refMe's NSSortDescriptor's sortDescriptorWithKey:ocidSelf ascending:true selector:"compare:"
set ocidSortedList to (ocidNewArrayM's sortedArrayUsingDescriptors:{ocidDescriptor}) as list

####コマンド行の初期化
set strAddCommandText to ""
###ファイルパスだけ繰り返し
repeat with objFilePath in ocidSortedList
	###テキストにして
	set strFilePath to objFilePath as text
	###コマンド行を整形して
	set strAddCommandText to " -lossless -d " & numDuration & "  -q 100 \"" & strFilePath & "\"" as text
	###コマンド行に追加
	set strCommandText to strCommandText & strAddCommandText as text
	
end repeat

####最終的なコマンド行を整形して
set strCommandText to ("" & strCommandText & " -o \"" & strOutPutFilePath & "\"") as text

###実行
tell application "Terminal"
	launch
	activate
	set objWindowID to (do script "\n\n")
	delay 2
	do script strCommandText in objWindowID
end tell

