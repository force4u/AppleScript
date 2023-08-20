#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()


###フォルダ名
set strFolderName to ("サンプルフォルダ") as text


###デスクトップURL
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
###作成予定のフォルダのURL
set ocidNewDirPathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strFolderName)
###↑このURLがIS DIRECTORY　フォルダなのか？確認
set listResult to (ocidNewDirPathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
###↑の判定で分岐
if (item 1 of listResult) is false then
	log "パスが存在しません フォルダを作成します"
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 777-->511 755-->493 700-->448 766-->502 
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidNewDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)
else if (item 1 of listResult) is true then
	log "パスが存在します。ファイルが存在するのか？フォルダが存在するのか？を確認"
	if (item 2 of listResult) = (refMe's NSNumber's numberWithBool:true) then
		log "パスはフォルダです　名前に連番を付与して作成します"
		set numStarNO to 2 as integer
	else if (item 2 of listResult) = (refMe's NSNumber's numberWithBool:false) then
		log "パスはファイルです　名前に連番を付与して作成します"
		set numStarNO to 0 as integer
	else
		return "処理に失敗しました"
	end if
	###最大１００番まで繰り返す
	repeat with itemIntNo from numStarNO to 100 by 1
		###指定のフォルダ名＋連番
		set strSameFolderName to (strFolderName & " " & itemIntNo) as text
		###連番付きのフォルダ名
		set ocidSameDirPathURL to (ocidDesktopDirPathURL's URLByAppendingPathComponent:(strSameFolderName))
		set ocidSameDirPath to ocidSameDirPathURL's |path|()
		###パスの有無
		set boolDirExists to (appFileManager's fileExistsAtPath:(ocidSameDirPath) isDirectory:(true))
		if boolDirExists is false then
			###フォルダを作る
			set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
			# 777-->511 755-->493 700-->448 766-->502 
			(ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions))
			set listBoolMakeDir to (appFileManager's createDirectoryAtURL:(ocidSameDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference))
			exit repeat
		end if
	end repeat
else
	return "処理に失敗しました"
end if

return
