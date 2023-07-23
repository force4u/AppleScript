#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()


###保存先 ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:(true) attributes:(missing value) |error|:(reference)


########################
######route
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("SystemInfo.rtf") isDirectory:true
set strSaveFilePath to ocidSaveFilePathURL's |path| as text
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
set recordSysInfo to (run script "return system info") as record

set recordSysInfoR to {|AppleScript version|:AppleScript version of (recordSysInfo), |AppleScript Studio version|:AppleScript Studio version of (recordSysInfo), |system version|:system version of (recordSysInfo), |short user name|:short user name of (recordSysInfo), |long user name|:long user name of (recordSysInfo), |user ID|:user ID of (recordSysInfo), |user locale|:user locale of (recordSysInfo), |home directory|:home directory of (recordSysInfo), |boot volume|:boot volume of (recordSysInfo), |computer name|:computer name of (recordSysInfo), |host name|:host name of (recordSysInfo), |IPv4 address|:IPv4 address of (recordSysInfo), |primary Ethernet address|:primary Ethernet address of (recordSysInfo), |CPU type|:CPU type of (recordSysInfo), |CPU speed|:CPU speed of (recordSysInfo), |physical memory|:physical memory of (recordSysInfo)} as record


set ocidSystemInfoDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidSystemInfoDict's setDictionary:(recordSysInfoR)

set ocidAllKeys to ocidSystemInfoDict's allKeys()

set strResponse to "" as text
repeat with itemKeys in ocidAllKeys
	set strKeys to itemKeys as text
	set strValue to (ocidSystemInfoDict's valueForKey:(itemKeys)) as text
	set strResponse to (strKeys & "：" & strValue & "\r" & strResponse) as text
end repeat


tell application "TextEdit"
	activate
	properties
	set objNewDoc to (make new document with properties {name:"SystemInfo", text:strResponse, path:strSaveFilePath})
	tell objNewDoc
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
	save objNewDoc in aliasSaveFilePath
end tell

########################
######ndp
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("ifconfig.me.rtf") isDirectory:true
set strSaveFilePath to ocidSaveFilePathURL's |path| as text
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
set strCommandText to "/bin/echo $(/usr/bin/curl -s ifconfig.me)" as text
set strResponse to (do shell script strCommandText) as text

set strResponse to (strCommandText & "\r" & strResponse) as text
tell application "TextEdit"
	activate
	properties
	set objNewDoc to (make new document with properties {name:"ifconfig.me", text:strResponse, path:strSaveFilePath})
	tell objNewDoc
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
	save objNewDoc in aliasSaveFilePath
end tell



########################
######networksetup
set strResponse to "" as text
set strCommandText to "/usr/sbin/networksetup  -listallnetworkservices"
set strResults to (do shell script strCommandText) as text
###戻り値を改行でリストに
set ocidListallnetworkservices to refMe's NSString's stringWithString:(strResults)
set ocidChrSet to refMe's NSCharacterSet's characterSetWithCharactersInString:("\r")
set ocidNetworkNameArray to ocidListallnetworkservices's componentsSeparatedByCharactersInSet:(ocidChrSet)
(ocidNetworkNameArray's removeObjectAtIndex:(0))
set strMacAdd to "" as text
repeat with itemNetworkName in ocidNetworkNameArray
	set strServiceName to itemNetworkName as text
	###コマンド生成　実行
	set strCommandText to "/usr/sbin/networksetup  -getinfo \"" & strServiceName & "\"" as text
	set strComResponse to (do shell script strCommandText) as text
	set strResponse to strServiceName & "\r" & strComResponse & "\r-------\r" & strResponse as text
end repeat



set ocidSaveFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:("networksetup.rtf") isDirectory:true)
set strSaveFilePath to ocidSaveFilePathURL's |path| as text
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
tell application "TextEdit"
	activate
	properties
	set objNewDoc to (make new document with properties {name:"networksetup", text:strResponse, path:strSaveFilePath})
	tell objNewDoc
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
	save objNewDoc in aliasSaveFilePath
end tell




########################
######airport
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("airport-i.rtf") isDirectory:true
set strSaveFilePath to ocidSaveFilePathURL's |path| as text
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
set strCommandText to "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I" as text
set strResponse to (do shell script strCommandText) as text
tell application "TextEdit"
	activate
	properties
	set objNewDoc to (make new document with properties {name:"airport-I", text:strResponse, path:strSaveFilePath})
	tell objNewDoc
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
	save objNewDoc in aliasSaveFilePath
end tell
########################
######getpacket
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("getpacket.rtf") isDirectory:true
set strSaveFilePath to ocidSaveFilePathURL's |path| as text
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
set strCommandText to "/usr/sbin/ipconfig getpacket en0" as text
set strResponse to (do shell script strCommandText) as text
tell application "TextEdit"
	activate
	properties
	set objNewDoc to (make new document with properties {name:"getpacket", text:strResponse, path:strSaveFilePath})
	tell objNewDoc
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
	
	save objNewDoc in aliasSaveFilePath
end tell

########################
######getpacket
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("ifconfigA.rtf") isDirectory:true
set strSaveFilePath to ocidSaveFilePathURL's |path| as text
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
set strCommandText to "/sbin/ifconfig -a" as text
set strResponse to (do shell script strCommandText) as text
tell application "TextEdit"
	activate
	properties
	set objNewDoc to (make new document with properties {name:"ifconfig", text:strResponse, path:strSaveFilePath})
	tell objNewDoc
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
	
	save objNewDoc in aliasSaveFilePath
end tell

########################
######getpacket
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("arp.rtf") isDirectory:true
set strSaveFilePath to ocidSaveFilePathURL's |path| as text
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as «class furl»
set strCommandText to "/usr/sbin/arp -a" as text
set strResponse to (do shell script strCommandText) as text
tell application "TextEdit"
	activate
	properties
	set objNewDoc to (make new document with properties {name:"arp", text:strResponse, path:strSaveFilePath})
	tell objNewDoc
		tell its text
			set its font to "Osaka-mono"
			set its size to 14
		end tell
	end tell
	
	save objNewDoc in aliasSaveFilePath
end tell
