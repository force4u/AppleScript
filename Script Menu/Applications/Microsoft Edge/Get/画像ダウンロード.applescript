#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#前面タブの画像をダウンロードフォルダにだうんろーどします
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidFalse to (refMe's NSNumber's numberWithBool:false)

###アプリケーションのバンドルID
set strBundleID to "com.microsoft.edgemac"
###エラー処理
tell application id strBundleID
	set numWindow to (count of every window) as integer
end tell
if numWindow = 0 then
	return "Windowが無いので処理できません"
end if
tell application "Microsoft Edge"
	activate
	tell front window
		tell active tab
			set strURL to URL as text
		end tell
	end tell
end tell

######ホスト名取得
set ocidURLstring to refMe's NSString's stringWithString:(strURL)
set ocidWebURL to refMe's NSURL's alloc()'s initWithString:(ocidURLstring)
set strHostName to ocidWebURL's |host|() as text
####SavePathDir ダウンロードフォルダ
set ocidGetUrlArray to (appFileManager's URLsForDirectory:(refMe's NSDownloadsDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDownloadsDirPathURL to ocidGetUrlArray's objectAtIndex:0
set ocidSaveFileDirURL to (ocidDownloadsDirPathURL's URLByAppendingPathComponent:(strHostName))
###Make Folder SavePathDir　フォルダを作る
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
appFileManager's createDirectoryAtURL:(ocidSaveFileDirURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###ダウンロードするファイル名＝日付
set strDate to doGetDateNo("yyyyMMddhhmmss") as text
### 画像ファイルディレクトリ
set strDirName to (strDate & "_files") as text
set ocidFileDirURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:(strDirName))
set boolDone to appFileManager's createDirectoryAtURL:(ocidFileDirURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
####
set strFileName to (strDate & ".html") as text
set ocidHTMLFileURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:(strFileName))
set ocidHTMLFilePath to ocidHTMLFileURL's |path|()
set boolDone to (appFileManager's createFileAtPath:(ocidHTMLFilePath) |contents|:(missing value) attributes:(missing value))

set aliasFilePath to (ocidHTMLFileURL's absoluteURL()) as alias
set strSaveDirPath to ocidFileDirURL's |path| as text
set aliasSaveDir to (ocidFileDirURL's absoluteURL()) as alias

tell application "Microsoft Edge"
	activate
	tell front window
		tell active tab
			save in aliasFilePath
		end tell
	end tell
end tell
###ファイル生成待ち最大60秒
repeat 60 times
	tell application "Finder"
		set numCntFile to (count of (get every item of aliasSaveDir)) as integer
		log numCntFile
	end tell
	if numCntFile = 0 then
		delay 1
	else
		exit repeat
	end if
end repeat
###コンテンツの収集
set listKeys to {(refMe's NSURLPathKey), (refMe's NSURLContentTypeKey), (refMe's NSURLIsDirectoryKey)} as list
set ocidKeyArray to refMe's NSArray's alloc()'s initWithArray:(listKeys)
###ファイル収集　最下層まで
set ocidEmuDict to appFileManager's enumeratorAtURL:(ocidSaveFileDirURL) includingPropertiesForKeys:(ocidKeyArray) options:(refMe's NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:(reference)
set ocidFileURLArray to ocidEmuDict's allObjects()
###削除しないファイル拡張子
set listExtension to {"jpg", "gif", "png", "jpeg", "webp", "svg", "bmp", "icon", "tiff", "JPG", "GIF", "PNG", "JPEG", "WEBP", "SVG", "BMP", "ICON", "TIFF"} as list

set listExtension to {"ts", "mp4", "webm", "jpg", "gif", "png", "jpeg", "webp", "svg", "bmp", "icon", "tiff", "JPG", "GIF", "PNG", "JPEG", "WEBP", "SVG", "BMP", "ICON", "TIFF"} as list


###収集したURLの数だけ繰り返し
repeat with itemFileURL in ocidFileURLArray
	###ディレクトリは処理しない
	set listBoolDir to (itemFileURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
	if (item 2 of listBoolDir) = ocidFalse then
		set strExtendion to (itemFileURL's pathExtension()) as text
		###拡張子がリストに含まれない場合はゴミ箱に入れる
		set boolContains to (listExtension contains strExtendion) as boolean
		if boolContains is false then
			set listResult to (appFileManager's trashItemAtURL:(itemFileURL) resultingItemURL:(missing value) |error|:(reference))
		end if
	end if
end repeat


############################
####保存先を開く
############################
delay 1
tell application "Finder"
	activate
	open aliasSaveDir
end tell

############################
####英語書式　日付
############################
to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to refMe's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to refMe's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"en_US")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
