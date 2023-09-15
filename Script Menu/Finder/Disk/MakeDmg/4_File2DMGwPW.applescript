#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#@‘‚«o‚·c‚©‚çƒAƒvƒŠƒP[ƒVƒ‡ƒ“‚Å‘‚«o‚¹‚Î@ƒhƒƒbƒvƒŒƒbƒg‚Æ‚µ‚Ä‚àg‚¦‚Ü‚·
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

on run
	#############################
	###y‹N“®ˆ—zWƒNƒŠƒbƒN‚µ‚½ê‡@ƒXƒNƒŠƒvƒg‚©‚çÀs‚µ‚½ê‡
	set appFileManager to refMe's NSFileManager's defaultManager()
	###ƒ_ƒCƒAƒƒO
	tell current application
		set strName to name as text
	end tell
	###ƒXƒNƒŠƒvƒgƒƒjƒ…[‚©‚çÀs‚µ‚½‚ç
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	### ƒfƒtƒHƒ‹ƒgƒƒP[ƒVƒ‡ƒ“
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
	set ocidFontsDirPathURL to (ocidLibraryDirPathURL's URLByAppendingPathComponent:("Fonts") isDirectory:true)
	set aliasDefaultLocation to (ocidFontsDirPathURL's absoluteURL()) as alias
	###ƒ_ƒCƒAƒƒO
	set strMes to "‘I‘ğ‚µ‚½ƒtƒ@ƒCƒ‹‚ğDMGƒCƒ[ƒWƒtƒ@ƒCƒ‹‚É•ÏŠ·‚µ‚Ü‚·B"
	set strPrompt to "‘I‘ğ‚µ‚½ƒtƒ@ƒCƒ‹‚ğDMGƒCƒ[ƒWƒtƒ@ƒCƒ‹‚É•ÏŠ·‚µ‚Ü‚·B"
	set listUTI to {"public.item"}
	set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles, multiple selections allowed and showing package contents) as list
	open listAliasFilePath
	
end run



on open listAliasFilePath
	#############################
	###y–‘Oˆ—z@ÅI“I‚ÉƒSƒ~” ‚É“ü‚ê‚éƒeƒ“ƒ|ƒ‰ƒŠƒtƒHƒ‹ƒ_‚Ì§’è
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
	repeat with itemAliasFilePath in listAliasFilePath
		#############################
		###y‚Pz@“ü—ÍƒpƒX
		set aliasFilePath to itemAliasFilePath as alias
		set strFilePath to (POSIX path of aliasFilePath) as text
		set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true)
		
		#############################
		###y‚Qzƒtƒ@ƒCƒ‹@‚Ìê‡@‚ÆƒtƒHƒ‹ƒ_‚Ìê‡‚Ì
		###ƒtƒ@ƒCƒ‹‚ªƒhƒƒbƒv‚³‚ê‚½ê‡‘Î‰
		set listBoolIsDir to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		###•ªŠò
		if (item 2 of listBoolIsDir) = (refMe's NSNumber's numberWithBool:false) then
			log "ƒtƒ@ƒCƒ‹‚Ìê‡"
			set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
			set ocidBaseFileName to ocidBaseFilePathURL's lastPathComponent()
			set strDMGname to ((ocidBaseFileName as text) & ".dmg") as text
			set strDmgVolumeName to ocidBaseFileName as text
			set strFolderName to ocidBaseFileName as text
			set strDistName to (ocidFilePathURL's lastPathComponent()) as text
		else
			###ƒtƒHƒ‹ƒ_‚Ìê‡
			###ƒtƒHƒ‹ƒ_‚Ì–¼‘O
			set recordFileInfo to info for aliasFilePath
			set strFolderName to (name of recordFileInfo) as text
			set strDMGname to (strFolderName & ".dmg") as text
			set strDmgVolumeName to strFolderName as text
			set strDistName to strFolderName as text
		end if
		
		#############################
		###y‚Rzƒeƒ“ƒ|ƒ‰ƒŠ[“à‚ÌDMG‚Ì–{‘Ì‚É‚È‚éƒtƒHƒ‹ƒ_
		###DMG‚É‚È‚éƒtƒHƒ‹ƒ_•Û‘¶ƒpƒX
		set ocidMakeTmpDirPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strFolderName) isDirectory:true)
		###ƒRƒ}ƒ“ƒh—p‚ÌƒpƒX
		set strMakeDmgDirPath to ocidMakeTmpDirPathURL's |path| as text
		###ƒtƒHƒ‹ƒ_‚ğì‚é
		set listDone to (appFileManager's createDirectoryAtURL:(ocidMakeTmpDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		
		################################
		####y‚SzÅI“I‚ÉDMG‚ğˆÚ“®‚·‚éƒfƒBƒŒƒNƒgƒŠ
		#### ˆÃ†‰»DMG‚Ì•Û‘¶æ
		set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
		set strFinishedDirName to (strFolderName & "_ˆÃ†‰»ÏDMG") as text
		set ocidFinishedDirPathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:(strFinishedDirName))
		###ƒtƒHƒ‹ƒ_‚ğì‚é
		set listDone to (appFileManager's createDirectoryAtURL:(ocidFinishedDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		###Finder—p
		set aliasOpenDirPath to (ocidFinishedDirPathURL's absoluteURL()) as alias
		
		#############################
		###y‚TzÅI“I‚ÉDMG‚ğˆÚ“®‚·‚éƒpƒX
		set ocidMoveDmgPathURL to (ocidFinishedDirPathURL's URLByAppendingPathComponent:(strDMGname))
		set strMoveDmgPath to (ocidMoveDmgPathURL's |path|()) as text
		
		########################################
		###y‚UzƒpƒXƒ[ƒh¶¬@UUID‚ğ—˜—p
		###¶¬‚µ‚½UUID‚©‚çƒnƒCƒtƒ“‚ğæ‚èœ‚­
		set ocidUUIDString to (refMe's NSMutableString's alloc()'s initWithCapacity:0)
		set ocidConcreteUUID to refMe's NSUUID's UUID()
		(ocidUUIDString's setString:(ocidConcreteUUID's UUIDString()))
		set ocidUUIDRange to (ocidUUIDString's rangeOfString:ocidUUIDString)
		(ocidUUIDString's replaceOccurrencesOfString:("-") withString:("") options:(refMe's NSRegularExpressionSearch) range:ocidUUIDRange)
		set strOwnerPassword to ocidUUIDString as text
		########################################
		###y‚Uz@ƒpƒXƒ[ƒhƒtƒ@ƒCƒ‹¶¬•Û‘¶
		set strPWFileName to strDMGname & ".PW.txt"
		set ocidPWFilePathURL to (ocidFinishedDirPathURL's URLByAppendingPathComponent:(strPWFileName))
		###ƒeƒLƒXƒg
		set strTextFile to "æ‚É‚¨‘—‚è‚µ‚Ü‚µ‚½ˆ³kƒtƒ@ƒCƒ‹€nw" & strDMGname & "x‚Ì€n‰ğ“€ƒpƒXƒ[ƒh‚ğ‚¨’m‚ç‚¹‚µ‚Ü‚·€n€n" & strOwnerPassword & "€n€n‰ğ“€o—ˆ‚È‚¢“™‚ ‚è‚Ü‚µ‚½‚ç‚¨’m‚ç‚¹‚­‚¾‚³‚¢B€n(ƒpƒXƒ[ƒh‚ğƒRƒs[•ƒy[ƒXƒg‚·‚éÛ‚É€n‰üs‚âƒXƒy[ƒX‚ª“ü‚ç‚È‚¢‚æ‚¤‚É—¯ˆÓ‚­‚¾‚³‚¢)€n" as text
		set ocidPWString to (refMe's NSString's stringWithString:(strTextFile))
		set ocidUUIDData to (ocidPWString's dataUsingEncoding:(refMe's NSUTF8StringEncoding))
		#####ƒpƒXƒ[ƒh‚ğ‘‚¢‚½ƒeƒLƒXƒgƒtƒ@ƒCƒ‹‚ğ•Û‘¶
		set boolResults to (ocidUUIDData's writeToURL:(ocidPWFilePathURL) atomically:true)
		
		#############################
		###y7z‚R‚Å¶¬‚µ‚½ƒtƒHƒ‹ƒ_‚É‚P‚Ì“à—e‚ğƒRƒs[‚·‚é‚½‚ß‚ÌURL
		###Œ³ƒtƒHƒ‹ƒ_‚ğƒRƒs[‚·‚éæ‚ÌURL
		set ocidCopyItemDirPathURL to (ocidMakeTmpDirPathURL's URLByAppendingPathComponent:(strDistName) isDirectory:true)
		###Œ³ƒfƒBƒŒƒNƒgƒŠ‚ğƒRƒs[‚·‚é
		set listDone to (appFileManager's copyItemAtURL:(ocidFilePathURL) toURL:(ocidCopyItemDirPathURL) |error|:(reference))
		
		#############################
		###y8zƒRƒ}ƒ“ƒh¶¬‚·‚éDMG‚ÌƒpƒX
		set ocidDmgPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strDMGname) isDirectory:false)
		set strDmgPath to (ocidDmgPathURL's |path|()) as text
		
		###
		delay 1
		#############################
		###y9zƒRƒ}ƒ“ƒhÀs DMG¶¬
		
		###“Ç‚İæ‚èê—p‚ÅDMGì¬
		set strCommandText to ("hdiutil create -volname €"" & strDmgVolumeName & "€" -srcfolder €"" & strMakeDmgDirPath & "€" -ov -format UDRO €"" & strDmgPath & "€"") as text
		
		log strCommandText
		do shell script strCommandText
		########################################
		###y10z‚S‚ÌURL‚É¶¬‚³‚ê‚½DMGƒtƒ@ƒCƒ‹‚ğ@‚U‚ÌURL‚ÉˆÚ“®‚·‚é
		###‚»‚Ì‚É¶¬‚µ‚½ƒpƒXƒ[ƒh‚ÅˆÃ†‰»‚·‚é		
		###‹Œd—l
		set strCommandText to ("/usr/bin/hdiutil convert €"" & strDmgPath & "€" -format UDRO -o  €"" & strMoveDmgPath & "€" -encryption AES-128 -passphrase " & strOwnerPassword & "") as text
		###Œ»sd—l
		set strCommandText to ("/usr/bin/printf " & strOwnerPassword & " | /usr/bin/hdiutil convert €"" & strDmgPath & "€" -format UDRO -o  €"" & strMoveDmgPath & "€" -encryption AES-128 -stdinpass") as text
		log strCommandText
		
				do shell script strCommandText
		
	end repeat
	####DMGì¬ˆ—‚ªI‚í‚Á‚½‚ç
	###•Û‘¶æ‚ğŠJ‚­
	(*
	tell application "Finder"
		open aliasOpenDirPath
	end tell
	*)
	########################################
	###y11z•Û‘¶æ‚ğŠJ‚­
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set boolDone to appSharedWorkspace's selectFile:(ocidMoveDmgPathURL's |path|()) inFileViewerRootedAtPath:(ocidFinishedDirPathURL's |path|())
	
	########################################
	###y12z’†ŠÔƒtƒ@ƒCƒ‹‚ğƒSƒ~” ‚É
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSTrashDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidTrashURL to ocidURLsArray's firstObject()
	set ocidMoveTrashDirURL to (ocidTrashURL's URLByAppendingPathComponent:(strFolderName) isDirectory:true)
	set listDone to appFileManager's trashItemAtURL:(ocidSaveDirPathURL) resultingItemURL:(ocidMoveTrashDirURL) |error|:(reference)
	
	
	
end open



