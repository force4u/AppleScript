#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# Microsoft Teams (work or school)のキャッシュ２ゴミ箱
# 先に主要なアプリは終了させてから　
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application

set strBundleID to ("com.microsoft.teams2") as text


set appFileManager to refMe's NSFileManager's defaultManager()
###
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
#
set ocidContainersDirPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Containers")
set ocidBundaleDirPathURL to ocidContainersDirPathURL's URLByAppendingPathComponent:(strBundleID)
#
set ocidCachesDirPathURL to ocidBundaleDirPathURL's URLByAppendingPathComponent:("Data/Library/Caches")
set ocidTmpDirPathURL to ocidBundaleDirPathURL's URLByAppendingPathComponent:("Data/tmp")
set ocidWebKitDirPathURL to ocidBundaleDirPathURL's URLByAppendingPathComponent:("Data/Library/WebKit")
set ocidEBWebViewDirPathURL to ocidBundaleDirPathURL's URLByAppendingPathComponent:("Data/Library/Application Support/Microsoft/MSTeams/EBWebView")
#ゴミ箱に入れる
log doMoveToTrash(ocidCachesDirPathURL)
log doMoveToTrash(ocidTmpDirPathURL)
log doMoveToTrash(ocidWebKitDirPathURL)
log doMoveToTrash(ocidEBWebViewDirPathURL)
###################################
########処理　ゴミ箱に入れる
###################################
to doMoveToTrash(argFilePath)
	###ファイルマネジャー初期化
	set appFileManager to refMe's NSFileManager's defaultManager()
	#########################################
	###渡された値のClassを調べてとりあえずNSURLにする
	set refClass to class of argFilePath
	if refClass is list then
		return "エラー:リストは処理しません"
	else if refClass is text then
		log "テキストパスです"
		set ocidArgFilePathStr to (refMe's NSString's stringWithString:argFilePath)
		set ocidArgFilePath to ocidArgFilePathStr's stringByStandardizingPath
		set ocidArgFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidArgFilePath)
	else if refClass is alias then
		log "エイリアスパスです"
		set strArgFilePath to (POSIX path of argFilePath) as text
		set ocidArgFilePathStr to (refMe's NSString's stringWithString:strArgFilePath)
		set ocidArgFilePath to ocidArgFilePathStr's stringByStandardizingPath
		set ocidArgFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidArgFilePath)
	else
		set refClass to (className() of argFilePath) as text
		if refClass contains "NSPathStore2" then
			log "NSPathStore2です"
			set ocidArgFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:argFilePath)
		else if refClass contains "NSCFString" then
			log "NSCFStringです"
			set ocidArgFilePath to argFilePath's stringByStandardizingPath
			set ocidArgFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidArgFilePath)
		else if refClass contains "NSURL" then
			set ocidArgFilePathURL to argFilePath
			log "NSURLです"
		end if
	end if
	#########################################
	###
	-->false
	set ocidFalse to (refMe's NSNumber's numberWithBool:false)'s boolValue
	-->true
	set ocidTrue to (refMe's NSNumber's numberWithBool:true)'s boolValue
	#########################################
	###NSURLがエイリアス実在するか？
	set ocidArgFilePath to ocidArgFilePathURL's |path|()
	set boolFileAlias to appFileManager's fileExistsAtPath:(ocidArgFilePath)
	###パス先が実在しないなら処理はここまで
	if boolFileAlias = false then
		log ocidArgFilePath as text
		log "処理中止 パス先が実在しない"
		return false
	end if
	#########################################
	###NSURLがディレクトリなのか？ファイルなのか？
	set listBoolDir to ocidArgFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference)
	#		log (item 1 of listBoolDir)
	#		log (item 2 of listBoolDir)
	#		log (item 3 of listBoolDir)
	if (item 2 of listBoolDir) = ocidTrue then
		#########################################
		log "ディレクトリです"
		log ocidArgFilePathURL's |path| as text
		##内包リスト
		set listResult to appFileManager's contentsOfDirectoryAtURL:ocidArgFilePathURL includingPropertiesForKeys:{refMe's NSURLPathKey} options:0 |error|:(reference)
		###結果
		set ocidContentsPathURLArray to item 1 of listResult
		###リストの数だけ繰り返し
		repeat with itemContentsPathURL in ocidContentsPathURLArray
			###ゴミ箱に入れる
			set listResult to (appFileManager's trashItemAtURL:itemContentsPathURL resultingItemURL:(missing value) |error|:(reference))
		end repeat
	else
		#########################################
		log "ファイルです"
		set listBoolDir to ocidArgFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsAliasFileKey) |error|:(reference)
		if (item 2 of listBoolDir) = ocidTrue then
			log "エイリアスは処理しません"
			return false
		end if
		set listBoolDir to ocidArgFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsSymbolicLinkKey) |error|:(reference)
		if (item 2 of listBoolDir) = ocidTrue then
			log "シンボリックリンクは処理しません"
			return false
		end if
		set listBoolDir to ocidArgFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsSystemImmutableKey) |error|:(reference)
		if (item 2 of listBoolDir) = ocidTrue then
			log "システムファイルは処理しません"
			return false
		end if
		###ファイルをゴミ箱に入れる
		set listResult to (appFileManager's trashItemAtURL:ocidArgFilePathURL resultingItemURL:(missing value) |error|:(reference))
	end if
	return true
end doMoveToTrash

