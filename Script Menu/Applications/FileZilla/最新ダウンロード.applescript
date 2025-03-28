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
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807

###アプリケーションのバンドルID
set strBundleID to "org.filezilla-project.filezilla"
#################################
###
set strGetURL to ("https://filezilla-project.org/download.php?platform=osx") as text
set strGetURLStr to refMe's NSString's stringWithString:(strGetURL)
set ocidGetURL to refMe's NSURL's URLWithString:(strGetURLStr)
###
set ocidEncode to (refMe's NSUTF8StringEncoding)
set listHTML to refMe's NSString's alloc()'s initWithContentsOfURL:(ocidGetURL) usedEncoding:(ocidEncode) |error|:(reference)
set ocidHTML to (item 1 of listHTML)

###
set ocidCharSet to refMe's NSCharacterSet's newlineCharacterSet()
set ocidSeparateArray to (ocidHTML's componentsSeparatedByCharactersInSet:(ocidCharSet))
repeat with itemSeparateArray in ocidSeparateArray
	if (itemSeparateArray as text) contains "quickdownloadbuttonlink" then
		set strAtag to itemSeparateArray as text
		exit repeat
	end if
end repeat
###

###タグの分解
set AppleScript's text item delimiters to "href=�""
set listAtag to every text item of strAtag
set AppleScript's text item delimiters to ""
###↑さらに分解
set strTagItem to (item 2 of listAtag) as text
set AppleScript's text item delimiters to "�""
set listTagItem to every text item of strTagItem
set AppleScript's text item delimiters to ""
###URLゲット
set strLinkURL to (item 1 of listTagItem) as text

log strLinkURL
set ocidLinkURLStr to refMe's NSString's stringWithString:(strLinkURL)
set ocidLinkURL to refMe's NSURL's URLWithString:(ocidLinkURLStr)
set ocidFileName to ocidLinkURL's lastPathComponent()

#################################
###ダウンロード
set ocidOprion to (refMe's NSDataReadingMappedIfSafe)
set listFileData to refMe's NSData's dataWithContentsOfURL:(ocidLinkURL) options:(ocidOprion) |error|:(reference)
set ocidFileData to (item 1 of listFileData)
###保存先（起動時に削除されるフォルダ）
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
###
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

###保存パス
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidFileName) isDirectory:false
set strGz2FilePath to ocidSaveFilePathURL's |path|() as text
###保存
set ocidOprion to (refMe's NSDataWritingAtomic)
set listDone to ocidFileData's writeToURL:(ocidSaveFilePathURL) options:(ocidOprion) |error|:(reference)
#################################
###解凍先
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicationDirURL to ocidURLsArray's firstObject()
set ocidSaveAppDirPathURL to ocidApplicationDirURL's URLByAppendingPathComponent:("Sites") isDirectory:true
set ocidSaveAppDirPath to ocidSaveAppDirPathURL's |path|()
###
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveAppDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###
set ocidSaveAppPathURL to ocidSaveAppDirPathURL's URLByAppendingPathComponent:("FileZilla.app") isDirectory:false
set ocidSaveAppPath to ocidSaveAppPathURL's |path|()
set boolExist to appFileManager's fileExistsAtPath:(ocidSaveAppPath)
if boolExist is true then
	set listDone to (appFileManager's trashItemAtURL:(ocidSaveAppPathURL) resultingItemURL:(missing value) |error|:(reference))
end if
#################################
###解凍
set strCommandText to ("/usr/bin/bsdtar -xvjf �"" & strGz2FilePath & "�" -C �"" & (ocidSaveAppDirPath as text) & "�"") as text

set strResponse to ""
try
	set strResponse to (do shell script strCommandText)
on error strErrorMes
	set aliasPathToMe to path to me as alias
	set strPathToMe to (POSIX path of aliasPathToMe) as text
	set strErrorMes to (strPathToMe & "�r" & strResponse & "�r" & strErrorMes & "�r") as text
	
	#####ダイアログを前面に
	set strAppName to (name of current application) as text
	####スクリプトメニューから実行したら
	if strAppName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns" as alias
	set recordResult to (display dialog "一部エラーが発生しました�r確認してください" with title "エラーメッセージ" default answer strErrorMes buttons {"担当者にメールで送信", "キャンセル", "クリップボードにコピー"} default button "担当者にメールで送信" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer) as record
	
	if button returned of recordResult is "担当者にメールで送信" then
		set strURL to ("mailto:?Body=" & strErrorMes & "&subject=【エラー報告】エラーが発生しました")
		tell application "Finder"
			open location strURL
		end tell
	end if
	if button returned of recordResult is "クリップボードにコピー" then
		try
			set strText to text returned of recordResult as text
			####ペーストボード宣言
			set appPasteboard to refMe's NSPasteboard's generalPasteboard()
			set ocidText to (refMe's NSString's stringWithString:(strText))
			appPasteboard's clearContents()
			appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
		on error
			tell application "Finder"
				set the clipboard to strText as text
			end tell
		end try
	end if
end try

#################################
###
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolSelectFileResults to appSharedWorkspace's selectFile:(ocidSaveAppPath) inFileViewerRootedAtPath:(ocidSaveAppDirPath)
