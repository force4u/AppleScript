#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.microsoft.edgemac にブックマークを追加する
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application

###起動
tell application id "com.microsoft.edgemac" to launch
###アプリケーションの起動待ち最大１０秒
repeat 10 times
	tell application id "com.microsoft.edgemac"
		activate
		set boolFrontMost to frontmost as boolean
	end tell
	if boolFrontMost is true then
		log "起動OK"
		exit repeat
	else
		delay 1
	end if
end repeat
####開くURL
set strURL to "edge://favorites/" as text
###ウィンドウの有無
tell application id "com.microsoft.edgemac"
	set numCntWindow to (count of window) as integer
end tell
####URLを開く
if numCntWindow = 0 then
	###ウィンドウが無い場合は新規ウィンドウでURLをロード
	tell application id "com.microsoft.edgemac"
		make new window
		tell front window
			tell active tab
				set URL to strURL
			end tell
		end tell
	end tell
else
	###ウィンドウがある場合は新規タブでURLをロード
	tell application id "com.microsoft.edgemac"
		tell front window
			make new tab with properties {URL:strURL}
		end tell
	end tell
end if

###URl読み込み確認最大１０秒
repeat 10 times
	tell application id "com.microsoft.edgemac"
		tell front window
			tell active tab
				set boolLoading to loading as boolean
			end tell
		end tell
	end tell
	if boolLoading is false then
		log "URL読み込み完了"
		exit repeat
	else
		delay 1
	end if
end repeat

set ocidBkMkFolderDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0

set listBookMarkID to {} as list

tell application id "com.microsoft.edgemac"
	set listBookMarkFolder to (every bookmark folder) as list
	repeat with itemBookMarkFolder in listBookMarkFolder
		set strBkMkFolderID to (id of itemBookMarkFolder) as text
		set strBkMkFolderName to (title of itemBookMarkFolder)
		set end of listBookMarkID to strBkMkFolderID
		(ocidBkMkFolderDict's setValue:(strBkMkFolderID) forKey:(strBkMkFolderName))
	end repeat
end tell
####"その他のお気に入り"のブックマークフォルダIDを取り出す

set strBkMkDirID to (ocidBkMkFolderDict's valueForKey:("その他のお気に入り")) as text

tell application id "com.microsoft.edgemac"
	tell bookmark folder id strBkMkDirID
		set objMakeBookMarkDir to (make new bookmark folder with properties {title:"Microsoft"})
		tell objMakeBookMarkDir
			make new bookmark item with properties {URL:"https://www.msn.com/ja-jp/feed", title:"Microsoft Start"}
			
			make new bookmark item with properties {URL:"https://www.office.com/", title:"Microsoft 365"}
			make new bookmark item with properties {URL:"https://office.live.com/start/Word.aspx", title:"Word | Microsoft 365"}
			make new bookmark item with properties {URL:"https://office.live.com/start/Excel.aspx", title:"Excel | Microsoft 365"}
			make new bookmark item with properties {URL:"https://office.live.com/start/Powerpoint.aspx", title:"Powerpoint | Microsoft 365"}
			make new bookmark item with properties {URL:"https://office.live.com/start/Outlook.aspx", title:"Outlook | Microsoft 365"}
			make new bookmark item with properties {URL:"https://office.live.com/start/OneDrive.aspx", title:"OneDrive | Microsoft 365"}
			
			make new bookmark item with properties {URL:"https://web.skype.com/", title:"Skype Web"}
			make new bookmark item with properties {URL:"https://teams.live.com/_?#/conversations/?ctx=chat", title:"Teams | Microsoft 365"}
			make new bookmark item with properties {URL:"https://www.onenote.com/", title:"OneNote | Microsoft 365"}
			make new bookmark item with properties {URL:"https://www.bing.com/", title:"Bing | Microsoft"}
		end tell
	end tell
end tell

set strBkMkDirID to (ocidBkMkFolderDict's valueForKey:("お気に入りバー")) as text

tell application id "com.microsoft.edgemac"
	tell bookmark folder id strBkMkDirID
		set objMakeBookMarkDir to (make new bookmark folder with properties {title:"Microsoft"})
		tell objMakeBookMarkDir
			make new bookmark item with properties {URL:"https://www.msn.com/ja-jp/feed", title:"Microsoft Start"}
			
			make new bookmark item with properties {URL:"https://www.office.com/", title:"Microsoft 365"}
			make new bookmark item with properties {URL:"https://office.live.com/start/Word.aspx", title:"Word | Microsoft 365"}
			make new bookmark item with properties {URL:"https://office.live.com/start/Excel.aspx", title:"Excel | Microsoft 365"}
			make new bookmark item with properties {URL:"https://office.live.com/start/Powerpoint.aspx", title:"Powerpoint | Microsoft 365"}
			make new bookmark item with properties {URL:"https://office.live.com/start/Outlook.aspx", title:"Outlook | Microsoft 365"}
			make new bookmark item with properties {URL:"https://office.live.com/start/OneDrive.aspx", title:"OneDrive | Microsoft 365"}
			
			make new bookmark item with properties {URL:"https://web.skype.com/", title:"Skype Web"}
			make new bookmark item with properties {URL:"https://teams.live.com/_?#/conversations/?ctx=chat", title:"Teams | Microsoft 365"}
			make new bookmark item with properties {URL:"https://www.onenote.com/", title:"OneNote | Microsoft 365"}
			make new bookmark item with properties {URL:"https://www.bing.com/", title:"Bing | Microsoft"}
		end tell
		
		
	end tell
end tell




return


