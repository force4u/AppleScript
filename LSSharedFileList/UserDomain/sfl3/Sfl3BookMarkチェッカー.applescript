#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#
# よく使う項目にiCloudを追加する
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


###################################
#####ファイル選択ダイアログ
###################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLArray to appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask)
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set strAppendPath to ("com.apple.sharedfilelist") as text
set ocidDefaultLocationURL to ocidAppSuppDirPathURL's URLByAppendingPathComponent:(strAppendPath) isDirectory:false
set aliasDefaultLocation to (ocidDefaultLocationURL's absoluteURL()) as alias
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
####ダイアログを出す
set listUTI to {"public.item", "dyn.ah62d4rv4ge81g3xqgk", "dyn.ah62d4rv4ge81g3xqgq"} as list
set aliasFilePath to (choose file with prompt "sfl3ファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
####入力ファイルパス
set strFilePath to POSIX path of aliasFilePath
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidSfl3FilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)


#######################################
##NSdataに読み込み　Keyを解凍する
#######################################
###【１】NSDataに読み込む
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listReadData to refMe's NSData's dataWithContentsOfURL:(ocidSfl3FilePathURL) options:(ocidOption) |error|:(reference)
set ocidPlistData to (item 1 of listReadData)
###【２】NSKeyedUnarchiverで解凍してDictに
#macOS13まで
#set ocidArchveDict to (refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData))
#macOS14から
set listReadUnarchiver to (refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:((refMe's NSObject)'s class) fromData:(ocidPlistData) |error|:(reference))
set ocidArchveDict to (item 1 of listReadUnarchiver)
###【２】可変Dictにセット
set ocidReplaceDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
(ocidReplaceDict's setDictionary:ocidArchveDict)
###ALLkeys
set ocidAllKeysArray to ocidReplaceDict's allKeys()
#######################################
###　items の処理
#######################################
###【３】items のArrayを取り出して
set ocidItemsArray to (ocidReplaceDict's objectForKey:("items"))
set ocidSaveString to refMe's NSMutableString's alloc()'s initWithCapacity:0

repeat with itemArray in ocidItemsArray
	set ocidBookMarkData to (itemArray's objectForKey:("Bookmark"))
	set listResponse to (refMe's NSURL's URLByResolvingBookmarkData:(ocidBookMarkData) options:(refMe's NSURLBookmarkResolutionWithoutUI) relativeToURL:(missing value) bookmarkDataIsStale:(missing value) |error|:(reference))
	set ocidBookMarkURL to (item 1 of listResponse)
	if ocidBookMarkURL /= (missing value) then
	set strSetValue to ocidBookMarkURL's absoluteString() as text
	(ocidSaveString's appendString:(strSetValue))
	(ocidSaveString's appendString:("\n"))
	end if
end repeat
#######################################
###　戻り値
#######################################
set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias

tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
set strMes to ("BookMarkエイリアスの戻り値です") as text
try
	set recordResult to (display dialog strMes with title strMes default answer (ocidSaveString as text) buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer) as record
on error
	log "エラーしました"
end try
if (gave up of recordResult) is true then
	return "時間切れです"
end if
##############################
#####値のコピー
##############################
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

