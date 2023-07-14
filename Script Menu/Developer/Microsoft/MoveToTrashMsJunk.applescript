#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
(*
linkCreation.dotm
SaveAsAdobePDF.ppam
SaveAsAdobePDF.xlam
この３種の一時ファイルを削除します
*)
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use scripting additions


property refMe : a reference to current application


set appFileManager to refMe's NSFileManager's defaultManager()

set strFilePathA to "~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Startup.localized/Word/~$nkCreation.dotm"
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePathA)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false
set boolDone to doMoveToTrash(ocidFilePathURL)

set strFilePathB to "~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Startup.localized/Excel/~$SaveAsAdobePDF.xlam"
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePathB)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false
set boolDone to doMoveToTrash(ocidFilePathURL)

set strFilePathC to "~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Startup.localized/Powerpoint/~$SaveAsAdobePDF.ppam"
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePathB)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false
set boolDone to doMoveToTrash(ocidFilePathURL)



set strFilePathA to "~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Add-Ins.localized/Word/~$nkCreation.dotm"
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePathA)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false
set boolDone to doMoveToTrash(ocidFilePathURL)

set strFilePathB to "~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Add-Ins.localized/Excel/~$SaveAsAdobePDF.xlam"
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePathB)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false
set boolDone to doMoveToTrash(ocidFilePathURL)

set strFilePathC to "~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Add-Ins.localized/Powerpoint/~$SaveAsAdobePDF.ppam"
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePathB)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false
set boolDone to doMoveToTrash(ocidFilePathURL)


set strDirFilePath to "~/Library/Group Containers/UBF8T346G9.Office/User Content.localized"
set ocidFilePathStr to refMe's NSString's stringWithString:(strDirFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:true
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
appShardWorkspace's openURL:ocidFilePathURL



to doMoveToTrash(argFilePath)
	###ファイルマネジャー初期化
	set appFileManager to refMe's NSFileManager's defaultManager()
	#########################################
	###渡された値のClassを調べてとりあえずNSURLにする
	set refClass to class of argFilePath
	if refClass is list then
		return "エラーリストは処理しません"
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
		log "処理中止"
		return false
	end if
	#########################################
	###NSURLがディレクトリなのか？ファイルなのか？
	set listBoolDir to ocidArgFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference)
	if (item 2 of listBoolDir) = ocidTrue then
		#########################################
		log "ディレクトリです"
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
		###念のためFilderでも調べる
		tell application "Finder"
			set aliasArgFilePath to ocidArgFilePathURL as alias
			set strPathKind to (kind of aliasArgFilePath) as text
		end tell
		###/tmpのような特殊フォルダの場合は処理しない
		if strPathKind is "フォルダ" then
			return "特殊ディレクトリかシンボリックリンクなので処理しません"
		else
			###ファイルをゴミ箱に入れる
			set listResult to (appFileManager's trashItemAtURL:ocidArgFilePathURL resultingItemURL:(missing value) |error|:(reference))
		end if
	end if
	return true
end doMoveToTrash
