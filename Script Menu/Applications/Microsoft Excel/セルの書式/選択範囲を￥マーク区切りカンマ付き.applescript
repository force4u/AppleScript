#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions

tell application "Microsoft Excel"
	set objSelectionCell to cells of selection
end tell


repeat with objCell in objSelectionCell
	
	tell application "Microsoft Excel"
		tell window 1
			tell active workbook
				tell active sheet
					tell objCell
						set number format to "$#,##0_);($#,##0)"
						set number format local to "\#,##0;\-#,##0"
					end tell
				end tell
			end tell
		end tell
	end tell
	
end repeat

