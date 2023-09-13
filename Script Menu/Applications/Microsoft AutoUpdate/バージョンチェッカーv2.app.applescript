#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
com.cocolog-nifty.quicktimer.icefloe
*)
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

###�A�v���P�[�V�����̃o���h��ID
set strBundleID to "com.microsoft.autoupdate2"

set strGetBundleID to "com.microsoft.autoupdate.standalone" as text
(* �C���X�g�[���p�b�P�[�W�̃o���h��ID
	com.microsoft.office.suite.365
	com.microsoft.office.suite.365.businesspro
	com.microsoft.word.standalone.365
	com.microsoft.excel.standalone.365
	com.microsoft.powerpoint.standalone.365
	com.microsoft.outlook.standalone.365
	com.microsoft.outlook.standalone.365.monthly
	com.microsoft.onenote.standalone.365
	com.microsoft.onedrive.standalone
	com.microsoft.skypeforbusiness.standalone
	com.microsoft.teams.standalone
	com.microsoft.intunecompanyportal.standalone
	com.microsoft.edge
	com.microsoft.defender.standalone
	com.microsoft.remotedesktop.standalone
	com.microsoft.vscode.zip
	com.microsoft.autoupdate.standalone
*)


set strURL to "https://macadmins.software/latest.xml" as text

set coidBaseURLStr to refMe's NSString's stringWithString:(strURL)
set ocidBaseURL to refMe's NSURL's URLWithString:(coidBaseURLStr)

################################################
###### URLRequest����
################################################
set ocidURLRequest to refMe's NSMutableURLRequest's alloc()'s init()
ocidURLRequest's setHTTPMethod:"GET"
ocidURLRequest's setURL:(ocidBaseURL)
ocidURLRequest's addValue:"application/xml" forHTTPHeaderField:"Content-Type"
###�|�X�g����f�[�^�͋�
ocidURLRequest's setHTTPBody:(missing value)

################################################
###### �f�[�^�擾
################################################
set ocidServerResponse to refMe's NSURLConnection's sendSynchronousRequest:(ocidURLRequest) returningResponse:(missing value) |error|:(reference)
###�擾
set ocidXMLData to (item 1 of ocidServerResponse)
set listXMLDoc to refMe's NSXMLDocument's alloc()'s initWithData:ocidXMLData options:(refMe's NSXMLDocumentTidyXML) |error|:(reference)

set ocidXMLDoc to item 1 of listXMLDoc
set ocidRootElement to ocidXMLDoc's rootElement()

################################################
###### o365�o�[�W�����擾
################################################
repeat with itemRootElement in ocidRootElement's children()
	set strName to itemRootElement's |name|() as text
	if strName is "o365" then
		set ocido365ver to (ocidRootElement's childAtIndex:0)'s stringValue()
	end if
end repeat
#######
log ocido365ver as text

################################################
###### �e�A�v���P�[�V������UTI�擾
################################################
set ocidPackageArray to ocidRootElement's elementsForName:"package"
repeat with itemackageArray in ocidPackageArray
	set ocidElementID to (itemackageArray's childAtIndex:0)'s stringValue()
	log ocidElementID as text
	
end repeat


################################################
###### �ΏۃA�v���ŐV�̃o�[�W����
################################################

set ocidPackageArray to ocidRootElement's elementsForName:"package"
repeat with itemackageArray in ocidPackageArray
	set numCntChild to itemackageArray's childCount() as integer
	set ocidElementID to (itemackageArray's childAtIndex:0)'s stringValue()
	if (ocidElementID as text) is strGetBundleID then
		set ocidCfbundleversionXML to (itemackageArray's childAtIndex:8)'s stringValue()
		set ocidDownloadURL to (itemackageArray's childAtIndex:(numCntChild - 1))'s stringValue()
	end if
end repeat

################################################
###### �C���X�g�[���ς݂̃p�[�W����
################################################
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
##�o���h������A�v���P�[�V������URL���擾
set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
if ocidAppBundle �� (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else if ocidAppBundle = (missing value) then
	set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
end if
##�\���i�A�v���P�[�V������URL�j
if ocidAppPathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
			set strAppPath to POSIX path of aliasAppApth as text
			set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
			set strAppPath to strAppPathStr's stringByStandardizingPath()
			set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
		on error
			return "�A�v���P�[�V������������܂���ł���"
		end try
	end tell
end if
set ocidFilePathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/Info.plist")
#####PLIST�̓��e��ǂݍ����
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set listReadPlistData to refMe's NSMutableDictionary's dictionaryWithContentsOfURL:ocidFilePathURL |error|:(reference)
set ocidPlistDict to item 1 of listReadPlistData
set ocidCfbundleversionPlist to ocidPlistDict's valueForKey:"CFBundleVersion"
################################################
###### �����N����
################################################
set strDownloadURL to ocidDownloadURL as text
set strCommandText to ("/usr/bin/curl -Lvs -I -o /dev/null -w '%{url_effective}' " & strDownloadURL & "") as text
set strLocation to (do shell script strCommandText) as text

################################################
###### �`�F�b�N
################################################
set strCfbundleversionXML to ocidCfbundleversionXML as text
set strCfbundleversionPlist to ocidCfbundleversionPlist as text

if strCfbundleversionXML is strCfbundleversionPlist then
	set strTitle to ("�ŐV�ł𗘗p���ł�") as text
	set strCom to ("�ŐV�ł𗘗p���ł��r" & strCfbundleversionXML) as text
	set strMes to (strTitle & "�rRSS:" & strCfbundleversionXML & "�rPLIST:" & strCfbundleversionPlist & "�rLink:" & strDownloadURL & "�rLocation:" & strLocation) as text
else
	set strTitle to ("�A�b�v�f�[�g������܂��F" & strCfbundleversionXML) as text
	set strCom to ("�A�b�v�f�[�g������܂��r�ŐV�F" & strCfbundleversionXML & "�r�g�p���F" & strCfbundleversionPlist) as text
	set strMes to ("�ŐV�Ń_�E�����[�h:" & strDownloadURL & "�r" & strLocation) as text
end if

################################################
###### �_�C�A���O
################################################
set appFileManager to refMe's NSFileManager's defaultManager()

####�_�C�A���O�Ɏw��A�v���̃A�C�R����\������
###�A�C�R������PLIST����擾
set strIconFileName to (ocidPlistDict's valueForKey:("CFBundleIconFile")) as text
###ICON��URL�ɂ���
set strPath to ("Contents/Resources/" & strIconFileName) as text
set ocidIconFilePathURL to ocidAppPathURL's URLByAppendingPathComponent:(strPath) isDirectory:false
###�g���q�̗L���`�F�b�N
set strExtensionName to (ocidIconFilePathURL's pathExtension()) as text
if strExtensionName is "" then
	set ocidIconFilePathURL to ocidIconFilePathURL's URLByAppendingPathExtension:"icns"
end if
##-->���ꂪ�A�C�R���p�X
log ocidIconFilePathURL's absoluteString() as text
###ICON�t�@�C�������ۂɂ��邩�H�`�F�b�N
set boolExists to appFileManager's fileExistsAtPath:(ocidIconFilePathURL's |path|)
###ICON���݂��Ȃ����p�Ƀf�t�H���g��p�ӂ���
if boolExists is false then
	set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
else
	set aliasIconPath to ocidIconFilePathURL's absoluteURL() as alias
	set strIconPath to ocidIconFilePathURL's |path|() as text
end if

set recordResult to (display dialog strCom with title strTitle default answer strMes buttons {"�N���b�v�{�[�h�ɃR�s�[", "�I��", "�_�E�����[�h"} default button "�_�E�����[�h" cancel button "�I��" giving up after 20 with icon aliasIconPath without hidden answer)

if button returned of recordResult is "�_�E�����[�h" then
	tell application "Finder"
		open location strLocation
	end tell
end if
if button returned of recordResult is "�N���b�v�{�[�h�ɃR�s�[" then
	try
		set strText to text returned of recordResult as text
		####�y�[�X�g�{�[�h�錾
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strTitle as text
		end tell
	end try
end if
