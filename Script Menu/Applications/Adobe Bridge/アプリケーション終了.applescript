#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# Adobe‚ÌŠÖ˜AƒAƒvƒŠ‚Ì‹­§I—¹—p
# æ‚Éå—v‚ÈƒAƒvƒŠ‚ÍI—¹‚³‚¹‚Ä‚©‚ç@—á‚¦‚ÎAcrobat‚ÍI—¹‚³‚¹‚Ä‚©‚çÀs
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application

set listBundleID to {"com.adobe.bridge12", "com.adobe.bridge13", "com.adobe.bridge14", "com.adobe.dynamiclinkmediaserver.application", "com.adobe.dynamiclinkmanager.application", "com.adobe.ImporterREDServer.application", "com.adobe.photodownloader", "com.adobe.cep.CEPHtmlEngine", "com.adobe.cep.CEPHtmlEngine Helper (Renderer)", "com.adobe.cep.CEPHtmlEngine Helper", "com.adobe.cep.CEPHtmlEngine Helper (GPU)", "com.adobe.cep.CEPHtmlEngine Helper (Plugin)", "com.adobe.headlights.LogTransport2App", "com.adobe.headlights.HLCrashProcessorApp", "com.adobe.LogTransport.LogTransport", "com.adobe.AdobeCRDaemon", "com.adobe.crashreporter"} as list

set listProcessName to {"Adobe Bridge 2024", "dynamiclinkmediaserver", "dynamiclinkmanager", "ImporterREDServer", "Photo Downloader", "CEPHtmlEngine", "CEPHtmlEngine Helper (Renderer)", "CEPHtmlEngine Helper", "CEPHtmlEngine Helper (GPU)", "CEPHtmlEngine Helper (Plugin)", "LogTransport2", "HLCrashProcessor", "LogTransport", "Adobe Crash Processor", "Adobe Crash Reporter"} as list

###‚Ü‚¸‚Í’ÊíI—¹ ‚ğ‚İ‚é
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	try
		with timeout of 3 seconds
			tell application id strBundleID to quit
		end timeout
	on error
		log "I—¹o—ˆ‚È‚©‚Á‚½:" & strBundleID
	end try
end repeat

###’ÊíI—¹


log "’ÊíI—¹ŠJn"
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID))
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate
	end repeat
end repeat
log "‹­§I—¹ŠJn"
###‹­§I—¹
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID))
	repeat with itemAppArray in ocidAppArray
		itemAppArray's forceTerminate
	end repeat
end repeat


###c‚è‚ª‚¿‚ÈAdobe Crash Handler‚ğKILL
set strCommandText to ("/bin/ps -alx  | /usr/bin/grep €"Adobe Crash Handler€" | /usr/bin/grep -v grep|  /usr/bin/awk -F' ' '{print $2}'") as text
set strResponse to (do shell script strCommandText) as text

set AppleScript's text item delimiters to "€r"
set listPID to every text item of strResponse
set AppleScript's text item delimiters to ""

repeat with itemPID in listPID
	set strPID to itemPID as text
	set strCommandText to ("/bin/kill -9 " & strPID & "") as text
	do shell script strCommandText
end repeat

###”O“ü‚ê

repeat with itemProcessName in listProcessName
	set strProcessName to itemProcessName as text
	set strCommandText to ("/bin/ps -alx  | /usr/bin/grep €"" & strProcessName & "€" | /usr/bin/grep -v grep|  /usr/bin/awk -F' ' '{print $2}'") as text
	set strResponse to (do shell script strCommandText) as text
	
	set AppleScript's text item delimiters to "€r"
	set listPID to every text item of strResponse
	set AppleScript's text item delimiters to ""
	
	repeat with itemPID in listPID
		set strPID to itemPID as text
		set strCommandText to ("/bin/kill -9 " & strPID & "") as text
		do shell script strCommandText
	end repeat
	
end repeat



