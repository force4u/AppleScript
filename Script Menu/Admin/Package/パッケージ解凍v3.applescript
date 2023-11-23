#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	第２階層まで解凍する
#	フォルダ名を明確にした
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
	set theFileTypeList to {"com.apple.installer-package-archive"} as list
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
	####展開　パッケージを調べて
	set listResult to appFileManager's contentsOfDirectoryAtURL:ocidExpandPkgPathURL includingPropertiesForKeys:{refMe's NSURLPathKey} options:0 |error|:(reference)
	set listFilePathURLArray to item 1 of listResult
	####内包されているファイル
	repeat with itemFilePathURLArray in listFilePathURLArray
		####拡張子PKGだけ実施
		set strExtension to itemFilePathURLArray's pathExtension() as text
		if strExtension is "pkg" then
			set ocidPkgName to itemFilePathURLArray's lastPathComponent()
			
			
			set strPkgFolderName to (ocidPkgName as text) & "_Folder"
			set ocidDistPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:strPkgFolderName)
			set boolMoveFileAndRename to (appFileManager's moveItemAtURL:itemFilePathURLArray toURL:ocidDistPathURL |error|:(reference))
			set ocidPayLoardPathURL to (ocidDistPathURL's URLByAppendingPathComponent:"Payload")
			set strPayLoardPathURL to ocidPayLoardPathURL's |path|() as text
			set strSaveDirPathURL to (ocidPayLoardPathURL's URLByDeletingLastPathComponent())'s |path|() as text
			#####解凍コピー
			try
				set theComandText to ("/usr/bin/ditto  -xz   \"" & strPayLoardPathURL & "\"   \"" & strSaveDirPathURL & "\"") as text
				do shell script theComandText
			end try
		end if
	end repeat
	#############################
	###Finderでフォルダを開く
	#############################
	appShardWorkspace's openURL:ocidExpandPkgPathURL
end open
