#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# Adobeの関連アプリの強制終了用
# 先に主要なアプリは終了させてから　例えばAcrobatは終了させてから実行
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application

set listBundleID to {"com.adobe.ccd.helper", "com.adobe.acc.AdobeCreativeCloud", "com.adobe.Creative-Cloud-Desktop-App", "com.adobe.CCXProcess", "com.adobe.acc.HEXHelper", "com.adobe.acc.HEXHelper.GPU", "com.adobe.acc.HEXHelper.Renderer", "com.adobe.Install", "com.adobe.ACCC.Uninstaller", "com.adobe.accmac", "com.adobe.AdobeCRDaemon", "com.adobe.crashreporter", "com.adobe.LogTransport.LogTransport", "com.Adobe.Installers.AdobeLogCollectorTool", "com.adobe.cc.Adobe-Creative-Cloud-Diagnostics", "com.adobe.ccd.troubleshooter", "com.adobe.acc.CCDContainer", "com.adobe.ARMDCHelper", "com.adobe.AcroLicApp", "com.adobe.HDUninstaller", "com.adobe.ARMDC", "com.adobe.AdobeApplicationUpdater", "com.adobe.acc.AdobeDesktopService", "com.adobe.ngl.p7helper", "com.adobe.adobe_licutil", "com.adobe.AdobeIPCBroker", "com.adobe.CCLibrary", "Adobe.UnifiedPluginInstallerAgent", "com.adobe.Acrobat.NativeMessagingHost", "com.adobe.AdobeRNAWebInstaller", "com.adobe.AdobeAcroCEFHelper", "com.adobe.AdobeAcroCEFHelperRenderer", "com.adobe.AdobeAcroCEFHelperGPU", "com.adobe.AdobeResourceSynchronizer", "com.adobe.AdobeRdrCEF", "com.adobe.AdobeAcroRdrCEFHelperRenderer", "com.adobe.AdobeAcroRdrCEFHelperGPU", "com.adobe.acrobat.assert", "com.adobe.photodownloader", "com.adobe.cep.CEPHtmlEngine Helper (GPU)", "com.adobe.cep.CEPHtmlEngine Helper (Plugin)", "com.adobe.cep.CEPHtmlEngine Helper (Renderer)", "com.adobe.cep.CEPHtmlEngine Helper", "com.adobe.cep.CEPHtmlEngine", "com.adobe.dynamiclinkmanager.application", "com.adobe.dynamiclinkmanager.application", "com.adobe.dynamiclinkmediaserver.application", "com.adobe.ImporterREDServer.application", "com.adobe.headlights.LogTransport2App"} as list

###まずは通常終了 を試みる
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	try
		with timeout of 3 seconds
			tell application id strBundleID to quit
		end timeout
	on error
		log "終了出来なかった:" & strBundleID
	end try
end repeat

###通常終了
log "通常終了開始"
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID))
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate
	end repeat
end repeat
log "強制終了開始"
###強制終了
repeat with itemBundleID in listBundleID
	set strBundleID to itemBundleID as text
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID))
	repeat with itemAppArray in ocidAppArray
		itemAppArray's forceTerminate
	end repeat
end repeat


###残りがちなAdobe Crash HandlerをKILL
set strCommandText to ("/bin/ps -alx  | /usr/bin/grep \"Adobe Crash Handler\" | /usr/bin/grep -v grep|  /usr/bin/awk -F' ' '{print $2}'") as text
set strResponse to (do shell script strCommandText) as text

set AppleScript's text item delimiters to "\r"
set listPID to every text item of strResponse
set AppleScript's text item delimiters to ""

repeat with itemPID in listPID
	set strPID to itemPID as text
	set strCommandText to ("/bin/kill -9 " & strPID & "") as text
	do shell script strCommandText
end repeat

