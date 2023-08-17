#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# macOS12あたりからこの設定は反映されない
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


####ログインアイテム 設定開始時
log "設定前："
tell application "System Events"
	set listLoginItem to every login item
	set listOutPut to {} as list
	repeat with itemLoginItem in listLoginItem
		tell itemLoginItem
			set recordProperties to properties
			set end of listOutPut to recordProperties
		end tell
	end repeat
end tell



####ログインアイテム起動時『隠す』で起動する
log "設定変更："
tell application "System Events"
	set listLoginItem to every login item
	repeat with itemLoginItem in listLoginItem
		tell itemLoginItem
			set hidden to true
		end tell
	end repeat
end tell


####ログインアイテム 設定後
log "設定後："
tell application "System Events"
	set listLoginItem to every login item
	set listOutPut to {} as list
	repeat with itemLoginItem in listLoginItem
		tell itemLoginItem
			set recordProperties to properties
			set end of listOutPut to recordProperties
		end tell
	end repeat
end tell

