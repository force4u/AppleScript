#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	ファイル＞＞書き出す＞＞アプリケーションにして利用してください
#	
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
	tell application "Finder"
		set aliasPathToMe to (path to me) as alias
	end tell
	#####復号化テンプレートへのパス（アプリに内包する場合）
	###UNIXパス
	set strPathToMe to (POSIX path of aliasPathToMe) as text
	##復号化テンプレートへのパス
	set strTemplates to (strPathToMe & "/Contents/Templates/openssl復号化.applescript") as text
	#####復号化テンプレートへのパス（別の場所にする場合）
	##	set strTemplates to (/some/path/openssl復号化.applescript") as text
	
	##sslパス
	set strBinPath to ("/usr/bin/openssl") as text
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
		else if strKind is "フォルダ" then
			log "フォルダは処理しない"
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
			set strMakeDirName to (strDirName & "_暗号化済")
			set ocidSaveDirPathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:(strMakeDirName))
			#####################
			###フォルダを作る
			set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
			(ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions))
			set listBoolMakeDir to (appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
			#####################
			###復号化テンプレートをコピーする
			##復号化テンプレートへのパス
			set ocidTemplatesPathStr to (refMe's NSString's stringWithString:(strTemplates))
			set ocidTemplatesPath to ocidTemplatesPathStr's stringByStandardizingPath()
			set ocidTemplatesPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidTemplatesPath) isDirectory:false)
			set ocidTemplatesName to ocidTemplatesPathURL's lastPathComponent()
			set ocidSaveTemplatesPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidTemplatesName))
			####
			set listDone to (appFileManager's copyItemAtURL:(ocidTemplatesPathURL) toURL:(ocidSaveTemplatesPathURL) |error|:(reference))
			
			#####################
			###SavePath
			set ocidSaveFilePathURLtmp to (ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidDirName))
			set ocidSaveFilePathURL to (ocidSaveFilePathURLtmp's URLByAppendingPathExtension:"encrypted")
			set strSaveFilePath to ocidSaveFilePathURL's |path|() as text
			########################################
			#####パスワード生成　UUIDを利用
			set strTextFileName to strDirName & ".pw.txt"
			set ocidTextFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:strTextFileName)
			###テキスト
			set strTextFile to "先にお送りしました暗号化済みファイル\n『" & strDirName & "』の\n復号化パスワードをお知らせします\n\n" & strOwnerPassword & "\n\n復号化出来ない等ありましたらお知らせください。\n(パスワードをコピー＆ペーストする際に\n改行やスペースが入らないように留意ください)\n" as text
			set ocidPWString to (refMe's NSString's stringWithString:strTextFile)
			set ocidUUIDData to (ocidPWString's dataUsingEncoding:(refMe's NSUTF8StringEncoding))
			#####パスワードを書いたテキストファイルを保存
			set boolResults to (ocidUUIDData's writeToURL:ocidTextFilePathURL atomically:true)
			########################################
			#####コマンド実行
			set strCommandText to ("\"" & strBinPath & "\" enc -aes-256-cbc -salt   -in  \"" & strFilePath & "\"  -out \"" & strSaveFilePath & "\" -pass pass:\"" & strOwnerPassword & "\"")
			do shell script strCommandText
		end if
	end repeat
	return "処理終了"
end open

