#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirURL to ocidURLsArray's firstObject()
set ocidContainersDirPathURL to ocidLibraryDirURL's URLByAppendingPathComponent:("Containers")

set ocidOption to refMe's NSDirectoryEnumerationSkipsHiddenFiles
set ocidKeyArray to refMe's NSArray's arrayWithArray:({(refMe's NSURLPathKey), (refMe's NSURLIsDirectoryKey), (refMe's NSURLIsSymbolicLinkKey)})
set listSubPathResult to (appFileManager's contentsOfDirectoryAtURL:(ocidContainersDirPathURL) includingPropertiesForKeys:(ocidKeyArray) options:(ocidOption) |error|:(reference))
set ocidSubPathURLArray to item 1 of listSubPathResult
repeat with itemSubPathURL in ocidSubPathURLArray
	set ocidCachesDirPathURL to (itemSubPathURL's URLByAppendingPathComponent:("Data/Library/Caches"))
	###【１】シンボリックリンクか？判定
	set litsBoolIsSymLink to (ocidCachesDirPathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsSymbolicLinkKey) |error|:(reference))
	if (item 2 of litsBoolIsSymLink) = (refMe's NSNumber's numberWithBool:true) then
		log "シンボリックリンクなので処理しない"
	else if (item 2 of litsBoolIsSymLink) = (refMe's NSNumber's numberWithBool:false) then
		###【２】ディレクトリか？判定
		set litsBoolIsDir to (ocidCachesDirPathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		if (item 2 of litsBoolIsDir) = (refMe's NSNumber's numberWithBool:false) then
			log "フォルダでは無いなら処理しない"
		else
			###【３】ディレクトリの中のコンテンツの取得
			set listCachesDirPathResult to (appFileManager's contentsOfDirectoryAtURL:(ocidCachesDirPathURL) includingPropertiesForKeys:(ocidKeyArray) options:(ocidOption) |error|:(reference))
			set ocidCachesDirPathResultArray to item 1 of listCachesDirPathResult
			###【３】で取得したコンテンツの結果があるならゴミ箱に入れる
			if ocidCachesDirPathResultArray ≠ (missing value) then
				repeat with itemCachesDirPathURL in ocidCachesDirPathResultArray
					##log itemachesDirPath's |path|() as text
					##ゴミ箱に入れる
					set listResult to (appFileManager's trashItemAtURL:(itemCachesDirPathURL) resultingItemURL:(itemCachesDirPathURL) |error|:(reference))
				end repeat
			else
				log "３のディレクトリの中身が空なので処理するものがない"
			end if
		end if
	end if
end repeat
