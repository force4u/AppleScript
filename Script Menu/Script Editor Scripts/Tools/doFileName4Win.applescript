#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe

## Script Editor Scripts 用
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

property strBundleID : "com.apple.ScriptEditor2" as text




set strInsertScript to ("set strNewFileName to doFileName4Win(strFileName)\rlog strNewFileName\r\r#######################################\r###ファイル名に使えない文字を全角に置換（Win互換）\r#######################################\rto doFileName4Win(atgFileName)\r\t###受け取った値をテキストに\r\tset strFileName to atgFileName as text\r\tset ocidRetuenFileName to refMe's NSMutableString's alloc()'s initWithCapacity:(0)\r\tocidRetuenFileName's setString:(strFileName)\r\t###置換レコード\r\tset ocidLength to ocidRetuenFileName's |length|()\r\tset ocidRange to refMe's NSMakeRange(0, ocidLength)\r\tset ocidOption to (refMe's NSCaseInsensitiveSearch)\r\t###基本レコード\r\tset recordProhibit to {|\\\\|:\"￥\", |<|:\"＜\", |>|:\"＞\", |*|:\"＊\", |?|:\"？\", |\"|:\"＂\", |\\||:\"｜\", |/|:\"／\", |:|:\"：\"} as record\r\tset ocidProhibitDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0\r\tocidProhibitDict's setDictionary:(recordProhibit)\r\t###キーのリストを取出して\r\tset ocidKeyArray to ocidProhibitDict's allKeys()\r\t###キーの数だけ繰り返し\r\trepeat with itemKey in ocidKeyArray\r\t\t##キーから\r\t\tset strKey to itemKey as text\r\t\t##値を取出して\r\t\tset strValue to (ocidProhibitDict's valueForKey:(itemKey)) as text\r\t\t##キー文字をヴァリュー文字に置換\r\t\t(ocidRetuenFileName's replaceOccurrencesOfString:(strKey) withString:(strValue) options:(ocidOption) range:(ocidRange))\r\tend repeat\r\t##置換されたテキストを\r\tset strRetuenFileName to ocidRetuenFileName as text\r\t###戻す\r\treturn strRetuenFileName\rend doFileName4Win") as text

tell application id strBundleID
	tell the front document
		set strSelectedContents to the contents of selection
	end tell
end tell

set strSelectedContents to strSelectedContents & "\r" & strInsertScript & "\r" & "" as text

tell application id strBundleID
	tell the front document
		set contents of selection to strSelectedContents
		set selection to {}
	end tell
end tell
