#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

########################
###コマンド生成　実行
set strCommandText to "/usr/sbin/networksetup  -listallnetworkservices"
set strResults to (do shell script strCommandText) as text
###戻り値を改行でリストに
set ocidListallnetworkservices to refMe's NSString's stringWithString:(strResults)
set ocidChrSet to refMe's NSCharacterSet's characterSetWithCharactersInString:("\r")
set ocidNetworkNameArray to ocidListallnetworkservices's componentsSeparatedByCharactersInSet:(ocidChrSet)
(ocidNetworkNameArray's removeObjectAtIndex:(0))
##リストの数だけ繰り返し
set strWiFiID to "" as text
repeat with itemNetworkName in ocidNetworkNameArray
	set strServiceName to itemNetworkName as text
	###コマンド生成　実行
	set strCommandText to "/usr/sbin/networksetup  -getinfo \"" & strServiceName & "\"" as text
	set strResponse to (do shell script strCommandText) as text
	if strResponse contains "Wi-Fi" then
		###戻り値を改行でリストに
		set ocidResponse to (refMe's NSString's stringWithString:(strResponse))
		set ocidChrSet to (refMe's NSCharacterSet's characterSetWithCharactersInString:("\r"))
		set ocidResponseArray to (ocidResponse's componentsSeparatedByCharactersInSet:(ocidChrSet))
		##リストの数だけ繰り返し
		repeat with itemResponse in ocidResponseArray
			set strResponse to itemResponse as text
			if strResponse contains "Wi-Fi ID" then
				###全半角両方生成する
				set ocidOrgStrings to (refMe's NSString's stringWithString:(strResponse))
				set ocidNSStringTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
				set ocidUppercase to ocidOrgStrings's uppercaseString()
				set strUppercase to ocidUppercase as text
				set strWiFiID to ("" & strResponse & "\n" & strUppercase & "") as text
			end if
		end repeat
	end if
end repeat
###クリップボードにコピー用にMACアドレスのみにする
set ocidStrArray to ocidUppercase's componentsSeparatedByString:" "
set ocidUppercaseId to ocidStrArray's lastObject()
set strText to ocidUppercaseId as text

##############################
#####ダイアログを前面に出す
##############################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns" as alias
set recordResult to (display dialog strWiFiID with title "NWデバイスMacアドレス" default answer strWiFiID buttons {"クリップボードにコピー", "OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)

if "クリップボードにコピー" is (button returned of recordResult) then
	set ocidText to (refMe's NSString's stringWithString:(strText))
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	appPasteboard's clearContents()
	##結果をペーストボードにテキストで入れる
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	return
end if
