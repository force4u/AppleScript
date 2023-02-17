#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#			Jedit用のURLエンコードされている％エンコード文字列を
#			読める形にデコード
#
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.6"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
property refNSString : a reference to refMe's NSString


##############################
#### 選択範囲のテキストを取得
##############################
tell application "CotEditor"
	tell front document
		set strInputText to contents of selection
	end tell
end tell
##############################
#### デコード
##############################
set strOutPutText to urlDecode(strInputText) as text
##############################
#### 戻り値テキストで置き換え
##############################
tell application "CotEditor"
	tell front document
		set contents of selection to strOutPutText
	end tell
end tell



on urlDecode(argInputText)
	set ocidRawUrl to refNSString's stringWithString:argInputText
	set ocidEncodedURL to ocidRawUrl's stringByRemovingPercentEncoding
	set strDecodedURL to ocidEncodedURL as text
	return strDecodedURL
end urlDecode
