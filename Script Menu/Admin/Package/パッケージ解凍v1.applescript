#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#	フォルダ名を明確にした 第一階層のみ解凍
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions


property refMe : a reference to current application

######ファイルのオープン
on run
	set theWithPrompt to "flat packageを拡張してbundles packageに変換します"
	set theDefLoc to path to downloads folder from user domain
	set theFileTypeList to {"com.apple.installer-package", "com.apple.application-bundle", "com.apple.installer-package-archive"} as list
	set aliasFilePathAlias to (choose file default location theDefLoc ¬
		with prompt theWithPrompt ¬
		of type theFileTypeList ¬
		invisibles true ¬
		with showing package contents without multiple selections allowed)
	open aliasFilePathAlias
end run

######ドロップのオープン
on open aliasFilePathAlias
	
	set appFileManager to refMe's NSFileManager's defaultManager()
	set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
	
	####選択したパッケージのパス
	set strOrigFilePath to POSIX path of aliasFilePathAlias as text
	set ocidOrigPkgFilePath to (refMe's NSString's stringWithString:strOrigFilePath)
	set ocidOrigFileName to ocidOrigPkgFilePath's lastPathComponent()
	set strBaseFileName to ocidOrigFileName's stringByDeletingPathExtension()
	
	####ユーザーダウンロードフォルダ
	set ocidUserDownloadsPathArray to (appFileManager's URLsForDirectory:(refMe's NSDownloadsDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidUserDownloadsPathURL to ocidUserDownloadsPathArray's objectAtIndex:0
	#####展開フォルダ名
	set strDirName to ("解凍済" & strBaseFileName) as text
	set ocidSaveDirPathURL to ocidUserDownloadsPathURL's URLByAppendingPathComponent:(strDirName)
	###フォルダを作る
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	
	
	###pkgの展開先
	set ocidExpandPkgPathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strBaseFileName)
	set strSaveDirPathURL to ocidExpandPkgPathURL's |path|() as text
	####コマンド実行
	set theComandText to "/usr/sbin/pkgutil  --expand  \"" & strOrigFilePath & "\" \"" & strSaveDirPathURL & "\"" as text
	do shell script theComandText
	
	#############################
	###Finderでフォルダを開く
	#############################
	appShardWorkspace's openURL:ocidExpandPkgPathURL
end open
