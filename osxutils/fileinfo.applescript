#!/usr/bin/env osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions


on run (argFilePath)
	if (argFilePath as text) is "" then
		log doPrintHelp()
		return 0
	end if
	set appFileManager to current application's NSFileManager's defaultManager()
	set strFilePath to (POSIX path of argFilePath) as text
	set ocidFilePathStr to current application's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (current application's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	set ocidFileName to ocidFilePathURL's lastPathComponent()
	#
	set listResponse to ocidFilePathURL's getResourceValue:(reference) forKey:(current application's NSURLContentTypeKey) |error|:(reference)
	set ocidUTType to (item 2 of listResponse)
	set ocidUTIArray to (ocidUTType's supertypes())'s allObjects()
	set ocidUTTypeString to current application's NSMutableString's alloc()'s initWithCapacity:(0)
	repeat with itemUTI in ocidUTIArray
		(ocidUTTypeString's appendString:(itemUTI's identifier()))
		(ocidUTTypeString's appendString:("\n\t\t"))
	end repeat
	set ocidUTI to ocidUTType's identifier()
	(ocidUTTypeString's appendString:(ocidUTI))
	(ocidUTTypeString's appendString:("\n"))
	#
	set listResponse to ocidFilePathURL's getResourceValue:(reference) forKey:(current application's NSURLTotalFileSizeKey) |error|:(reference)
	set ocidTotalFileSize to (item 2 of listResponse)
	set numLong to ocidTotalFileSize's unsignedLongLongValue()
	set numByteUnits to 1000 as integer
	set sizeInKB to (numLong / numByteUnits)
	set sizeInMB to (numLong / (numByteUnits * numByteUnits))
	set sizeInGB to (numLong / (numByteUnits * numByteUnits * numByteUnits))
	set sizeInTB to (numLong / (numByteUnits * numByteUnits * numByteUnits * numByteUnits))
	if (sizeInTB as integer) > 0 then
		set strTotalFileSize to ((sizeInTB as integer) & " TB") as text
	else if (sizeInGB as integer) > 0 then
		set strTotalFileSize to ((sizeInGB as integer) & " GB") as text
	else if (sizeInMB as integer) > 0 then
		set strTotalFileSize to ((sizeInMB as integer) & " MB") as text
	else
		set strTotalFileSize to ((sizeInKB as integer) & " KB") as text
	end if
	set strRealFileSize to ((numLong as integer) & " Bytes") as text
	#
	set listResponse to ocidFilePathURL's getResourceValue:(reference) forKey:(current application's NSURLTotalFileAllocatedSizeKey) |error|:(reference)
	set ocidAllocatedSize to (item 2 of listResponse)
	set numLong to ocidAllocatedSize's unsignedLongLongValue()
	set numByteUnits to 1000 as integer
	set sizeInKB to (numLong / numByteUnits)
	set sizeInMB to (numLong / (numByteUnits * numByteUnits))
	set sizeInGB to (numLong / (numByteUnits * numByteUnits * numByteUnits))
	set sizeInTB to (numLong / (numByteUnits * numByteUnits * numByteUnits * numByteUnits))
	if (sizeInTB as integer) > 0 then
		set strAllocatedSize to ((sizeInTB as integer) & " TB") as text
	else if (sizeInGB as integer) > 0 then
		set strAllocatedSize to ((sizeInGB as integer) & " GB") as text
	else if (sizeInMB as integer) > 0 then
		set strAllocatedSize to ((sizeInMB as integer) & " MB") as text
	else if (sizeInKB as integer) > 0 then
		set strAllocatedSize to ((sizeInKB as integer) & " KB") as text
	else
		set strAllocatedSize to ((numLong as integer) & " Bytes") as text
	end if
	#
	set listResponse to ocidFilePathURL's getResourceValue:(reference) forKey:(current application's NSURLCreationDateKey) |error|:(reference)
	set ocidCreationDate to (item 2 of listResponse)
	set strCreationDate to (ocidCreationDate as date) as text
	#
	set listResponse to ocidFilePathURL's getResourceValue:(reference) forKey:(current application's NSURLContentModificationDateKey) |error|:(reference)
	set ocidModificationDate to (item 2 of listResponse)
	set strModificationDate to (ocidModificationDate as date) as text
	#
	set listResponse to ocidFilePathURL's getResourceValue:(reference) forKey:(current application's NSURLContentAccessDateKey) |error|:(reference)
	set ocidAccessDate to (item 2 of listResponse)
	set strAccessDate to (ocidAccessDate as date) as text
	#
	set listResponse to ocidFilePathURL's getResourceValue:(reference) forKey:(current application's NSURLAttributeModificationDateKey) |error|:(reference)
	set ocidAttributeDate to (item 2 of listResponse)
	set strAttributeDate to (ocidAttributeDate as date) as text
	#
	set listResponse to appFileManager's attributesOfItemAtPath:(ocidFilePath) |error|:(reference)
	set ocidAttarDict to (item 1 of listResponse)
	set ocidOwnerAccount to ocidAttarDict's valueForKey:(current application's NSFileOwnerAccountName)
	set ocidGroupOwner to ocidAttarDict's valueForKey:(current application's NSFileGroupOwnerAccountName)
	set ocidPosixPermissionsDec to ocidAttarDict's valueForKey:(current application's NSFilePosixPermissions)
	#
	set numPermissionsDec to (ocidPosixPermissionsDec as text) as number
	set numDecNo to numPermissionsDec as number
	set numDiv1 to (numDecNo div 8) as number
	set numMod1 to (numDecNo mod 8) as number
	set numDiv2 to (numDiv1 div 8) as number
	set numMod2 to (numDiv1 mod 8) as number
	set numDiv3 to (numDiv2 div 8) as number
	set numMod3 to (numDiv2 mod 8) as number
	set strOctal to (numMod3 & numMod2 & numMod1) as text
	set numPosixPermissionsOct to strOctal as number
	#
	set ocidExtendedAttriDec to ocidAttarDict's objectForKey:("NSFileExtendedAttributes")
	set ocidAllKeys to ocidExtendedAttriDec's allKeys()
	set strAttarItems to (ocidAllKeys's componentsJoinedByString:("\n\t")) as text
	#
	set ocidExtendedAttriDec to ocidAttarDict's objectForKey:("NSFileExtendedAttributes")
	set ocidAllKeys to ocidExtendedAttriDec's allKeys()
	#
	set boolContain to ocidAllKeys's containsObject:("com.apple.metadata:kMDItemFinderComment")
	if boolContain is true then
		set ocidSwiftData to ocidExtendedAttriDec's objectForKey:("com.apple.metadata:kMDItemFinderComment")
		set appPlistSerial to current application's NSPropertyListSerialization
		set ocidFormat to current application's NSPropertyListXMLFormat_v1_0
		set ocidOption to current application's NSPropertyListMutableContainersAndLeaves
		set listResponse to appPlistSerial's propertyListWithData:(ocidSwiftData) options:(ocidOption) format:(ocidFormat) |error|:(reference)
		set ocidNSSwiftDataString to (item 1 of listResponse)
		set strFinderComment to ocidNSSwiftDataString as text
	else
		set strFinderComment to ""
	end if
	#
	set ocidOutputString to current application's NSMutableString's alloc()'s initWithCapacity:(0)
	(ocidOutputString's appendString:("ファイルパス名: "))
	(ocidOutputString's appendString:(ocidFileName))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("ファイルパス: "))
	(ocidOutputString's appendString:(ocidFilePath))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("ファイルタイプ: "))
	(ocidOutputString's appendString:(ocidUTTypeString))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("ファイルサイズ: "))
	(ocidOutputString's appendString:(strTotalFileSize))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("使用ディスクサイズ: "))
	(ocidOutputString's appendString:(strAllocatedSize))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("実サイズ: "))
	(ocidOutputString's appendString:(strRealFileSize))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("拡張属性: "))
	(ocidOutputString's appendString:(strAttarItems))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("作成日: "))
	(ocidOutputString's appendString:(strCreationDate))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("修正日: "))
	(ocidOutputString's appendString:(strModificationDate))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("直近アクセス日: "))
	(ocidOutputString's appendString:(strAccessDate))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("属性変更日: "))
	(ocidOutputString's appendString:(strAttributeDate))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("所有者: "))
	(ocidOutputString's appendString:(ocidOwnerAccount))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("グループ: "))
	(ocidOutputString's appendString:(ocidGroupOwner))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("アクセス権10進数: "))
	(ocidOutputString's appendString:(numPermissionsDec as text))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("アクセス権8進数: "))
	(ocidOutputString's appendString:(numPosixPermissionsOct as text))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("\n"))
	(ocidOutputString's appendString:("Finderコメント: "))
	(ocidOutputString's appendString:(strFinderComment))
	(ocidOutputString's appendString:("\n"))
	
	return ocidOutputString as text
end run


on doPrintHelp()
	set strHelpText to ("\n基本的なファイル情報を取得表示します\n使用方法:\nfileinfo.applescript /パス/ファイル\n引数:\n  /パス/ファイル 対象のファイルの情報を表示します\n例:\n\tfileinfo.applescript /some/file \n注意:\n フォルダを指定すると一部表示されません\n\n") as text
	return strHelpText
end doPrintHelp