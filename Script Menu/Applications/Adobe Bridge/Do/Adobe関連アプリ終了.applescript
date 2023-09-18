#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# AdobeÇÃä÷òAÉAÉvÉäÇÃã≠êßèIóπóp
# êÊÇ…éÂóvÇ»ÉAÉvÉäÇÕèIóπÇ≥ÇπÇƒÇ©ÇÁÅ@ó·Ç¶ÇŒAcrobatÇÕèIóπÇ≥ÇπÇƒÇ©ÇÁé¿çs
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application

set listBundleID to {"com.adobe.ccd.helper", "com.adobe.acc.AdobeCreativeCloud", "com.adobe.Creative-Cloud-Desktop-App", "com.adobe.CCXProcess", "com.adobe.acc.HEXHelper", "com.adobe.acc.HEXHelper.GPU", "com.adobe.acc.HEXHelper.Renderer", "com.adobe.Install", "com.adobe.ACCC.Uninstaller", "com.adobe.accmac", "com.adobe.AdobeCRDaemon", "com.adobe.crashreporter", "com.adobe.LogTransport.LogTransport", "com.Adobe.Installers.AdobeLogCollectorTool", "com.adobe.cc.Adobe-Creative-Cloud-Diagnostics", "com.adobe.ccd.troubleshooter", "com.adobe.acc.CCDContainer", "com.adobe.ARMDCHelper", "com.adobe.AcroLicApp", "com.adobe.HDUninstaller", "com.adobe.ARMDC", "com.adobe.AdobeApplicationUpdater", "com.adobe.acc.AdobeDesktopService", "com.adobe.ngl.p7helper", "com.adobe.adobe_licutil", "com.adobe.AdobeIPCBroker", "com.adobe.CCLibrary", "Adobe.UnifiedPluginInstallerAgent", "com.adobe.Acrobat.NativeMessagingHost", "com.adobe.AdobeRNAWebInstaller", "com.adobe.AdobeAcroCEFHelper", "com.adobe.AdobeAcroCEFHelperRenderer", "com.adobe.AdobeAcroCEFHelperGPU", "com.adobe.AdobeResourceSynchronizer", "com.adobe.AdobeRdrCEF", "com.adobe.AdobeAcroRdrCEFHelperRenderer", "com.adobe.AdobeAcroRdrCEFHelperGPU", "com.adobe.acrobat.assert", "com.adobe.photodownloader", "com.adobe.cep.CEPHtmlEngine Helper (GPU)", "com.adobe.cep.CEPHtmlEngine Helper (Plugin)", "com.adobe.cep.CEPHtmlEngine Helper (Renderer)", "com.adobe.cep.CEPHtmlEngine Helper", "com.adobe.cep.CEPHtmlEngine", "com.adobe.dynamiclinkmanager.application", "com.adobe.dynamiclinkmanager.application", "com.adobe.dynamiclinkmediaserver.application", "com.adobe.ImporterREDServer.application", "com.adobe.headlights.LogTransport2App", "com.adobe.bridge12", "com.adobe.bridge13", "com.adobe.bridge14", "com.adobe.dynamiclinkmediaserver.application", "com.adobe.dynamiclinkmanager.application", "com.adobe.ImporterREDServer.application", "com.adobe.photodownloader", "com.adobe.cep.CEPHtmlEngine", "com.adobe.cep.CEPHtmlEngine Helper (Renderer)", "com.adobe.cep.CEPHtmlEngine Helper", "com.adobe.cep.CEPHtmlEngine Helper (GPU)", "com.adobe.cep.CEPHtmlEngine Helper (Plugin)", "com.adobe.headlights.LogTransport2App", "com.adobe.headlights.HLCrashProcessorApp", "com.adobe.LogTransport.LogTransport", "com.adobe.AdobeCRDaemon", "com.adobe.crashreporter"} as list

set listProcessName to {"Adobe Desktop Service", "Core Sync", "Creative Cloud", "Creative Cloud Helper", "CCXProcess", "CCLibrary", "Core Sync Helper", "Creative Cloud Content Manager.node", "AdobeIPCBroker", "AGSService", "AGMService", "AdobeCRDaemon", "Adobe CEF Helper", "Adobe CEF Helper (GPU)", "Adobe CEF Helper (Renderer)", "AdobeExtensionsService", "AdobeResourceSynchronizer", "AdobeGCClient", "Adobe Installer", "com.adobe.acc.installer.v2", "Adobe Acrobat Synchronizer", "Adobe FormsCentral", "com.adobe.ARMDC.Communicator", "com.adobe.ARMDC.SMJobBlessHelper", "Adobe Content Synchronizer", "Adobe Crash Handler", "Adobe Bridge 2024", "dynamiclinkmediaserver", "dynamiclinkmanager", "ImporterREDServer", "Photo Downloader", "CEPHtmlEngine", "CEPHtmlEngine Helper (Renderer)", "CEPHtmlEngine Helper", "CEPHtmlEngine Helper (GPU)", "CEPHtmlEngine Helper (Plugin)", "LogTransport2", "HLCrashProcessor", "LogTransport", "Adobe Crash Processor", "Adobe Crash Reporter"} as list

###Ç‹Ç∏ÇÕí èÌèIóπ ÇééÇ›ÇÈ
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	try
		with timeout of 3 seconds
			tell application id strBundleID to quit
		end timeout
	on error
		log "èIóπèoóàÇ»Ç©Ç¡ÇΩ:" & strBundleID
	end try
end repeat

###í èÌèIóπ
log "í èÌèIóπäJén"
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID))
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate
	end repeat
end repeat
log "ã≠êßèIóπäJén"
###ã≠êßèIóπ
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID))
	repeat with itemAppArray in ocidAppArray
		itemAppArray's forceTerminate
	end repeat
end repeat


###écÇËÇ™ÇøÇ»Adobe Crash HandlerÇKILL
set strCommandText to ("/bin/ps -alx  | /usr/bin/grep Ä"Adobe Crash HandlerÄ" | /usr/bin/grep -v grep|  /usr/bin/awk -F' ' '{print $2}'") as text
set strResponse to (do shell script strCommandText) as text

set AppleScript's text item delimiters to "Är"
set listPID to every text item of strResponse
set AppleScript's text item delimiters to ""

repeat with itemPID in listPID
	set strPID to itemPID as text
	set strCommandText to ("/bin/kill -9 " & strPID & "") as text
	do shell script strCommandText
end repeat

###îOì¸ÇÍ

repeat with itemProcessName in listProcessName
	set strProcessName to itemProcessName as text
	set strCommandText to ("/bin/ps -alx  | /usr/bin/grep Ä"" & strProcessName & "Ä" | /usr/bin/grep -v grep|  /usr/bin/awk -F' ' '{print $2}'") as text
	set strResponse to (do shell script strCommandText) as text
	
	set AppleScript's text item delimiters to "Är"
	set listPID to every text item of strResponse
	set AppleScript's text item delimiters to ""
	
	repeat with itemPID in listPID
		set strPID to itemPID as text
		set strCommandText to ("/bin/kill -9 " & strPID & "") as text
		do shell script strCommandText
	end repeat
	
end repeat



