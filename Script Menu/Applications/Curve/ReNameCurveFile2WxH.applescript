#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

###デフォルトロケーション
set ocidForDirArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidForDirArray's firstObject()
set aliasDefaultLocation to (ocidDesktopPathURL's absoluteURL()) as alias

set listUTI to {"com.vladidanila.vectornator", "com.linearity.curve"}

#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if

set strMes to ("curveファイルを選んでください") as text
set strPrompt to ("curveファイルを選んでください") as text


set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles and multiple selections allowed without showing package contents) as list

repeat with itemAliasFilePath in listAliasFilePath
	set theFilePath to POSIX path of itemAliasFilePath as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:(theFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	###リネームに必要な値
	set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
	set strExtensionName to (ocidFilePathURL's pathExtension()) as text
	set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
	set strBaseFileName to (ocidBaseFilePathURL's lastPathComponent()) as text
	##コマンド用のパス
	set strFilePath to (ocidFilePathURL's |path|()) as text
	###コマンド整形
	set strCommandText to ("/usr/bin/unzip -c \"" & strFilePath & "\" Document.json")
	###実行
	set strCommandResponse to (do shell script strCommandText) as text
	### コマンドの戻り値からJOSN部のみ取り出す
	set ocidCommandResponse to (refMe's NSString's stringWithString:(strCommandResponse))
	set ocidCommandResponseArray to (ocidCommandResponse's componentsSeparatedByString:("\r"))
	set ocidJsonDoc to (ocidCommandResponseArray's objectAtIndex:2)
	###NSDATA化
	set ocidJsonData to (ocidJsonDoc's dataUsingEncoding:(refMe's NSUTF8StringEncoding))
	###JSON初期化
	set listJSONSerialization to (refMe's NSJSONSerialization's JSONObjectWithData:(ocidJsonData) options:(refMe's NSJSONReadingAllowFragments) |error|:(reference))
	set ocidJsonData to item 1 of listJSONSerialization
	###ディレクトリに格納して
	set ocidJsonDict to (refMe's NSDictionary's alloc()'s initWithDictionary:(ocidJsonData))
	###値を取り出す
	set strUUIDArray to (ocidJsonDict's valueForKeyPath:("drawing.artboardPaths"))
	set strUUID to strUUIDArray's firstObject()
	log strUUID as text
	#############################################
	set strCommandText to ("/usr/bin/unzip -c \"" & strFilePath & "\" '" & strUUID & "'")
	set strCommandResponse to (do shell script strCommandText) as text
	### コマンドの戻り値からJOSN部のみ取り出す
	set ocidCommandResponse to (refMe's NSString's stringWithString:(strCommandResponse))
	set ocidCommandResponseArray to (ocidCommandResponse's componentsSeparatedByString:("\r"))
	set ocidJsonDoc to (ocidCommandResponseArray's objectAtIndex:2)
	###NSDATA化
	set ocidJsonData to (ocidJsonDoc's dataUsingEncoding:(refMe's NSUTF8StringEncoding))
	###JSON初期化
	set listJSONSerialization to (refMe's NSJSONSerialization's JSONObjectWithData:(ocidJsonData) options:(refMe's NSJSONReadingAllowFragments) |error|:(reference))
	set ocidJsonData to item 1 of listJSONSerialization
	###ディレクトリに格納して
	set ocidJsonDict to (refMe's NSDictionary's alloc()'s initWithDictionary:(ocidJsonData))
	###値を取り出す
	set strWidth to (ocidJsonDict's valueForKeyPath:("frame.width"))
	set strHeight to (ocidJsonDict's valueForKeyPath:("frame.height"))
	###新しいファイル名
	###vectornatorを廃止
	set strExtensionName to "curve" as text
	set strNewFileName to (strBaseFileName & "." & strWidth & "x" & strHeight & "." & strExtensionName) as text
	###新しいURL
	set ocidNewFilePathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:(strNewFileName))
	###移動（リネーム）
	set listDone to (appFileManager's moveItemAtURL:(ocidFilePathURL) toURL:(ocidNewFilePathURL) |error|:(reference))
end repeat


