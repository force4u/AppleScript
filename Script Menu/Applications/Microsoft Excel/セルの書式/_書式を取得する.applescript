#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions


#####################################
#####スクリプトメニューから実行させない
#####################################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		set aliasPathToMe to path to me as alias
		tell application "Script Editor"
			open aliasPathToMe
		end tell
		return "中止しました"
	end tell
else
	tell current application
		activate
	end tell
end if

tell application "Microsoft Excel"
	set objSelectionCell to cells of selection
end tell


repeat with objCell in objSelectionCell
	
	tell application "Microsoft Excel"
		tell window 1
			tell active workbook
				tell active sheet
					tell objCell
						get number format
						get number format local
					end tell
				end tell
			end tell
		end tell
	end tell
end repeat

