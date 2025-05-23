#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

#####################################
######ファイル保存先
#####################################
set ocidUserLibraryPathArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidFilePathURL to ocidUserLibraryPathArray's objectAtIndex:0
set ocidSaveDirPathURL to ocidFilePathURL's URLByAppendingPathComponent:"Apple/system_profiler"
############################
#####属性
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
############################
###フォルダを作る
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#####################################
######PLISTパス
#####################################
set ocidFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:"SPPrintersDataType.json"
set strFilePath to (ocidFilePathURL's |path|()) as text
###古いファイルはゴミ箱に
set boolResults to (appFileManager's trashItemAtURL:ocidFilePathURL resultingItemURL:(missing value) |error|:(reference))
#####################################
######コマンド実行
#####################################
set strCommandText to "/usr/sbin/system_profiler  SPPrintersDataType -json"
set strReadString to (do shell script strCommandText) as text
###戻り値をストリングに
set ocidReadString to refMe's NSString's stringWithString:(strReadString)
###NSDATAにして
set ocidReadData to ocidReadString's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
###ファイルに書き込み(使い回し用）-->不要な場合は削除して
ocidReadData's writeToURL:(ocidFilePathURL) atomically:true
#####################################
######JOSN　をDictで処理
#####################################
set listJSONSerialization to (refMe's NSJSONSerialization's JSONObjectWithData:(ocidReadData) options:0 |error|:(reference))
set ocidJsonData to item 1 of listJSONSerialization
set ocidJsonRootDict to (refMe's NSDictionary's alloc()'s initWithDictionary:(ocidJsonData))
set ocidDataTypeArray to (ocidJsonRootDict's objectForKey:("SPPrintersDataType"))
set numCntNo to 0 as integer
set strOutPutText to ("") as text
repeat with itemDataTypeArray in ocidDataTypeArray
	set numCntNo to numCntNo + 1 as integer
	set strValue to (itemDataTypeArray's valueForKey:("_name")) as text
	set strURL to (itemDataTypeArray's valueForKey:("uri")) as text
	set strPPDpath to (itemDataTypeArray's valueForKey:("ppd")) as text
	set strVer to (itemDataTypeArray's valueForKey:("ppdfileversion")) as text
	set strOutPutText to (strOutPutText & numCntNo & ": " & strValue & "\n" & strURL & "\n" & strPPDpath & "\n" & strVer & "\n") as text
end repeat


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
set strIconPath to "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FinderIcon.icns" as text
set aliasIconPath to POSIX file strIconPath as alias
###ダイアログ
set recordResult to (display dialog " 戻り値です\rコピーしてメールかメッセージを送ってください" with title "SPHardwareDataType" default answer strOutPutText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 30 with icon aliasIconPath without hidden answer)
###クリップボードコピー
if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strOutPutText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if