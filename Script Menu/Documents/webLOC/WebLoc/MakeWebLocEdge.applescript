#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

#########################
tell application "Microsoft Edge"
	set strTITLE to "" as text
	set strURL to "" as text
	set numCntWindow to (count of every window) as integer
end tell
###Edge�̃E�B���h�E�������Ȃ�_�C�A���O���o��
if numCntWindow < 1 then
	##�f�t�H���g�N���b�v�{�[�h����
	set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
	try
		set ocidPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
	on error
		set ocidPasteboardStrings to "" as text
	end try
	set strDefaultAnswer to ocidPasteboardStrings as text
else
	
	####�^�C�g���@�Ɓ@URL���擾
	tell application "Microsoft Edge"
		tell front window
			tell active tab
				set strURL to URL as text
				set strTITLE to title as text
			end tell
		end tell
	end tell
	set strDefaultAnswer to strURL as text
end if
################################
######�_�C�A���O
################################
#####�_�C�A���O��O�ʂ�
tell current application
	set strName to name as text
end tell
####�X�N���v�g���j���[������s������
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns") as alias
try
	set recordResponse to (display dialog "WEB�y�[�W��URL����͂��Ă��������n��F�nhttps://news.yahoo.co.jp�nhttp://localhost:631�nhttps://www.google.com/search?q=����" with title "URL����͂��Ă�������" default answer strDefaultAnswer buttons {"OK", "�L�����Z��"} default button "OK" cancel button "�L�����Z��" with icon aliasIconPath giving up after 20 without hidden answer)
on error
	log "�G���[���܂���"
	return "�G���[���܂���"
end try
if true is equal to (gave up of recordResponse) then
	return "���Ԑ؂�ł����Ȃ����Ă�������"
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else
	log "�L�����Z�����܂���"
	return "�L�����Z�����܂���"
end if
#########################
###�^�u�Ɖ��s���������Ă���
set ocidResponseText to refMe's NSString's stringWithString:(strResponse)
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidTextM's appendString:(ocidResponseText)
##���s����
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("�n") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("�r") withString:("")
##�^�u����
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("�t") withString:("")
set strResponse to ocidTextM as text
if strResponse starts with "http" then
	###URL�����łɃG���R�[�h����Ă��邩�H�̊m�F
	set ocidChkURL to refMe's NSURL's alloc()'s initWithString:(ocidTextM)
else
	return "httpURL�ȊO�͏������Ȃ�"
end if
#########################
###
if ocidChkURL = (missing value) then
	##URL
	set strURL to doUrlDecode(strURL)
	##�e�L�X�g
	set ocidArgText to refMe's NSString's stringWithString:(strURL)
	set ocidArgTextArray to ocidArgText's componentsSeparatedByString:("?")
	set numCntArray to (count of ocidArgTextArray) as integer
	####�N�G���[������ꍇ
	if numCntArray > 1 then
		###�ŏ���Arrayitem��URL��
		set ocidBaseURLstr to ocidArgTextArray's firstObject()
		ocidArgTextArray's removeObjectAtIndex:(0)
		####�ŏ���?�ȍ~���N�G���[�Ȃ̂ŁH�Ń��X�g�������̂ŁH�𑫂��ăe�L�X�g��
		set ocidQueryStr to ocidArgTextArray's componentsJoinedByString:("?")
		log ocidQueryStr as text
		###�yB�z�N�G���[��name��value�̋�؂蕶���Ń��X�g��
		set ocidArgTextArray to ocidQueryStr's componentsSeparatedByString:("=")
		set numCntArray to (count of ocidArgTextArray) as integer
		###�����N�G���[������ꍇ
		if numCntArray > 1 then
			log ocidArgTextArray as list
			###�y�i�[�z�ŏ��̍��ڂ�name�����ɂȂ�̂Ŋi�[���Ă���
			set strNewQuery to ((ocidArgTextArray's firstObject() as text) & "=") as text
			repeat with itemIntNo from 1 to (numCntArray - 2) by 1
				###�yB�z�̃��X�g�����Ԃɏ���
				set ocidItem to (ocidArgTextArray's objectAtIndex:(itemIntNo))
				log ocidItem as text
				####�yC�z&�ŋ�؂��ă��X�g��
				set ocidItemArray to (ocidItem's componentsSeparatedByString:("&"))
				set numCntArray to (count of ocidItemArray) as integer
				####��������ꍇ���N�G���[��value�ɒl�Ƃ��ā�������ꍇ
				if numCntArray > 1 then
					###�Ō�̒l���i�[���Ă���
					set ocidNextQue to ocidItemArray's lastObject()
					###�Ō�̒l���폜�����̃N�G���[��Name������
					(ocidItemArray's removeLastObject())
					####�c�����l��Value�ɂȂ�̂ŁyC�z�Ł��Ń��X�g�ɂ����̂Ł��𑫂��ăe�L�X�g�ɖ߂�
					set ocidItemQueryStr to (ocidItemArray's componentsJoinedByString:("&"))
					###VALUE���N�G���[�̒l��URL�G���R�[�h����
					set strEncValue to doUrlEncode(ocidItemQueryStr as text)
					###�G���R�[�h�ς݂̒l���X�g�����O�X�ɂ���
					set ocidEncValue to (refMe's NSString's stringWithString:(strEncValue))
					###Value�̒��ɂ��違���ʂŃG���R�[�h���Ă���
					set ocidEncValue to (ocidEncValue's stringByReplacingOccurrencesOfString:("&") withString:("%26"))
					####�y�i�[�z�o���オ�����l���N�G���[�p�Ɋi�[
					set strNewQuery to strNewQuery & ((ocidEncValue as text) & "&" & (ocidNextQue as text) & "=") as text
				else
					####�N�G���[���P�����̏ꍇ
					####�y�i�[�z�o���オ�����l���N�G���[�p�Ɋi�[
					set strNewQuery to strNewQuery & ((ocidItemArray's firstObject() as text) & "&" & (ocidItemArray's lastObject() as text) & "=") as text
				end if
			end repeat
			####�y�i�[�z�o���オ�����l���N�G���[�p�Ɋi�[
			set strNewQuery to (strNewQuery & (ocidArgTextArray's lastObject() as text)) as text
			####�x�[�X�ɂȂ�URL�ɃN�G���[�̒l��߂���URL���Ē�`
			set strEncText to ((ocidBaseURLstr as text) & "?" & strNewQuery) as text
		end if
		##URL�̃N�G���[��Name�������ꍇ
		set strEncText to ((ocidBaseURLstr as text) & "?" & (ocidQueryStr as text)) as text
		set strURL to doUrlDecode(strEncText)
		set strEncText to doUrlEncode(strURL)
	else
		##URL�ɁH���Ȃ����N�G���[���Ȃ��ꍇ
		set ocidBaseURLstr to ocidArgTextArray's firstObject()
		set strURL to doUrlDecode(ocidBaseURLstr)
		set strEncText to doUrlEncode(strURL)
	end if
	
	set strURL to strEncText as text
else
	set strURL to ocidTextM as text
end if



#########################
set ocidURLString to refMe's NSString's alloc()'s initWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
set strURL to ocidURL's absoluteString() as text

set ocidHostName to (ocidURL's |host|())

##�ۑ���
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirURL to ocidURLsArray's firstObject()
set ocidWebLocDirPathURL to ocidDocumentDirURL's URLByAppendingPathComponent:("Apple/Webloc/")
set ocidSaveDirPathURL to ocidWebLocDirPathURL's URLByAppendingPathComponent:(ocidHostName)
##�t�H���_���
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set aliasSaveDirPathURL to (ocidSaveDirPathURL's absoluteURL()) as alias
#########################
###�t�@�C����
set strFileName to ocidHostName as text
set strDateno to doGetDateNo("yyyyMMdd")
set strSaveWeblocFileName to (strFileName & "." & strDateno & ".webloc") as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveWeblocFileName)
#########################
##WEBLOC�@���e
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(strURL) forKey:("URL")
set strDateno to doGetDateNo("yyyyMMdd")
ocidPlistDict's setValue:(strDateno) forKey:("version")
ocidPlistDict's setValue:(strDateno) forKey:("productVersion")
##����͎����p
ocidPlistDict's setValue:(strDateno) forKey:("kMDItemFSCreationDate")
##����������p
if strTITLE is "" then
	log "�������Ȃ�"
else if strTITLE is (missing value) then
	log "�������Ȃ�"
else
	ocidPlistDict's setValue:(strTITLE) forKey:("name")
end if
#########################
####webloc�t�@�C�������
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistData to item 1 of listPlistEditDataArray
set boolWritetoUrlArray to ocidPlistData's writeToURL:(ocidSaveFilePathURL) options:0 |error|:(reference)
(*
tell application "Finder"
	make new internet location file to strURL at aliasSaveDirPathURL with properties {name:"" & strName & "", creator type:"MACS", stationery:false, location:strURL}
end tell
*)
#########################
set strSaveUrlFileName to (strFileName & "." & strDateno & ".url") as text
####URL�t�@�C�������
set strShortCutFileString to ("[InternetShortcut]�r�nURL=" & strURL & "�r�n") as text
set ocidUrlFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveUrlFileName)

set ocidShortCutFileString to refMe's NSMutableString's alloc()'s initWithCapacity:0
ocidShortCutFileString's setString:(strShortCutFileString)

##�ۑ�
set boolDone to ocidShortCutFileString's writeToURL:(ocidUrlFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)

#########################

####�ۑ�����J��
tell application "Finder"
	set aliasSaveFile to (file strSaveWeblocFileName of folder aliasSaveDirPathURL) as alias
	set refNewWindow to make new Finder window
	tell refNewWindow
		set position to {10, 30}
		set bounds to {10, 30, 720, 480}
	end tell
	set target of refNewWindow to aliasSaveDirPathURL
	set selection to aliasSaveFile
end tell

#########################
####�o�[�W�����Ŏg�����t
to doGetDateNo(strDateFormat)
	####���t���̎擾
	set ocidDate to current application's NSDate's |date|()
	###���t�̃t�H�[�}�b�g���`
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
####################################
###### ���ŃR�[�h
####################################

on doUrlDecode(argText)
	##�e�L�X�g
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##�f�R�[�h
	set ocidArgTextEncoded to ocidArgText's stringByRemovingPercentEncoding
	set strArgTextEncoded to ocidArgTextEncoded as text
	return strArgTextEncoded
end doUrlDecode


####################################
###### ���G���R�[�h
####################################
on doUrlEncode(argText)
	##�e�L�X�g
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##�L�����N�^�Z�b�g���w��
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	##�L�����N�^�Z�b�g�ŕϊ�
	set ocidArgTextEncoded to ocidArgText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	##�e�L�X�g�`���Ɋm��
	set strTextToEncode to ocidArgTextEncoded as text
	###�l��߂�
	return strTextToEncode
end doUrlEncode

(*

####################################
###### ���G���R�[�h
####################################
on doUrlEncode(argText)
	##�e�L�X�g
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##�L�����N�^�Z�b�g���w��
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	##�L�����N�^�Z�b�g�ŕϊ�
	set ocidArgTextEncoded to ocidArgText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	######## �u���@���G���R�[�h�̒ǉ�����
	###�u�����R�[�h
	set recordPercentMap to {|+|:"%2B", |&|:"%26", |$|:"%24"} as record
	set recordPercentMap to {|+|:"%2B", |$|:"%24"} as record
	##	set recordPercentMap to {|+|:"%2B", |=|:"%3D", |&|:"%26", |$|:"%24"} as record
	###�f�B�N�V���i���ɂ���
	set ocidPercentMap to refMe's NSDictionary's alloc()'s initWithDictionary:(recordPercentMap)
	###�L�[�̈ꗗ�����o���܂�
	set ocidAllKeys to ocidPercentMap's allKeys()
	###���o�����L�[�ꗗ�����Ԃɏ���
	repeat with itemAllKey in ocidAllKeys
		##�L�[�̒l�����o����
		set ocidMapValue to (ocidPercentMap's valueForKey:(itemAllKey))
		##�u��
		set ocidEncodedText to (ocidArgTextEncoded's stringByReplacingOccurrencesOfString:(itemAllKey) withString:(ocidMapValue))
		##���̕ϊ��ɔ�����
		set ocidArgTextEncoded to ocidEncodedText
	end repeat
	##�e�L�X�g�`���Ɋm��
	set strTextToEncode to ocidEncodedText as text
	###�l��߂�
	return strTextToEncode
end doUrlEncode

*)