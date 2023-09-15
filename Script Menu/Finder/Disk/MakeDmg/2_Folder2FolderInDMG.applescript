#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#@‘‚«o‚·c‚©‚çƒAƒvƒŠƒP[ƒVƒ‡ƒ“‚Å‘‚«o‚¹‚Î@ƒhƒƒbƒvƒŒƒbƒg‚Æ‚µ‚Ä‚àg‚¦‚Ü‚·
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application

on run
	### ƒ_ƒuƒ‹ƒNƒŠƒbƒN‚µ‚½‚ç@ƒXƒNƒŠƒvƒg‚©‚çÀs‚µ‚½‚ç
	set strMes to "‘I‘ğ‚µ‚½ƒtƒHƒ‹ƒ_‚ğDMGƒCƒ[ƒWƒtƒ@ƒCƒ‹‚É•ÏŠ·‚µ‚Ü‚·B"
	set aliasDefaultLocation to (path to fonts folder from user domain) as alias
	set listAliasDirPath to (choose folder strMes default location aliasDefaultLocation with prompt strMes with invisibles and multiple selections allowed without showing package contents) as list
	open listAliasDirPath
	
end run



on open listAliasDirPath
	#####y–‘Oˆ—zÅI“I‚ÉƒSƒ~” ‚É“ü‚ê‚éƒtƒHƒ‹ƒ_‚ğì‚é
	###ƒeƒ“ƒ|ƒ‰ƒŠ
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidTempDirURL to appFileManager's temporaryDirectory()
	set ocidUUID to refMe's NSUUID's alloc()'s init()
	set ocidUUIDString to ocidUUID's UUIDString
	set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
	###ƒtƒHƒ‹ƒ_‚ğì‚é
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 777-->511 755-->493 700-->448 766-->502 
	ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
	set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	
	###ƒGƒŠƒAƒX‚Ì”‚¾‚¯ŒJ‚è•Ô‚µ
	repeat with itemAliasDirPath in listAliasDirPath
		###y‚Pz“ü—ÍƒtƒHƒ‹ƒ_ƒpƒX
		set aliasDirPath to itemAliasDirPath as alias
		set strDirPath to (POSIX path of aliasDirPath) as text
		set ocidDirPathStr to (refMe's NSString's stringWithString:(strDirPath))
		set ocidDirPath to ocidDirPathStr's stringByStandardizingPath()
		set ocidDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDirPath) isDirectory:true)
		###ƒtƒ@ƒCƒ‹‚ªƒhƒƒbƒv‚³‚ê‚½ê‡‘Î‰
		set listBoolIsDir to (ocidDirPathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		if (item 2 of listBoolIsDir) = (refMe's NSNumber's numberWithBool:false) then
			log "ƒfƒBƒŒƒNƒgƒŠˆÈŠO‚Íˆ—‚µ‚Ü‚¹‚ñ"
			display alert "ƒfƒBƒŒƒNƒgƒŠˆÈŠO‚Íˆ—‚µ‚Ü‚¹‚ñ"
			return "ƒfƒBƒŒƒNƒgƒŠˆÈŠO‚Íˆ—‚µ‚Ü‚¹‚ñ"
			exit repeat
		end if
		
		###ƒtƒHƒ‹ƒ_‚Ì–¼‘O
		set recordFileInfo to info for aliasDirPath
		set strFolderName to (name of recordFileInfo) as text
		set strDMGname to (strFolderName & ".dmg") as text
		
		###y‚Qz“ü—ÍƒtƒHƒ‹ƒ_‚ÌƒRƒ“ƒeƒiƒfƒBƒŒƒNƒgƒŠ
		set ocidContainerDirPathURL to ocidDirPathURL's URLByDeletingLastPathComponent()
		set aliasContainerDirPath to (ocidContainerDirPathURL's absoluteURL()) as alias
		
		###y‚RzÅI“I‚Éo—ˆã‚ª‚Á‚½DMGƒtƒ@ƒCƒ‹‚ğˆÚ“®‚³‚¹‚éƒpƒX
		###DMG‚É‚È‚éƒtƒHƒ‹ƒ_•Û‘¶ƒpƒX
		set ocidMoveDmgPathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:(strDMGname) isDirectory:false)
		
		###y‚Szƒeƒ“ƒ|ƒ‰ƒŠ“à‚ÅDMGƒtƒ@ƒCƒ‹‚ğ¶¬‚·‚éƒpƒX
		###DMG‚ğì¬‚·‚éURL
		set ocidDmgPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strDMGname) isDirectory:false)
		###ƒRƒ}ƒ“ƒh—p‚ÌƒpƒX
		set strDmgPath to ocidDmgPathURL's |path| as text
		
		###y‚Tzƒeƒ“ƒ|ƒ‰ƒŠ“à@DMG‚Ì–{‘Ì‚Æ‚È‚éƒfƒBƒŒƒNƒgƒŠ@
		###DMG‚É‚È‚éƒtƒHƒ‹ƒ_
		set ocidMakeTmpDirPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strFolderName) isDirectory:false)
		###ƒRƒ}ƒ“ƒh—p‚ÌƒpƒX
		set strMakeDmgDirPath to ocidMakeTmpDirPathURL's |path| as text
		###ƒtƒHƒ‹ƒ_‚ğì‚é
		set listDone to (appFileManager's createDirectoryAtURL:(ocidMakeTmpDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		###y6zª‚T‚Åì‚Á‚½ƒtƒHƒ‹ƒ_“à‚É‚P‚ÌƒtƒHƒ‹ƒ_‚ğƒRƒs[‚·‚é‚½‚ß‚ÌƒpƒX
		###Œ³ƒtƒHƒ‹ƒ_‚ğƒRƒs[‚·‚éæ‚ÌURL
		set ocidCopyItemDirPathURL to (ocidMakeTmpDirPathURL's URLByAppendingPathComponent:(strFolderName) isDirectory:true)
		###y‚Vz‚P‚ÌURL‚ğ‚U‚ÌURL‚ÉƒRƒs[‚·‚é
		set listDone to (appFileManager's copyItemAtURL:(ocidDirPathURL) toURL:(ocidCopyItemDirPathURL) |error|:(reference))
		###
		delay 1
		###y‚WzƒRƒ}ƒ“ƒh®Œ`‚µ‚ÄÀs
		set strCommandText to ("/usr/bin/hdiutil create -volname €"" & strFolderName & "€" -srcfolder €"" & strMakeDmgDirPath & "€" -ov -format UDRO €"" & strDmgPath & "€"") as text
		log strCommandText
		do shell script strCommandText
		delay 1
		###y‚Xz‚S‚ÌURL‚É¶¬‚³‚ê‚½DMGƒtƒ@ƒCƒ‹‚ğ@‚R‚ÌURL‚ÉˆÚ“®‚·‚é
		set listDone to (appFileManager's moveItemAtURL:(ocidDmgPathURL) toURL:(ocidMoveDmgPathURL) |error|:(reference))
		
	end repeat
	####DMGì¬ˆ—‚ªI‚í‚Á‚½‚ç
	###•Û‘¶æ‚ğŠJ‚­
	tell application "Finder"
		open aliasContainerDirPath
	end tell
	
	####y‚P‚Oz–‘Oˆ—‚Åì‚Á‚½ƒtƒHƒ‹ƒ_‚ğƒSƒ~” ‚É“ü‚ê‚é
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSTrashDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidTrashURL to ocidURLsArray's firstObject()
	set ocidMoveTrashDirURL to (ocidTrashURL's URLByAppendingPathComponent:(strFolderName) isDirectory:true)
	set listDone to appFileManager's trashItemAtURL:(ocidSaveDirPathURL) resultingItemURL:(ocidMoveTrashDirURL) |error|:(reference)
	return "ˆ—I—¹"
end open



