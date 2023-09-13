#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "CoreImage"
use scripting additions

property refMe : a reference to current application
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807


#####################
### QR�R�[�h�ۑ���@NSPicturesDirectory
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPicturesDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidPicturesDirURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidPicturesDirURL's URLByAppendingPathComponent:("QRcode/Map")
##�t�H���_�쐬
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

#####################
### ���Z�b�g
tell application id "com.apple.Maps" to activate
set strURL to "" as text
tell application "Finder"
	set the clipboard to the strURL as string
end tell
#####################
###�R�s�[�̃T�u��
doCopyMap()

###�N���b�v�{�[�h����URL���擾����
tell application "Finder"
	repeat 10 times
		set strURL to (the clipboard) as text
		if strURL is "" then
			delay 0.1
		else
			log "strURL:" & strURL
			exit repeat
		end if
	end repeat
end tell

if strURL is "" then
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidStringData to appPasteboard's stringForType:("public.utf8-plain-text")
	set ocidText to (refMe's NSString's stringWithString:(ocidStringData))
	set strURL to ocidText
end if

#####################
if strURL is "" then
	###URL�̎擾�Ɏ��s���Ă���p�^�[��
	###�_�C�A���O
	tell current application
		set strName to name as text
	end tell
	####�X�N���v�g���j���[������s������
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	set aliasIconPath to POSIX file "/System/Applications/Maps.app/Contents/Resources/AppIcon.icns" as alias
	set strDefaultAnswer to "https://maps.apple.com/?ll=35.658558,139.745504" as text
	try
		set objResponse to (display dialog "URL�̎擾" with title "QR�e�L�X�g" default answer strDefaultAnswer buttons {"OK", "�L�����Z��"} default button "OK" cancel button "�L�����Z��" with icon aliasIconPath giving up after 20 without hidden answer)
	on error
		log "�G���[���܂���"
		return
	end try
	if true is equal to (gave up of objResponse) then
		return "���Ԑ؂�ł����Ȃ����Ă�������"
	end if
	if "OK" is equal to (button returned of objResponse) then
		set strURL to (text returned of objResponse) as text
	else
		return "�L�����Z��"
	end if
end if

############################
##�l���R�s�[�o���Ȃ������Ƃ��G���[�ɂȂ�̂�
##�����̓g���C
try
	####################################
	###URL��NSURL�Ɋi�[
	set ocidURL to refMe's NSURL's alloc's initWithString:(strURL)
	log className() of ocidURL as text
	--> NSURL
	####################################
	###�N�G���[�������o��
	set ocidQueryUrl to ocidURL's query
	log className() of ocidQueryUrl as text
	--> __NSCFString
	log ocidQueryUrl as text
on error
	###�G���[������R�s�[��蒼��
	tell application "Maps"
		tell application "System Events"
			tell process "Maps"
				key code 53
			end tell
		end tell
	end tell
	doCopyMap()
	tell application "Finder"
		repeat 10 times
			set strURL to (the clipboard) as text
			if strURL is "" then
				delay 0.1
			else
				log "strURL:" & strURL
				exit repeat
			end if
		end repeat
	end tell
	####################################
	###URL��NSURL�Ɋi�[
	set ocidURLstr to refMe's NSString's alloc()'s initWithString:(strURL)
	set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLstr)
	log ocidURL's absoluteString() as text
	
	
	####################################
	###�N�G���[�������o��
	set ocidQueryUrl to ocidURL's query
	log className() of ocidQueryUrl as text
	--> __NSCFString
	log ocidQueryUrl as text
end try

####################################
###���o�����N�G����������؂蕶���Ń��X�g��
set ocidArrayComponent to (ocidQueryUrl's componentsSeparatedByString:"&")
log className() of ocidArrayComponent as text
--> __NSArrayM
log ocidArrayComponent as list

####################################
####�σ��R�[�h���쐬
set ocidRecordQuery to refMe's NSMutableDictionary's alloc()'s init()
####�l����̃��R�[�h���`
set recordQuery to {t:"", q:"", address:"", near:"", ll:"", z:"18", spn:"", saddr:"", daddr:"", dirflg:"", sll:"", sspn:"", ug:""} as record
####���̒�`�Œl����̉σ��R�[�h���쐬
set ocidRecordQuery to refMe's NSMutableDictionary's dictionaryWithDictionary:recordQuery
####################################
###��������N�G���[���J��Ԃ�
repeat with objArrayComponent in ocidArrayComponent
	#####�n���ꂽ�N�G���[���������ɕ�������Array�����X�g�ɂ���
	set ocidArrayFirstObject to (objArrayComponent's componentsSeparatedByString:"=")
	
	####�܂��͏��ԂɁ@�L�[�@�Ɓ@�l�@�Ŋi�[
	set ocidKey to item 1 of ocidArrayFirstObject
	log ocidKey as text
	
	set ocidValue to item 2 of ocidArrayFirstObject
	log ocidValue as text
	
	#########�ʒu���@�ܓx �o�x
	if (ocidKey as text) = "ll" then
		set ll of ocidRecordQuery to ocidValue
		####�J���}�ł킯�Ĉܓx �o�x��
		set ocidArrayLL to (ocidValue's componentsSeparatedByString:",")
		log ocidArrayLL as list
		###�ŏ��̍���
		set ocidLatitude to item 1 of ocidArrayLL
		log "Latitude:" & ocidLatitude as text
		###���Ƃ̍���
		set ocidLongitude to item 2 of ocidArrayLL
		log "Longitude:" & ocidLongitude as text
		
		#########Address String  �Z��
	else if (ocidKey as text) = "address" then
		set address of ocidRecordQuery to ocidValue
		set ocidAddEnc to ocidValue's stringByRemovingPercentEncoding
		log "AddressString:" & ocidAddEnc as text
		
		#########The zoom level.�@��������
	else if (ocidKey as text) = "z" then
		set z of ocidRecordQuery to ocidValue
		set ocidZoomValue to ocidValue
		log "ZoomValue:" & ocidZoomValue
		
		#########�}�b�v�r���[ 
	else if (ocidKey as text) = "t" then
		set t of ocidRecordQuery to ocidValue
		set ocidMapType to ocidValue
		log "MapType:" & ocidMapType
		(*
		m (standard view)
		k (satellite view)
		h (hybrid view)
		r (transit view)
		goole
		map_action=pano
		map_action=map
		basemap=satellite
		terrain
		roadmap
		*)
		####################################
		#########dirflg �ړ����@	
	else if (ocidKey as text) = "dirflg" then
		set dirflg of ocidRecordQuery to ocidValue
		set ocidDirflgType to ocidValue
		log "DirflgType:" & ocidDirflgType
		(*
		d (by car)
		w (by foot) 
		r (by public transit)
		
		goole
		travelmode=driving
		walking
		transit
			*)
		
		#########Dirflg Parameters �o���_
	else if (ocidKey as text) = "saddr" then
		set saddr of ocidRecordQuery to ocidValue
		set strSaddrEnc to ocidValue as text
		set ocidSaddrEnc to ocidValue's stringByRemovingPercentEncoding
		log "StartingPoint:" & ocidSaddrEnc as text
		
		#########Destination  �����X
	else if (ocidKey as text) = "daddr" then
		set daddr of ocidRecordQuery to ocidValue
		set strDaddrEnc to ocidValue as text
		set ocidDaddrEnc to ocidValue's stringByRemovingPercentEncoding
		log "DestinationPoint:" & ocidDaddrEnc as text
		
		#########Search Query�@�������
	else if (ocidKey as text) = "q" then
		set q of ocidRecordQuery to ocidValue
		set strRecordQuery to ocidValue as text
		set ocidSearchQueryEnc to ocidValue's stringByRemovingPercentEncoding
		log "SearchQuery" & ocidSearchQueryEnc as text
		
		####################################
		#########��匟�����̎��ӏ��̗L���ɂ�镪��
		
	else if (ocidKey as text) = "sll" then
		set sll of ocidRecordQuery to ocidValue
		####�J���}�ł킯�Ĉܓx �o�x��
		set ocidSearchArrayLL to (ocidValue's componentsSeparatedByString:",")
		log ocidSearchArrayLL as list
		####�ŏ��̍���
		set ocidNearLatitude to item 1 of ocidSearchArrayLL
		log "NearLatitude:" & ocidNearLatitude as text
		####���Ƃ̍���
		set ocidNearLongitude to item 2 of ocidSearchArrayLL
		log "NearNearLongitude:" & ocidNearLongitude as text
		
	else if (ocidKey as text) = "spn" then
		####���͏��͈̔�
		set spn of ocidRecordQuery to ocidValue
		
		
		####################################
		#########during search���� �ʒu��� �ܓx �o�x
		
	else if (ocidKey as text) = "near" then
		set near of ocidRecordQuery to ocidValue
		####�J���}�ł킯�Ĉܓx �o�x��
		set ocidNearArrayLL to (ocidValue's componentsSeparatedByString:",")
		log ocidNearArrayLL as list
		###�ŏ��̍���
		set ocidNearLatitude to item 1 of ocidNearArrayLL
		log "NearLatitude:" & ocidNearLatitude as text
		###���Ƃ̍���
		set ocidNearLongitude to item 2 of ocidNearArrayLL
		log "NearNearLongitude:" & ocidNearLongitude as text
		
		####################################
		#########�K�C�h����ug
	else if (ocidKey as text) = "ug" then
		set ug of ocidRecordQuery to ocidValue
		
	end if
	
end repeat

log ocidRecordQuery as record


####################################################
#########�Ή��A�v���̕���
###�z�X�g�������o��
set ocidHostUrl to ocidURL's |host|
log className() of ocidHostUrl as text
--> __NSCFString
log ocidHostUrl as text
####################################
###�z�X�g�ɂ�镪��
if (ocidHostUrl as text) is "guides.apple.com" then
	-->���̂܂܂̒l�Ńo�[�R�[�h���쐬����
	set listButtonAset to {"AppleMap�K�C�h�p"} as list
	set strAlertMes to "�K�C�h�����N��AppleMap��p�ł�"
	
else if (ocidHostUrl as text) is "collections.apple.com" then
	-->�R���N�V�����͌��݂́w�K�C�h�x�ɂȂ����H
	set listButtonAset to {"AppleMap�K�C�h�p"} as list
	set strAlertMes to "�K�C�h�����N��AppleMap��p�ł�"
	
else if (ocidHostUrl as text) is "maps.apple.com" then
	-->�K�C�h�ȊO
	-->��������
	####################################
	###���e�ɂ���Ă̕���
	if (ll of ocidRecordQuery as text) is not "" then
		######�ܓx�o�x������ꍇ
		set listButtonAset to {"AppleMap�p", "GoogleMap�p", "GeoQR"} as list
		set strAlertMes to "GeoQR�͑Ή����Ă��Ȃ��@���A�v��������܂�"
		
	else if (q of ocidRecordQuery as text) is not "" then
		######������傪����ꍇ
		set listButtonAset to {"AppleMap�p", "GoogleMap�p", "�ėp"} as list
		set strAlertMes to "iOS�pAppleMap��QR�R�[�h���쐬���� OR ��ʓI��QR�R�[�h���쐬����"
		
	else if (daddr of ocidRecordQuery as text) is not "" then
		set listButtonAset to {"AppleMap�o�H", "GoogleMap�o�H"} as list
		set strAlertMes to "�o�H���p��Map�ɂȂ�܂�"
		
	else
		######�ܓx�o�x����������喳������AppleMap�̂�
		set listButtonAset to {"AppleMap�p�̂�"} as list
		set strAlertMes to "�K�C�h�����N��AppleMap��p�ł�"
		
	end if
end if
##############################################
log listButtonAset
###URL�̎擾�Ɏ��s���Ă���p�^�[��
###�_�C�A���O
tell current application
	set strName to name as text
end tell
####�X�N���v�g���j���[������s������
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	##	set objAns to (display alert "�ǂ���p��QR�R�[�h���쐬���܂����H" message strAlertMes default button 1 buttons listButtonAset)
	set listResponse to (choose from list listButtonAset with title "�Z��" with prompt strAlertMes default items (item 1 of listButtonAset) OK button name "OK" cancel button name "�L�����Z��" without multiple selections allowed and empty selection allowed) as list
	
on error
	log "�G���[���܂���"
	return
end try
if (item 1 of listResponse) is false then
	return "�L�����Z�����܂���"
end if

set objResponse to (item 1 of listResponse) as text

## 	set objResponse to (button returned of objAns) as text
##############################################

if objResponse is "GeoQR" then
	### �ܓx�o�x��GEO�o�[�R�[�h�@�Ή��@��ɐ���������ꍇ����
	set theChl to ("GEO:" & (ocidLatitude as text) & "," & (ocidLongitude as text) & "," & (z of ocidRecordQuery as text) & "") as text
	###�o�H���@Map
else if objResponse is "AppleMap�o�H" then
	set theChl to ("http://maps.apple.com/?daddr=" & (ocidDaddrEnc as text) & "&saddr=" & (ocidSaddrEnc as text) & "") as text
	###�o�H���@Google
else if objResponse is "GoogleMap�o�H" then
	set theChl to ("https://www.google.com/maps/?daddr=" & (ocidDaddrEnc as text) & "&saddr=" & (ocidSaddrEnc as text) & "") as text
	####AppleMap�̃K�C�h�����N
else if objResponse is "AppleMap�K�C�h�p" then
	set theChl to ("" & strURL & "") as text
	
else if objResponse is "GoogleMap�p" then
	##############################################
	###GoogleMap�p�̏����_�ȉ��̌�����
	###�t�[���T�v���X
	set theLatitude to (ocidLatitude as text)
	set AppleScript's text item delimiters to "."
	set listLatitude to every text item of theLatitude as list
	set AppleScript's text item delimiters to ""
	set strLatitudeInt to text item 1 of listLatitude as text
	set strLatitudeDecimal to text item 2 of listLatitude as text
	set strLatitudeDecimal to (text 1 through 7 of (strLatitudeDecimal & "000000000")) as text
	set theLatitude to ("" & strLatitudeInt & "." & strLatitudeDecimal & "")
	
	set theLongitude to (ocidLongitude as text)
	set AppleScript's text item delimiters to "."
	set listLongitude to every text item of theLongitude as list
	set AppleScript's text item delimiters to ""
	set strLongitudeInt to text item 1 of listLongitude as text
	set strLongitudeDecimal to text item 2 of listLongitude as text
	set strLongitudeDecimal to (text 1 through 7 of (strLongitudeDecimal & "000000000")) as text
	set theLongitude to ("" & strLongitudeInt & "." & strLongitudeDecimal & "")
	
	set theGooglemapParts to ("@" & theLatitude & "," & theLongitude & "," & (z of ocidRecordQuery as text) & "z")
	
	set theChl to ("https://www.google.com/maps/" & theGooglemapParts & "") as text
else
	set theChl to ("http://maps.apple.com/?q=" & (ocidLatitude as text) & "," & (ocidLongitude as text) & "," & (z of ocidRecordQuery as text) & "z") as text
end if
#####################################################
#####QR�R�[�h�ۑ��v�t�@�C����
if (q of ocidRecordQuery as text) is not "" then
	###������傠��
	if (count of (ocidSearchQueryEnc as text)) < 8 then
		set strQueryEnc to (ocidSearchQueryEnc as text) as text
	else
		set strQueryEnc to characters 1 thru 8 of (ocidSearchQueryEnc as text) as text
	end if
	set strFileName to ("" & strQueryEnc & ".png")
	refMe's NSLog("��:osascript: ocidSearchQueryEnc " & (ocidSearchQueryEnc as text) & "")
	
else if (daddr of ocidRecordQuery as text) is not "" then
	###�s�����傠��
	set strDaddrEnc to characters 1 thru 8 of (ocidDaddrEnc as text) as text
	set strFileName to ("" & strDaddrEnc & ".png")
	refMe's NSLog("��:osascript: ocidDaddrEnc " & (ocidDaddrEnc as text) & "")
else
	###���̖����ꍇ�͓��t���t�@�C�����ɂ���
	set strDateFormat to "yyyy�NMMMMdd��hh��mm��" as text
	set ocidForMatter to refMe's NSDateFormatter's alloc()'s init()
	ocidForMatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidForMatter's setDateFormat:(strDateFormat)
	set objDate to (current date)
	set strDateTime to (ocidForMatter's stringFromDate:(objDate)) as text
	set strFileName to ("" & strDateTime & ".png")
end if
####################################
###�t�@�C�����̐ړ���
if objResponse is "GeoQR" then
	### �ܓx�o�x��GEO�o�[�R�[�h�@�Ή��@��ɐ���������ꍇ����
	set strFileName to ("GeoQR." & strFileName) as text
	###�o�H���@Map
else if objResponse is "AppleMap�o�H" then
	set strFileName to ("A�o�H." & strFileName) as text
	###�o�H���@Google
else if objResponse is "GoogleMap�o�H" then
	set strFileName to ("G�o�H." & strFileName) as text
	####AppleMap�̃K�C�h�����N
else if objResponse is "AppleMap�K�C�h�p" then
	set strFileName to ("Guide." & strFileName) as text
else if objResponse is "GoogleMap�p" then
	set strFileName to ("Google." & strFileName) as text
else
	set strFileName to ("Google." & strFileName) as text
end if
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName)

######################################
### �F���߁@�؂�̂Ă̓s����w��̃j�A
######################################
###URL�̎擾�Ɏ��s���Ă���p�^�[��
###�_�C�A���O
tell current application
	set strName to name as text
end tell
####�X�N���v�g���j���[������s������
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
tell application "Finder"
	set the listRGB16bitColor to (choose color default color {0, 0, 0, 1}) as list
end tell
##########Color Picker Value 16Bit
set numRcolor16Bit to item 1 of listRGB16bitColor as number
set numGcolor16Bit to item 2 of listRGB16bitColor as number
set numBcolor16Bit to item 3 of listRGB16bitColor as number
set numAcolor16Bit to 65535 as number
##########Standard RGB Value 8Bit
set numRcolor8Bit to numRcolor16Bit / 256 div 1 as number
set numGcolor8Bit to numGcolor16Bit / 256 div 1 as number
set numBcolor8Bit to numBcolor16Bit / 256 div 1 as number
set numAcolor8Bit to numAcolor16Bit / 256 div 1 as number
##########NSColorValue Float
set numRcolorFloat to numRcolor8Bit / 255 as number
set numGcolorFloat to numGcolor8Bit / 255 as number
set numBcolorFloat to numBcolor8Bit / 255 as number
set numAcolorFloat to numAcolor8Bit / 255 as number
####�F�w��
##	�F�w��l�͂�����𗘗p
##	https://quicktimer.cocolog-nifty.com/icefloe/2023/06/post-d68270.html
###�F�w�肷��ꍇ
##	set ocidQrColor to refMe's CIColor's colorWithRed:0.101960784314 green:0.752941176471 blue:0.262745098039 alpha:1.0
###
set ocidQrColor to refMe's CIColor's colorWithRed:numRcolorFloat green:numGcolorFloat blue:numBcolorFloat alpha:numAcolorFloat

##############################################
set strInputText to theChl as text
####�e�L�X�g��NSString��
set ocidInputString to refMe's NSString's stringWithString:strInputText
####�e�L�X�g��UTF8��
set ocidUtf8InputString to ocidInputString's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
####CIQRCodeGenerator������
set ocidQRcodeImage to refMe's CIFilter's filterWithName:"CIQRCodeGenerator"
ocidQRcodeImage's setDefaults()
###�e�L�X�g�ݒ�
ocidQRcodeImage's setValue:ocidUtf8InputString forKey:"inputMessage"
###�ǂݎ��덷�l�ݒ�L, M, Q, H
ocidQRcodeImage's setValue:"Q" forKey:"inputCorrectionLevel"
###QR�R�[�h�{�̂̃C���[�W
set ocidCIImage to ocidQRcodeImage's outputImage()
-->�����Ő��������̂�QR�̃Z����1x1px�̍ŏ��T�C�Y
###################################
#####�F�̒u������
###################################

###�u�������F�����̏ꍇ�͍�
set ocidBlackColor to refMe's CIColor's colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0
###CIFalseColor�ŐF��h��܂�
set ocidFilterColor to refMe's CIFilter's filterWithName:"CIFalseColor"
ocidFilterColor's setDefaults()
ocidFilterColor's setValue:ocidQrColor forKey:"inputColor0"
ocidFilterColor's setValue:ocidBlackColor forKey:"inputColor1"
ocidFilterColor's setValue:ocidCIImage forKey:"inputImage"
###�t�B���^���������摜��outputImage������o���܂�
set ocidCIImage to ocidFilterColor's valueForKey:"outputImage"


###QR�R�[�h�̏c���擾
set ocidCIImageDimension to ocidCIImage's extent()
set ocidCIImageWidth to (item 1 of item 2 of ocidCIImageDimension) as integer
set ocidCIImageHight to (item 2 of item 2 of ocidCIImageDimension) as integer
###�ŏI�I�ɏo�͂�����px�T�C�Y
set numScaleMax to 720
###�����Ŋg�債�Ȃ��ƃA���Ȃ̂Ł��̒l�̃j�A�ȃT�C�Y�ɂȂ�܂�
set numWidth to ((numScaleMax / ocidCIImageWidth) div 1) as integer
set numHight to ((numScaleMax / ocidCIImageHight) div 1) as integer
###���T�C�Y�̊g��k������ꍇ�͂����Œl�𒲐�����Ηǂ�
####�ϊ��X�P�[���쐬-->�g��
set recordScalse to refMe's CGAffineTransform's CGAffineTransformMakeScale(numWidth, numHight)
##�ϊ��X�P�[����K���i���̃T�C�Y�Ɍ��̃T�C�Y�̃X�P�[���K�����Ă��Ӗ��Ȃ�����
set ocidCIImageScaled to ocidCIImage's imageByApplyingTransform:recordScalse
#######���̃Z����1x1px�̍ŏ��T�C�Y�ŏo�������Ƃ��͂����ŏ���
##set ocidCIImageScaled to ocidCIImage
###�C���[�W�f�[�^��W�J
set ocidNSCIImageRep to refMe's NSCIImageRep's imageRepWithCIImage:ocidCIImageScaled
###�o�͗p�̃C���[�W�̏�����
set ocidNSImageScaled to refMe's NSImage's alloc()'s initWithSize:(ocidNSCIImageRep's |size|())
###�C���[�W�f�[�^������
ocidNSImageScaled's addRepresentation:ocidNSCIImageRep
###�o���オ�����f�[�^��OS_dispatch_data 
set ocidOsDispatchData to ocidNSImageScaled's TIFFRepresentation()
####NSBitmapImageRep��
set ocidNSBitmapImageRep to refMe's NSBitmapImageRep's imageRepWithData:ocidOsDispatchData
#################################################################
###quiet zone�p�ɉ摜���p�f�B���O����
set numPadWidth to ((ocidCIImageWidth * numWidth) + (numWidth * 6)) as integer
set numPadHight to ((ocidCIImageHight * numHight) + (numHight * 6)) as integer
###���E�ɂR�Z�����Â]�� quiet zone�𑫂�
####�܂��͌���QR�R�[�h�̃T�C�Y�ɂU�Z���T�C�Y���������T�C�Y�̉摜�������
set ocidNSBitmapImagePadRep to (refMe's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:numPadWidth pixelsHigh:numPadHight bitsPerSample:8 samplesPerPixel:4 hasAlpha:true isPlanar:false colorSpaceName:(refMe's NSCalibratedRGBColorSpace) bitmapFormat:(refMe's NSAlphaFirstBitmapFormat) bytesPerRow:0 bitsPerPixel:32)
###������
refMe's NSGraphicsContext's saveGraphicsState()
###�r�b�g�}�b�v�C���[�W
(refMe's NSGraphicsContext's setCurrentContext:(refMe's NSGraphicsContext's graphicsContextWithBitmapImageRep:ocidNSBitmapImagePadRep))
###�h��F���w���x�Ɏw�肵��
refMe's NSColor's whiteColor()'s |set|()
##�摜�ɂ���
refMe's NSRectFill({origin:{x:0, y:0}, |size|:{width:numPadWidth, height:numPadHight}})
###�o���オ�����摜��QR�o�[�R�[�h�����E�R�Z�������炵���ʒu��CompositeSourceOver����
ocidNSBitmapImageRep's drawInRect:{origin:{x:(numWidth * 3), y:(numHight * 3)}, |size|:{width:numPadWidth, Hight:numPadHight}} fromRect:{origin:{x:0, y:0}, |size|:{width:numPadWidth, height:numPadHight}} operation:(refMe's NSCompositeSourceOver) fraction:1.0 respectFlipped:true hints:(missing value)
####�摜�쐬�I��
refMe's NSGraphicsContext's restoreGraphicsState()
#################################################################

####JPEG�p�̈��k�v���p�e�B
##set ocidNSSingleEntryDictionary to refMe's NSDictionary's dictionaryWithObject:1 forKey:(refMe's NSImageCompressionFactor)
####PNG�p�̈��k�v���p�e�B
set ocidNSSingleEntryDictionary to refMe's NSDictionary's dictionaryWithObject:true forKey:(refMe's NSImageInterlaced)

#####�o�̓C���[�W�֕ϊ�
set ocidNSInlineData to (ocidNSBitmapImagePadRep's representationUsingType:(refMe's NSBitmapImageFileTypePNG) |properties|:ocidNSSingleEntryDictionary)



###	�ۑ�
set ocidOption to (refMe's NSDataWritingAtomic)
set boolDone to ocidNSInlineData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference)
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
#####################
###Preview �ŊJ��
###
tell application "Preview"
	launch
	activate
	open aliasSaveFilePath
end tell

#####################
### Finder�ŕۑ�����J��
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's selectFile:(ocidSaveFilePathURL's |path|()) inFileViewerRootedAtPath:(ocidSaveDirPathURL's |path|())



return true

########################
### �����N�R�s�[�@ForMaps
########################
to doCopyMap()
	
	tell application "System Events"
		launch
	end tell
	tell application "Maps"
		activate
	end tell
	tell application "Maps"
		tell application "System Events"
			tell process "Maps"
				key code 53
			end tell
		end tell
	end tell
	try
		tell application "System Events"
			tell process "Maps"
				##	get every menu bar
				tell menu bar 1
					##	get every menu bar item
					tell menu bar item "�ҏW"
						##	get every menu bar item
						tell menu "�ҏW"
							##	get every menu item
							tell menu item "�����N���R�s�["
								click
							end tell
						end tell
					end tell
				end tell
			end tell
		end tell
	on error
		try
			tell application id "com.apple.Maps"
				activate
				tell application "System Events"
					tell process "Maps"
						activate
						click menu item "�����N���R�s�[" of menu 1 of menu bar item "�ҏW" of menu bar 1
					end tell
				end tell
			end tell
		end try
	end try
end doCopyMap