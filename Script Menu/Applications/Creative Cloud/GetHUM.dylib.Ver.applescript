#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

set strOtools to "/Library/Developer/CommandLineTools/usr/bin/llvm-otool" as text
try
	set aliasOtools to POSIX file strOtools as alias
on error
	try
		do shell script "/usr/bin/xcode-select --install"
	end try
	return "コマンドラインツールをインストールしてからもう一度"
end try

set objSysInfo to system info
set strCpuType to (CPU type of objSysInfo) as text

set strDylibPath to "/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/HUM.dylib"

if strCpuType contains "ARM" then
	set strCommand to ("/usr/bin/otool -arch arm64 -P  \"" & strDylibPath & "\"") as text
else
	set strCommand to ("/usr/bin/otool -arch x86_64 -P  \"" & strDylibPath & "\"") as text
end if
###コマンド実行
set strPlistStrings to (do shell script strCommand) as text
###テキストに
set ocidPlistStrings to refMe's NSString's stringWithString:(strPlistStrings)
###改行でリストにして
set ocidChrSet to refMe's NSCharacterSet's newlineCharacterSet()
set ocidPlistArray to ocidPlistStrings's componentsSeparatedByCharactersInSet:(ocidChrSet)
set numCntArray to count of ocidPlistArray
###１行目と２行目を除いた値がPLIST
set ocidRange to refMe's NSMakeRange(2, (numCntArray - 2))
set ocidPlistSubArray to ocidPlistArray's subarrayWithRange:(ocidRange)
###テキストに戻して
set ocidPlist to ocidPlistSubArray's componentsJoinedByString:"\n"
###データにして
set ocidPlistData to ocidPlist's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
###PLIST経由でDICTにして
set listPlistDict to refMe's NSPropertyListSerialization's propertyListWithData:(ocidPlistData) options:(refMe's NSPropertyListImmutable) format:(missing value) |error|:(reference)
set ocidPlistDict to item 1 of listPlistDict
###値を取り出す
set ocidVerSion to ocidPlistDict's valueForKey:"CFBundleVersion"

return "バージョンは" & (ocidVerSion as text)

