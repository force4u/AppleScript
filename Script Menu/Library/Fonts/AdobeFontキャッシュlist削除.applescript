#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

set objFileManager to refMe's NSFileManager's defaultManager()


##############################################
## ダイアログ関連
##############################################
####デフォルトロケーション
set ocidUrlArray to (objFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
###LibraryフォルダURL
set ocidAppSupDirPathURL to ocidUrlArray's firstObject()
set ocidAdobeFilePathURL to ocidAppSupDirPathURL's URLByAppendingPathComponent:"Adobe"
set aliasDefaultLocation to ocidAdobeFilePathURL as alias
####プロンプトテキスト
set strPromptText to "フォルダ選んでください" as text
try
	set aliasFolderPath to (choose folder strPromptText with prompt strPromptText default location aliasDefaultLocation without multiple selections allowed, invisibles and showing package contents) as alias
on error
	log "エラーしました"
	return
end try

##############################################
##入力フォルダ パス
##############################################
####パス
set strFolderPath to POSIX path of aliasFolderPath as text
####パスをNSString
set ocidFolderPath to refMe's NSString's stringWithString:strFolderPath
####ドキュメントのパスをNSURLに
set ocidFolderPathURL to refMe's NSURL's fileURLWithPath:ocidFolderPath

##############################################
##準備
##############################################
###enumeratorAtURL用のBoolean用
set ocidFalse to (refMe's NSNumber's numberWithBool:false)
set ocidTrue to (refMe's NSNumber's numberWithBool:true)
###enumeratorAtURLL格納用のレコード
set ocidEmuDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###enumeratorAtURLL格納するリスト
set ocidEmuFileURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
###ファイルURLのみを格納するリスト
set ocidFilePathURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0



##############################################
##ディレクトリのコンテツを収集
##############################################
###収集する付随プロパティ
set ocidPropertiesForKeys to {refMe's NSURLIsRegularFileKey}
####ディレクトリのコンテツを収集
set ocidEmuDict to (objFileManager's enumeratorAtURL:ocidFolderPathURL includingPropertiesForKeys:ocidPropertiesForKeys options:(refMe's NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:(reference))
###戻り値用のリストに格納
set ocidEmuFileURLArray to ocidEmuDict's allObjects()


##############################################
##『ファイル』だけ取り出したリストにする
##############################################

####enumeratorAtURLのかずだけ繰り返し
repeat with itemEmuFileURL in ocidEmuFileURLArray
	####URLをforKeyで取り出し
	set listResult to (itemEmuFileURL's getResourceValue:(reference) forKey:(refMe's NSURLIsRegularFileKey) |error|:(reference))
	###リストからNSURLIsRegularFileKeyのBOOLを取り出し
	set boolIsRegularFileKey to item 2 of listResult
	####ファイルのみを(ディレクトリやリンボリックリンクは含まない）
	if boolIsRegularFileKey is ocidTrue then
		####リストにする
		(ocidFilePathURLArray's addObject:itemEmuFileURL)
	end if
end repeat


###解放
set ocidEmuFileURLArray to ""
set ocidEmuDict to ""
(*
ここで『ocidFilePathURLArray』に全ファイルのリストが入る
*)
##############################################
##本処理
##############################################

repeat with itemFilePath in ocidFilePathURLArray
	####アクロバットのフォントキャッシュをゴミ箱に
	set ocidFileName to itemFilePath's lastPathComponent()
	if (ocidFileName as text) is "UserCache64.bin" then
		set listResult to (objFileManager's trashItemAtURL:itemFilePath resultingItemURL:(missing value) |error|:(reference))
	end if
	
	#####拡張子lstをゴミ箱に
	set ocidExtensionName to itemFilePath's pathExtension()
	if (ocidExtensionName as text) is "lst" then
		set listResult to (objFileManager's trashItemAtURL:itemFilePath resultingItemURL:(missing value) |error|:(reference))
	end if
end repeat


###################################
########Libraryフォルダ
###################################
set ocidUserLibraryPath to (objFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
###LibraryフォルダURL
set ocidLibraryPathURL to ocidUserLibraryPath's firstObject()
set ocidFolderPathURL to ocidLibraryPathURL's URLByAppendingPathComponent:"Caches/Adobe/"


##############################################
##準備
##############################################
###enumeratorAtURL用のBoolean用
set ocidFalse to (refMe's NSNumber's numberWithBool:false)
set ocidTrue to (refMe's NSNumber's numberWithBool:true)
###enumeratorAtURLL格納用のレコード
set ocidEmuDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###enumeratorAtURLL格納するリスト
set ocidEmuFileURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
###ファイルURLのみを格納するリスト
set ocidFilePathURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0



##############################################
##ディレクトリのコンテツを収集
##############################################
###収集する付随プロパティ
set ocidPropertiesForKeys to {refMe's NSURLIsRegularFileKey}
####ディレクトリのコンテツを収集
set ocidEmuDict to (objFileManager's enumeratorAtURL:ocidFolderPathURL includingPropertiesForKeys:ocidPropertiesForKeys options:(refMe's NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:(reference))
###戻り値用のリストに格納
set ocidEmuFileURLArray to ocidEmuDict's allObjects()


##############################################
##『ファイル』だけ取り出したリストにする
##############################################

####enumeratorAtURLのかずだけ繰り返し
repeat with itemEmuFileURL in ocidEmuFileURLArray
	####URLをforKeyで取り出し
	set listResult to (itemEmuFileURL's getResourceValue:(reference) forKey:(refMe's NSURLIsRegularFileKey) |error|:(reference))
	###リストからNSURLIsRegularFileKeyのBOOLを取り出し
	set boolIsRegularFileKey to item 2 of listResult
	####ファイルのみを(ディレクトリやリンボリックリンクは含まない）
	if boolIsRegularFileKey is ocidTrue then
		####リストにする
		(ocidFilePathURLArray's addObject:itemEmuFileURL)
	end if
end repeat


###解放
set ocidEmuFileURLArray to ""
set ocidEmuDict to ""
(*
ここで『ocidFilePathURLArray』に全ファイルのリストが入る
*)
##############################################
##本処理
##############################################

repeat with itemFilePath in ocidFilePathURLArray
	set ocidFileName to itemFilePath's lastPathComponent()
	#####拡張子lstをゴミ箱に
	set ocidExtensionName to itemFilePath's pathExtension()
	if (ocidExtensionName as text) is "lst" then
		set listResult to (objFileManager's trashItemAtURL:itemFilePath resultingItemURL:(missing value) |error|:(reference))
	end if
end repeat
