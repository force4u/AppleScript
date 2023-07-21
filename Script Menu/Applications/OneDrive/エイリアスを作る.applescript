#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#デスクトップにクラウドドライブのエイリアスを作ります
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

################################################
####クラウドストレージ内のOneDriveフォルダが複数ある場合対応
################################################
##ホームディレクトリ
set ocidHomeDirUrl to appFileManager's homeDirectoryForCurrentUser()
###クラウドストレージ
set ocidCloudStorageDirURL to ocidHomeDirUrl's URLByAppendingPathComponent:"Library/CloudStorage"
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
	###最後のパスにOneDriveが含まれていたら
	if strLastPathName starts with "OneDrive" then
		###そのパスをUNIXパス形式で
		set ocidDirPath to itemPathUrlArray's |path|()
		###Arrayに格納
		(ocidPathArray's addObject:ocidDirPath)
	end if
end repeat


####################################
###アイコンのパス
set strIconFilePath to "/Applications/OneDrive.app/Contents/Resources/OneDrive.icns" as text

####################################
####エイリアスが作られる場所 デスクトップ
set ocidDesktopFilePathURL to ocidHomeDirUrl's URLByAppendingPathComponent:"Desktop"

################################################
####クラウドストレージ内のOneDriveフォルダの数だけ繰り返し
################################################
repeat with itemPathArray in ocidPathArray
	set strItemPath to itemPathArray as text
	####################################
	####エイリアスの元ファイル
	####################################
	set ocidFilePathStr to (refMe's NSString's stringWithString:strItemPath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false)
	set ocidDirName to ocidFilePathURL's lastPathComponent()
	###デスクトップにフォルダ名を追加してエリアスのパスに
	set ocidAddAliasFilePathURL to (ocidDesktopFilePathURL's URLByAppendingPathComponent:ocidDirName)
	set strAddAliasFilePath to ocidAddAliasFilePathURL's |path|() as text
	
	####################################
	#### エイリアスを作る
	####################################
	set listBookMarkNSData to (ocidFilePathURL's bookmarkDataWithOptions:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) includingResourceValuesForKeys:{refMe's NSURLCustomIconKey} relativeToURL:(missing value) |error|:(reference))
	set ocdiBookMarkData to (item 1 of listBookMarkNSData)
	set listResults to (refMe's NSURL's writeBookmarkData:(ocdiBookMarkData) toURL:(ocidAddAliasFilePathURL) options:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) |error|:(reference))
	
	####################################
	#### アイコンを付与
	####################################
	###ICONパス
	set ocidIconPathStr to (refMe's NSString's stringWithString:(strIconFilePath))
	set ocidIconPath to ocidIconPathStr's stringByStandardizingPath()
	set ocidIconPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidIconPath) isDirectory:false)
	##アイコン用のイメージデータ取得
	set ocidImageData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidIconPathURL))
	###NSWorkspace初期化
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	###アイコン付与
	set boolAddIcon to (appSharedWorkspace's setIcon:(ocidImageData) forFile:(strAddAliasFilePath) options:(refMe's NSExclude10_4ElementsIconCreationOption))
	
	
end repeat

return
