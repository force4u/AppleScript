#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application


set listPanel to {"balance", "effects", "input", "mute", "output", "volume"} as list
set recordPanel to {|バランス|:"balance", |効果音|:"effects", |入力|:"input", |消音|:"mute", |出力|:"output", |ボリューム|:"volume"} as record
set ocidPanelDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPanelDict's setDictionary:(recordPanel)
set ocidPanelKeyArray to ocidPanelDict's allKeys()
set listPanelKeyArray to ocidPanelKeyArray as list



set listResponse to (choose from list listPanelKeyArray with title "選んでください" with prompt "パネルを選んでください" default items (item 1 of listPanelKeyArray) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list

set strKyeName to (item 1 of listResponse) as text

set strValue to (ocidPanelDict's valueForKey:(strKyeName)) as text

tell application id "com.apple.systempreferences"
	launch
	activate
	reveal anchor strValue of pane id "com.apple.Sound-Settings.extension"
end tell
