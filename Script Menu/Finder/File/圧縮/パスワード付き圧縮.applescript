#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	7zzを利用します（個別にインストールする必要があります）
#	https://github.com/force4u/AppleScript/tree/main/Script%20Menu/Applications/7zz
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

on run
	log "ドロップレット限定用"
	set strAlertMes to "ファイルかフォルダをドロップしてください" as text
	try
		set recordResponse to (display alert ("【ドロップレットです】\r" & strAlertMes) as informational giving up after 10) as record
	on error
		log "エラーしました"
		return "キャンセルしました。処理を中止します。インストールが必要な場合は再度実行してください"
	end try
	if true is equal to (gave up of recordResponse) then
		return "時間切れです。処理を中止します。インストールが必要な場合は再度実行してください"
	end if
	return
end run


on open listDropObject
	###NSFileManager初期化
	set appFileManager to refMe's NSFileManager's defaultManager()
	###Path to me
	tell application "Finder"
		set aliasPathToMe to (path to me) as alias
	end tell
	#######7zzを　アプリケーションに内包する場合
	###UNIXパス
	set strPathToMe to (POSIX path of aliasPathToMe) as text
	##7zzバイナリーへのパス
	set strBinPath to (strPathToMe & "/Contents/bin/7zz") as text
	#######7zzのパスを指定する場合
	##		set strBinPath to ("/some/path/bin/7zz") as text
	
	###ドロップの数だけ繰返し
	repeat with itemDropObject in listDropObject
		#################################
		###処理する判定
		set boolChkAliasPath to true as boolean
		try
			tell application "Finder"
				set strKind to (kind of itemDropObject) as text
			end tell
		on error
			log "シンボリックリンク等kindを取得できないファイルは処理しない"
			set boolChkAliasPath to false as boolean
		end try
		if strKind is "アプリケーション" then
			log "アプリケーションは処理しない"
			set boolChkAliasPath to false as boolean
		else if strKind is "ボリューム" then
			log "ボリュームは処理しない"
			set boolChkAliasPath to false as boolean
		else if strKind is "エイリアス" then
			log "エイリアスは処理しない"
			set boolChkAliasPath to false as boolean
		end if
		#################################
		###trueの場合のみ圧縮処理する
		if boolChkAliasPath is true then
			########################################
			#####パスワード生成　UUIDを利用
			###生成したUUIDからハイフンを取り除く
			set ocidUUIDString to (refMe's NSMutableString's alloc()'s initWithCapacity:0)
			set ocidConcreteUUID to refMe's NSUUID's UUID()
			(ocidUUIDString's setString:(ocidConcreteUUID's UUIDString()))
			set ocidUUIDRange to (ocidUUIDString's rangeOfString:ocidUUIDString)
			(ocidUUIDString's replaceOccurrencesOfString:("-") withString:("") options:(refMe's NSRegularExpressionSearch) range:ocidUUIDRange)
			set strOwnerPassword to ocidUUIDString as text
			########################################
			#####パス
			set strFilePath to (POSIX path of itemDropObject) as text
			set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
			set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
			set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false)
			set ocidDirName to ocidFilePathURL's lastPathComponent()
			set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
			set strDirName to ocidDirName as text
			set strMakeDirName to (strDirName & "_圧縮済")
			set ocidBaseFilePathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:strMakeDirName)
			#####################
			###フォルダを作る
			set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
			(ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions))
			set listBoolMakeDir to (appFileManager's createDirectoryAtURL:(ocidBaseFilePathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
			#####################
			###zipPath
			set ocidDirFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathComponent:(ocidDirName))
			set ocidZipFilePathURL to (ocidDirFilePathURL's URLByAppendingPathExtension:"zip")
			set strZipFilePathURL to ocidZipFilePathURL's |path|() as text
			########################################
			#####パスワード生成　UUIDを利用
			set strTextFileName to strDirName & ".pw.txt"
			set ocidTextFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathComponent:strTextFileName)
			###テキスト
			set strTextFile to "先にお送りしました圧縮ファイル\n『" & strDirName & "』の\n解凍パスワードをお知らせします\n\n" & strOwnerPassword & "\n\n解凍出来ない等ありましたらお知らせください。\n(パスワードをコピー＆ペーストする際に\n改行やスペースが入らないように留意ください)\n" as text
			set ocidPWString to (refMe's NSString's stringWithString:strTextFile)
			set ocidUUIDData to (ocidPWString's dataUsingEncoding:(refMe's NSUTF8StringEncoding))
			#####パスワードを書いたテキストファイルを保存
			set boolResults to (ocidUUIDData's writeToURL:ocidTextFilePathURL atomically:true)
			########################################
			#####コマンド実行
			set strCommandText to ("\"" & strBinPath & "\" a \"" & strZipFilePathURL & "\"   -p" & strOwnerPassword & " \"" & strFilePath & "\"")
			do shell script strCommandText
		end if
	end repeat
	return "処理終了"
end open

