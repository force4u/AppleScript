#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

###フォントブックを終了
tell application id "com.apple.FontBook"
	quit
end tell

##############################
###ライブラリ名を指定 ダイアログ
set appFileManager to refMe's NSFileManager's defaultManager()
###FontCollectionsのフォルダパス
set ocidUserLibraryPathArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserLibraryPath to ocidUserLibraryPathArray's firstObject()
set ocidFontCollectionsURL to ocidUserLibraryPath's URLByAppendingPathComponent:("FontCollections") isDirectory:(true)
set aliasFontCollectionsURL to ocidFontCollectionsURL's absoluteURL() as alias
##############################
#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set strDefaultName to "MobileAsset_Font7.library" as text
set strExtension to "library"
set strPromptText to "フォントライブラリの名前を決めてください" as text
set strMesText to "フォントライブラリの名前を決めてください" as text
set aliasFilePath to (choose file name strMesText default location aliasFontCollectionsURL default name strDefaultName with prompt strPromptText) as «class furl»
######
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
set ocidFileName to ocidFilePathURL's lastPathComponent()
set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
set ocidExtensionName to ocidFilePathURL's pathExtension()
###空の文字列　if文用
set ocidEmptyString to refMe's NSString's alloc()'s init()
if ocidExtensionName = ocidEmptyString then
	###ダイアログで拡張子取っちゃった場合対策
	set ocidFilePathURL to ocidFilePathURL's URLByAppendingPathExtension:(strExtension)
end if
##############################
#####　フォント選択
set strFontsDirPath to "/System/Library/AssetsV2/com_apple_MobileAsset_Font7"
set ocidFontsDirPathStr to refMe's NSString's stringWithString:(strFontsDirPath)
set ocidFontsDirPath to ocidFontsDirPathStr's stringByStandardizingPath()
set ocidFontsDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFontsDirPath) isDirectory:false)
###ダイアログ
set aliasFontCollectionsURL to ocidFontsDirPathURL's absoluteURL() as alias
set strMes to "フォルダを選んでください"
set strPrompt to "フォントをライブラリに登録するフォルダ（フォントが入っているフォルダ）を選んでください"
set aliasFolderPath to (choose folder strMes with prompt strPrompt default location aliasFontCollectionsURL with invisibles and showing package contents without multiple selections allowed)
##############################
###読み込むフォントのパス
set strFontsDirPath to POSIX path of aliasFolderPath as text
set ocidFontsDirPathStr to refMe's NSString's stringWithString:(strFontsDirPath)
set ocidFontsDirPath to ocidFontsDirPathStr's stringByStandardizingPath()
set ocidFontsDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFontsDirPath) isDirectory:true)


##############################
##### System Local Application ドメイン専用
if strFontsDirPath starts with "/Users" then
	set strMes to "このスクリプトは、System Local Application ドメイン専用です" as text
	display alert (strMes) buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" as informational giving up after 10
	return strMes
end if
###enumeratorAtURLL格納するリスト
set ocidEmuFileURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
###フォントファイルのURLのみを格納するリスト
set ocidFontFilePathURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0

##############################
#####ディレクトリのコンテツを収集
###収集する付随プロパティ
set ocidPropertiesForKeys to {(refMe's NSURLContentTypeKey), (refMe's NSURLIsRegularFileKey)}
####ディレクトリのコンテツを収集
set ocidEmuDict to (appFileManager's enumeratorAtURL:(ocidFontsDirPathURL) includingPropertiesForKeys:ocidPropertiesForKeys options:(refMe's NSDirectoryEnumerationSkipsPackageDescendants) errorHandler:(reference))
###戻り値用のリストに格納
ocidEmuFileURLArray's addObjectsFromArray:(ocidEmuDict's allObjects)

##############################
#####『ファイル』だけ取り出したリストにする
####enumeratorAtURLのかずだけ繰り返し
repeat with itemEmuFileURL in ocidEmuFileURLArray
	
	####URLをforKeyで取り出し
	set listResult to (itemEmuFileURL's getResourceValue:(reference) forKey:(refMe's NSURLIsRegularFileKey) |error|:(reference))
	###リストからNSURLIsRegularFileKeyのBOOLを取り出し
	set boolIsRegularFileKey to item 2 of listResult
	log boolIsRegularFileKey as text
	####ファイルのみを(ディレクトリやリンボリックリンクは含まない）
	if boolIsRegularFileKey is (refMe's NSNumber's numberWithBool:true) then
		set listResult to (itemEmuFileURL's getResourceValue:(reference) forKey:(refMe's NSURLContentTypeKey) |error|:(reference))
		set ocidContentType to item 2 of listResult
		set strUTI to (ocidContentType's identifier) as text
		if strUTI contains "font" then
			####リストにする
			(ocidFontFilePathURLArray's addObject:(itemEmuFileURL))
		end if
	end if
end repeat

##############################
#####URL格納用(absoluteString)
set ocidFontPathArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
repeat with itemAliasFontPath in ocidFontFilePathURLArray
	(ocidFontPathArray's addObject:(itemAliasFontPath))
end repeat

##############################
##### PLIST処理
###PLISTのデータになるDict
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###bookmarks
set ocidBookmarks to refMe's NSMutableDictionary's alloc()'s init()
ocidPlistDict's setObject:(ocidBookmarks) forKey:("bookmarks")
#####################
###containerURLs
set ocidContainerURLs to refMe's NSMutableArray's alloc()'s initWithCapacity:0
###フォントのURLを追加(absoluteString形式)
repeat with itemFontPathArray in ocidFontPathArray
	set strAbsoluteStringPath to (itemFontPathArray's absoluteString())
	(ocidContainerURLs's addObject:(strAbsoluteStringPath))
end repeat
ocidPlistDict's setObject:(ocidContainerURLs) forKey:("containerURLs")
###disabled
set ocidFalse to (refMe's NSNumber's numberWithBool:false)
ocidPlistDict's setValue:(ocidFalse) forKey:("disabled")
###name
ocidPlistDict's setValue:(ocidBaseFileName) forKey:("name")
###reference
set ocidReference to refMe's NSNumber's numberWithInteger:(1)
ocidPlistDict's setValue:(ocidReference) forKey:("reference")
###date
set ocidDate to (refMe's NSDate's |date|())
set ocidFormatter to refMe's NSDateFormatter's alloc()'s init()
ocidFormatter's setDateFormat:("yyyy-MM-dd'T'HH:mm:ss'Z'")
ocidFormatter's setTimeZone:(refMe's NSTimeZone's timeZoneWithAbbreviation:("UTC"))
set ocidSetDate to ocidFormatter's stringFromDate:(ocidDate)
-->string形式でセットするのでsetValueで
ocidPlistDict's setValue:(ocidSetDate) forKey:("date")
#####################
###urlAddedDates
set ocidUrlAddedDates to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###フォントのURLを追加(absoluteString形式)
repeat with itemFontPathArray in ocidFontPathArray
	set strPath to (itemFontPathArray's |path|())
	(ocidUrlAddedDates's setValue:(ocidSetDate) forKey:(strPath))
end repeat
ocidPlistDict's setObject:(ocidUrlAddedDates) forKey:("urlAddedDates")
###version
ocidFormatter's setDateFormat:("yyyyMMdd")
set ocidversion to ocidFormatter's stringFromDate:(ocidDate)
ocidPlistDict's setValue:(ocidversion) forKey:("version")

######################
###XML形式
set ocidXmlplist to refMe's NSPropertyListXMLFormat_v1_0
####書き込み用にXMLに変換
set ocidPlistEditData to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidXmlplist) options:0 |error|:(missing value)
####書き込み
ocidPlistEditData's writeToURL:(ocidFilePathURL) atomically:true


###フォントブックを起動
tell application id "com.apple.FontBook"
	launch
end tell


return
