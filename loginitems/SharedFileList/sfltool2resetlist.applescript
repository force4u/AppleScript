#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
要管理者権限
実行後再起動（デバイス電源OFF-ON）推奨
対象のSharedFileListをリセットします
リセットするのは４つ
"com.apple.LSSharedFileList.SessionLoginItems"
"com.apple.LSSharedFileList.ManagedSessionLoginItems"

"com.apple.LSSharedFileList.SFLServiceManagementLoginItems"
"com.apple.LSSharedFileList.GlobalLoginItems"
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
#######################################
###リストを取得
#######################################
##	set listLoginItemSharedFileList to {"com.apple.LSSharedFileList.SFLServiceManagementLoginItems", "com.apple.LSSharedFileList.GlobalLoginItems"}

##	set listLoginItemSharedFileList to {"com.apple.LSSharedFileList.SessionLoginItems", "com.apple.LSSharedFileList.ManagedSessionLoginItems"}

set listLoginItemSharedFileList to {"com.apple.LSSharedFileList.SessionLoginItems", "com.apple.LSSharedFileList.SFLServiceManagementLoginItems", "com.apple.LSSharedFileList.GlobalLoginItems", "com.apple.LSSharedFileList.ManagedSessionLoginItems"}

#######################################
###リセット実行
#######################################
repeat with itemLoginItemSharedFileList in listLoginItemSharedFileList
	set strLoginItemSharedFileList to itemLoginItemSharedFileList as text
	set strCommandText to ("/usr/bin/sfltool resetlist " & strLoginItemSharedFileList & "") as text
	do shell script strCommandText
end repeat








