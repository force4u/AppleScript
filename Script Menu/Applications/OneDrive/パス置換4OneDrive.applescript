#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　ファイル名　ディレクトリ名の置換　作成途中
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


### 置換文字列　英数を全角に Creative Cloud Files
##	set strSubstitutionDict to {|"|:"＂", |*|:"＊", |:|:"：", |<|:"＜", |>|:"＞", |?|:"？", |/|:"／", |\\|:"＼", |\||:"｜"} as record
### 置換文字列　英数を全角に Windows
##	set strSubstitutionDict to {|"|:"＂", |*|:"＊", |:|:"：", |<|:"＜", |>|:"＞", |?|:"？", |\\|:"＼", |\||:"｜"} as record
### 置換文字列　英数を全角に OneDrive
set strSubstitutionDict to {|"|:"＂", |*|:"＊", |:|:"：", |<|:"＜", |>|:"＞", |?|:"？", |\\|:"＼", |\||:"｜", |$|:"＄", |~|:"～", |desktop.ini|:"ｄｅｓｋｔｏｐ．ｉｎｉ", _vti_:"＿ｖｔｉ＿", |NUL|:"ＮＵＬ", |AUX|:"ＡＵＸ", |PRN|:"ＰＲＮ", |CON|:"ＣＯＮ", |.lock|:"．ｌｏｃｋ", |;|:"；", |COM0|:"ＣＯＭ０", |COM1|:"ＣＯＭ１", |COM2|:"ＣＯＭ２", |COM3|:"ＣＯＭ３", |COM4|:"ＣＯＭ４", |COM5|:"ＣＯＭ５", |COM6|:"ＣＯＭ６", |COM7|:"ＣＯＭ７", |COM8|:"ＣＯＭ８", |COM9|:"ＣＯＭ９", |LPT0|:"ＬＰＴ０", |LPT1|:"ＬＰＴ１", |LPT2|:"ＬＰＴ２", |LPT3|:"ＬＰＴ３", |LPT4|:"ＬＰＴ４", |LPT5|:"ＬＰＴ５", |LPT6|:"ＬＰＴ６", |LPT7|:"ＬＰＴ７", |LPT8|:"ＬＰＴ８", |LPT9|:"ＬＰＴ９"} as record

##############################
###デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirURL to ocidURLsArray's firstObject()
set ocidCloudStorageDirPathURL to ocidLibraryDirURL's URLByAppendingPathComponent:("CloudStorage")
set aliasCloudStorageDirPath to (ocidCloudStorageDirPathURL's absoluteURL()) as alias

##############################
###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###
set strMes to "フォルダを選んでください" as text
set strPrompt to "フォルダを選択してください" as text
try
	set aliasResponse to (choose folder strMes with prompt strPrompt default location aliasCloudStorageDirPath without multiple selections allowed, invisibles and showing package contents) as alias
on error
	log "エラーしました"
	return
end try
##############################
###パス
set strEmuDirPath to (POSIX path of aliasResponse) as text
set ocidEmuDirPathStr to refMe's NSString's stringWithString:(strEmuDirPath)
set ocidEmuDirPath to ocidEmuDirPathStr's stringByStandardizingPath()
set ocidEmuDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidEmuDirPath) isDirectory:true)
##############################
###EMUモードでファイル収集
set ocidPropertyKeys to {(refMe's NSURLPathKey), (refMe's NSURLNameKey)}
set ocidOption to (refMe's NSDirectoryEnumerationSkipsHiddenFiles)
set ocidEmuDict to (appFileManager's enumeratorAtURL:(ocidEmuDirPathURL) includingPropertiesForKeys:(ocidPropertyKeys) options:(ocidOption) errorHandler:(reference))
##enumeratorAtURLは戻り値がDictなのでArrayにする
set ocidEmuFileURLArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:0
##allObjectsを追加する
ocidEmuFileURLArrayM's addObjectsFromArray:(ocidEmuDict's allObjects())

##############################
### 英数を全角に
set ocidSubstitutionDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidSubstitutionDict's setDictionary:(strSubstitutionDict)
set ocidSubstKeysArray to ocidSubstitutionDict's allKeys()

##############################
### 置換前のパスをゴミ箱に入れるよう
set ocidGoToTrashURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0

##############################
###URLの数だけ繰り返す
repeat with itemEmuFileURL in ocidEmuFileURLArrayM
	set ocidEmuFilePath to itemEmuFileURL's |path|()
	set ocidMovePath to ocidEmuFilePath
	
	##############################
	###パスの文字列を置換
	repeat with itemSubstKeys in ocidSubstKeysArray
		set ocidRepString to (ocidSubstitutionDict's valueForKey:(itemSubstKeys))
		set ocidMovePathRep to (ocidMovePath's stringByReplacingOccurrencesOfString:(itemSubstKeys) withString:(ocidRepString))
		set ocidMovePath to ocidMovePathRep
	end repeat
	set strMovePath to ocidMovePath as text
	set strEmuFilePath to ocidEmuFilePath as text
	##############################
	###パスの文字列に置換が発生したら
	if (ocidEmuFilePath) is not equal to (ocidMovePath) then
		
		(ocidGoToTrashURLArray's addObject:(itemEmuFileURL))
		
		##############################
		###移動先にフォルダが無いとエラーになるのでフォルダを作る
		set listResourveValue to (itemEmuFileURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		set ocidResourveValue to (item 2 of listResourveValue)
		###パスがディレクトリなら
		if (ocidResourveValue as boolean) = true then
			set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
			(ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions))
			set listBoolMakeDir to (appFileManager's createDirectoryAtPath:(ocidMovePath) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		else
			###パスがファイルなら
			set ocidContainerPath to ocidMovePath's stringByDeletingLastPathComponent()
			set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
			(ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions))
			set listBoolMakeDir to (appFileManager's createDirectoryAtPath:(ocidContainerPath) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		end if
		###移動する
		set boolMoveFileAndRename to (appFileManager's moveItemAtPath:(ocidEmuFilePath) toPath:(ocidMovePath) |error|:(reference))
	end if
end repeat


##############################
### 置換前のパスをゴミ箱に入れるよう
repeat with itemGoToTrashURL in ocidGoToTrashURLArray
	set listResult to (appFileManager's trashItemAtURL:(itemGoToTrashURL) resultingItemURL:(missing value) |error|:(reference))
end repeat
