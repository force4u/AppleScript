#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#@‘‚«o‚·c‚©‚çƒAƒvƒŠƒP[ƒVƒ‡ƒ“‚Å‘‚«o‚¹‚Î@ƒhƒƒbƒvƒŒƒbƒg‚Æ‚µ‚Ä‚àg‚¦‚Ü‚·
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

on run
	set strMes to "‘I‘ğ‚µ‚½ƒtƒHƒ‹ƒ_‚ğDMGƒCƒ[ƒWƒtƒ@ƒCƒ‹‚É•ÏŠ·‚µ‚Ü‚·B"
	set aliasDefaultLocation to (path to fonts folder from user domain) as alias
	set listAliasDirPath to (choose folder strMes default location aliasDefaultLocation with prompt strMes with invisibles and multiple selections allowed without showing package contents) as list
	open listAliasDirPath
end run



on open listAliasDirPath
	###ƒGƒŠƒAƒX‚Ì”‚¾‚¯ŒJ‚è•Ô‚µ
	repeat with itemAliasDirPath in listAliasDirPath
		###“ü—ÍƒpƒX
		set aliasDirPath to itemAliasDirPath as alias
		set strDirPath to (POSIX path of aliasDirPath) as text
		###ƒtƒHƒ‹ƒ_‚Ì–¼‘O
		set recordFileInfo to info for aliasDirPath
		set strFolderName to (name of recordFileInfo) as text
		log recordFileInfo
		if (kind of recordFileInfo) is "ƒtƒHƒ‹ƒ_" then
			##‚»‚Ì‚Ü‚Üˆ—
		else if (kind of recordFileInfo) is folder then
			##‚»‚Ì‚Ü‚Üˆ—
		else
			log "ƒfƒBƒŒƒNƒgƒŠˆÈŠO‚Íˆ—‚µ‚Ü‚¹‚ñ"
			display alert "ƒfƒBƒŒƒNƒgƒŠˆÈŠO‚Íˆ—‚µ‚Ü‚¹‚ñ"
			return "ƒfƒBƒŒƒNƒgƒŠˆÈŠO‚Íˆ—‚µ‚Ü‚¹‚ñ"
			exit repeat
		end if
		return
		###‘I‚ñ‚¾ƒtƒHƒ‹ƒ_‚ÌƒRƒ“ƒeƒi
		tell application "Finder"
			set aliasContainerDirPath to (container of aliasDirPath) as alias
		end tell
		###DMG‚Ì–¼‘O
		set strDirName to (strFolderName & ".dmg")
		###o—ÍƒpƒX
		set strContainerDirPath to (POSIX path of aliasContainerDirPath) as text
		set strSaveFilePath to (strContainerDirPath & strDirName) as text
		###ƒRƒ}ƒ“ƒhÀs
		set strCommandText to ("hdiutil create -volname €"" & strFolderName & "€" -srcfolder €"" & strDirPath & "€" -ov -format UDRO €"" & strSaveFilePath & "€"") as text
		log strCommandText
		do shell script strCommandText
	end repeat
	
	###•Û‘¶æ‚ğŠJ‚­
	tell application "Finder"
		open aliasContainerDirPath
	end tell
	
end open



