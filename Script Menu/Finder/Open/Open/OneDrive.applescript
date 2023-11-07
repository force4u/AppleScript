#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
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
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()

###################################
#####パス
###################################
set ocidHomeDirUrl to appFileManager's homeDirectoryForCurrentUser()
set ocidCloudStorageDirURL to ocidHomeDirUrl's URLByAppendingPathComponent:"Library/CloudStorage"

###################################
#####個人向きと企業向き
###################################
###プロパティ設定
set ocidPropertieKey to {(refMe's NSURLPathKey), (refMe's NSURLIsDirectoryKey)}
###オプション設定
set ocidOption to refMe's NSDirectoryEnumerationSkipsHiddenFiles
###ディレクトリのコンテンツを取得（第一階層のみ）
set listPathUrlArray to (appFileManager's contentsOfDirectoryAtURL:ocidCloudStorageDirURL includingPropertiesForKeys:ocidPropertieKey options:ocidOption |error|:(reference))
###Arrayに格納
set ocidPathUrlArray to item 1 of listPathUrlArray
###パス格納用のArrayを作って
set ocidPathArray to (refMe's NSMutableArray's arrayWithCapacity:0)
####コンテンツの数だけ繰り返し
repeat with itemPathUrlArray in ocidPathUrlArray
	###最後のパスを取得して
	set ocidLastPathName to itemPathUrlArray's lastPathComponent()
	###テキストに
	set strLastPathName to ocidLastPathName as text
	###最後のパスにBoxが含まれていたら
	if strLastPathName starts with "OneDrive" then
		###Arrayに格納
		(ocidPathArray's addObject:itemPathUrlArray)
	end if
end repeat

###################################
#####開く
###################################
repeat with itemPathArray in ocidPathArray
	set aliasFilePathURL to itemPathArray as alias
	set boolResults to (appShardWorkspace's openURL:itemPathArray)
	if boolResults is false then
		tell application "Finder"
			make new Finder window to aliasFilePathURL
		end tell
	end if
end repeat


return




