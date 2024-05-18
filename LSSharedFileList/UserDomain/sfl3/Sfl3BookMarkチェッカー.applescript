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
##SFL3専用　他ファイルは排除
set strExtensionName to ocidSfl3FilePathURL's pathExtension() as text
if strExtensionName is not "sfl3" then
	return "sfl3専用です"
end if
#######################################
##NSdataに読み込み　Keyを解凍する
#######################################
###【１】NSDataに読み込む
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listResponse to refMe's NSData's dataWithContentsOfURL:(ocidSfl3FilePathURL) options:(ocidOption) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "正常処理"
	set ocidPlistData to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	log (item 2 of listResponse)'s code() as text
	log (item 2 of listResponse)'s localizedDescription() as text
	return "NSDATAでエラーしました"
end if
###【２】NSKeyedUnarchiverで解凍してDictに
#macOS13まで
#set ocidArchveDict to (refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData))
#macOS14から
set listResponse to (refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:((refMe's NSObject)'s class) fromData:(ocidPlistData) |error|:(reference))
if (item 2 of listResponse) = (missing value) then
	log "正常処理"
	set ocidArchveDict to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	log (item 2 of listResponse)'s code() as text
	log (item 2 of listResponse)'s localizedDescription() as text
	return "NSKeyedUnarchiverでエラーしました"
end if

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
##ダイアログに渡すためのテキスト
set ocidSaveString to refMe's NSMutableString's alloc()'s initWithCapacity:0
#リストの数だけ繰り返し
repeat with itemArray in ocidItemsArray
	set ocidBookMarkData to (itemArray's objectForKey:("Bookmark"))
	#ブックマークの参照先を取得
	set ocidOption to (refMe's NSURLBookmarkResolutionWithoutUI)
	set listResponse to (refMe's NSURL's URLByResolvingBookmarkData:(ocidBookMarkData) options:(ocidOption) relativeToURL:(missing value) bookmarkDataIsStale:(true) |error|:(reference))
	if (item 2 of listResponse) = (missing value) then
		log "正常処理"
		set ocidBookMarkURL to (item 1 of listResponse)
		if ocidBookMarkURL ≠ (missing value) then
			##URLパスを
			set strSetValue to ocidBookMarkURL's absoluteString() as text
			##ダイアログへ渡すテキストに追加していく
			(ocidSaveString's appendString:(strSetValue))
			(ocidSaveString's appendString:("\n"))
		end if
	else if (item 2 of listResponse) ≠ (missing value) then
		log (item 2 of listResponse)'s code() as text
		log (item 2 of listResponse)'s localizedDescription() as text
		log "NSKeyedUnarchiverでエラーしました"
	end if
	
	
end repeat
#######################################
###　戻り値
#######################################
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FinderIcon.icns" as alias

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
	set recordResult to (display dialog strMes with title strMes default answer (ocidSaveString as text) buttons {"クリップボードにコピー", "終了", "再実行"} default button "再実行" cancel button "終了" giving up after 20 with icon aliasIconPath without hidden answer) as record
on error
	return "キャンセルかエラーしました"
end try
if (gave up of recordResult) is true then
	return "時間切れです"
end if
##############################
#####自分自身を再実行
##############################
if button returned of recordResult is "再実行" then
	tell application "Finder"
		set aliasPathToMe to (path to me) as alias
	end tell
	run script aliasPathToMe with parameters "再実行"
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

