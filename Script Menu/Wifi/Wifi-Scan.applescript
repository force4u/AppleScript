#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*	RSSI値の目安　劣化、遅延なしが０->これはあり得ない
良好な信号品質: -30 dBm 以上
中程度の信号品質: -50 dBm 前後
悪い信号品質: -70 dBm 未満
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

##### airport -s
set strCommandText to "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s"
tell application "Terminal"
	launch
	activate
	set objTabWindows to do script "\n\n"
	tell objTabWindows
		activate
	end tell
	activate
	tell application "System Events"
		tell process "Terminal"
			set frontmost to true
			click menu item "タブを新しいウインドウに移動" of menu 1 of menu bar item "ウインドウ" of menu bar 1
		end tell
	end tell
	
	
	
	tell front window
		activate
		set numWidowID to id as integer
	end tell
	
	tell window id numWidowID
		set size to {980, 320}
		set position to {0, 25}
		set origin to {360, 515}
		set frame to {0, 560, 980, 875}
		set bounds to {0, 25, 980, 320}
	end tell
	tell objTabWindows
		activate
		do script strCommandText in objTabWindows
	end tell
	delay 3
	set strCommandText to "/bin/echo \"RSSIの値　良:-30 中:-50 不良：-70\""
	tell objTabWindows
		activate
		do script strCommandText in objTabWindows
	end tell
end tell
##### airport -I
set strCommandText to "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I"
tell application "Terminal"
	launch
	activate
	set objTabWindows to do script "\n\n"
	tell objTabWindows
		activate
	end tell
	activate
	tell application "System Events"
		tell process "Terminal"
			set frontmost to true
			click menu item "タブを新しいウインドウに移動" of menu 1 of menu bar item "ウインドウ" of menu bar 1
		end tell
	end tell
	tell front window
		activate
		set numWidowID to id as integer
	end tell
	
	tell window id numWidowID
		set size to {520, 560}
		set position to {0, 321}
		set origin to {0, 80}
		set frame to {0, 80, 520, 660}
		set bounds to {0, 321, 520, 890}
	end tell
	tell objTabWindows
		activate
		do script strCommandText in objTabWindows
	end tell
	delay 1
	set strCommandText to "/usr/bin/printf \"RSSIの値　良:-30 中:-50 不良：-70\""
	tell objTabWindows
		activate
		do script strCommandText in objTabWindows
	end tell
end tell



##### airport -I
set strCommandText to "while x=1; do /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep CtlRSSI; sleep 0.5; done"
tell application "Terminal"
	launch
	activate
	set objTabWindows to do script "\n\n"
	tell objTabWindows
		activate
	end tell
	tell front window
		activate
		set numWidowID to id as integer
	end tell
	tell window id numWidowID
		set size to {520, 560}
		set position to {0, 321}
		set origin to {0, 80}
		set frame to {0, 80, 520, 660}
		set bounds to {0, 321, 520, 890}
	end tell
	activate
	tell application "System Events"
		tell process "Terminal"
			set frontmost to true
			click menu item "タブを新しいウインドウに移動" of menu 1 of menu bar item "ウインドウ" of menu bar 1
		end tell
	end tell
	tell front window
		activate
		set numWidowID to id as integer
	end tell
	
	tell window id numWidowID
		set size to {459, 499}
		set position to {521, 321}
		set origin to {521, 80}
		set frame to {521, 80, 980, 579}
		set bounds to {521, 321, 980, 820}
	end tell
	tell objTabWindows
		activate
		do script strCommandText in objTabWindows
	end tell
end tell
