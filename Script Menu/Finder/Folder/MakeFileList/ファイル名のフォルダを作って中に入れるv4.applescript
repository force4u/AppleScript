#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
#-->ドロップレットアプリケーションに書き出すとフォルダでも出来ます
#v3 重複チェックを入れた
#v4 WEBLOC等でOpenしてしまうので
#OPENを利用しないドロップレットに変更した
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


####################################
#ダブルクリックかスクリプトエディタから実行
on run
	##デスクトップ
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
	set aliasDesktopDirPath to ocidDesktopDirPathURL's absoluteURL() as alias
	###ダイアログを前面に出す
	tell current application
		set strName to name as text
	end tell
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	set strMes to ("ファイルを選んでください") as text
	set strPrompt to ("ファイルを選んでください") as text
	set listUTI to {"public.item"} as list
	set listAliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDesktopDirPath) of type listUTI with multiple selections allowed and showing package contents without invisibles) as list
	#サブルーチンに渡す
	set boolDone to doAction(listAliasFilePath)
	#サブルーチンの戻り値でエラーチェック
	if boolDone is false then
		display alert "エラーが発生しました" message "エラーが発生しましたログを確認ください"
	end if
end run

####################################
#ドロップレットでドロップした場合
on open listAliasPath
	#サブルーチンに渡す
	set boolDone to doAction(listAliasPath)
	#サブルーチンの戻り値でエラーチェック
	if boolDone is false then
		display alert "エラーが発生しました" message "エラーが発生しましたログを確認ください"
	end if
end open



on doAction(argListAliasFilePath)
	##ファイルマネージャ初期化
	set appFileManager to refMe's NSFileManager's defaultManager()
	##繰り返しのはじまり
	repeat with itemAliasFilePath in argListAliasFilePath
		set aliasFilePath to itemAliasFilePath as alias
		set strFilePath to (POSIX path of aliasFilePath) as text
		set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
		##拡張子
		set ocidExtensionName to ocidFilePathURL's pathExtension()
		##フォルダを作るディレクトリ
		set ocidConteinerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
		##ファイル名（拡張子あり）
		set ocidFileName to ocidFilePathURL's lastPathComponent()
		##拡張子をとって
		set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
		#カンマを置換する→これがフォルダ名
		#拡張子が２重に指定してあるケース対応でカンマをアンダースコアに置換する
		set ocidDirName to (ocidBaseFileName's stringByReplacingOccurrencesOfString:(".") withString:("_"))
		#作成するフォルダパス
		set ocidMakeDirPathURL to (ocidConteinerDirPathURL's URLByAppendingPathComponent:(ocidDirName) isDirectory:(true))
		##フォルダパス＋ファイル名で移動先
		set ocidMoveFilePathURL to (ocidMakeDirPathURL's URLByAppendingPathComponent:(ocidFileName) isDirectory:(false))
		##作ろうとしているディレクトリがすでに無いか？確認
		set ocidMakeDirPath to ocidMakeDirPathURL's |path|()
		set boolDirExists to (appFileManager's fileExistsAtPath:(ocidMakeDirPath) isDirectory:(true))
		if boolDirExists = true then
			log "フォルダがすでにある"
		else if boolDirExists = false then
			log "フォルダを作る"
			set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
			# 777-->511 755-->493 700-->448 766-->502 
			(ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions))
			set listBoolMakeDir to (appFileManager's createDirectoryAtURL:(ocidMakeDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		end if
		##重複チェック
		set ocidDistFilePath to doChkExists(ocidMoveFilePathURL)
		if ocidDistFilePath is false then
			display alert "エラーが発生しました" message "重複チェックでエラーになりました"
			return "重複チェックでエラーになりました"
		end if
		set ocidDistFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDistFilePath) isDirectory:false)
		if ocidMoveFilePathURL = ocidMoveFilePathURL then
			log "置換します"
			#今あるファイルをゴミ箱に
			set listResult to (appFileManager's trashItemAtURL:(ocidDistFilePathURL) resultingItemURL:(ocidDistFilePathURL) |error|:(reference))
			#移動
			set ListDone to (appFileManager's moveItemAtURL:(ocidFilePathURL) toURL:(ocidDistFilePathURL) |error|:(reference))
		else
			#移動
			set ListDone to (appFileManager's moveItemAtURL:(ocidFilePathURL) toURL:(ocidDistFilePathURL) |error|:(reference))
		end if
		set boolDone to (item 1 of ListDone) as boolean
		if boolDone is false then
			log "移動に失敗しました"
			return false
		end if
	end repeat
	return true
end doAction




####################################
#上書きチェック
# ocid file path = NSPathStore を返します
####################################
to doChkExists(argFilePath)
	log (className() of argFilePath) as text
	if (class of argFilePath) is text then
		log "テキストファイルパス"
		set ocidFilePathStr to refMe's NSString's stringWithString:(argFilePath)
		set ocidArgFilePath to ocidFilePathStr's stringByStandardizingPath()
	else if (class of argFilePath) is alias then
		log "エリアスファイルパス"
		set strArgFilePath to (POSIX path of argFilePath) as text
		set ocidFilePathStr to refMe's NSString's stringWithString:(argFilePath)
		set ocidArgFilePath to ocidFilePathStr's stringByStandardizingPath()
	else if (class of argFilePath) is «class furl» then
		log "エリアスfurlファイルパス"
		set aliasFilePath to argFilePath as alias
		set strArgFilePath to (POSIX path of argFilePath) as text
		set ocidFilePathStr to refMe's NSString's stringWithString:(argFilePath)
		set ocidArgFilePath to ocidFilePathStr's stringByStandardizingPath()
	else if (className() of argFilePath as text) contains "NSCFString" then
		log "NSStringファイルパス"
		set ocidArgFilePath to argFilePath's stringByStandardizingPath()
	else if (className() of argFilePath as text) contains "NSPathStore" then
		log "NSPathStore2ファイルパス"
		set ocidArgFilePath to argFilePath
	else if (className() of argFilePath as text) contains "NSURL" then
		log "NSURLファイルパス"
		set ocidArgFilePath to argFilePath's |path|
	end if
	####
	set appFileManager to refMe's NSFileManager's defaultManager()
	set boolExists to appFileManager's fileExistsAtPath:(ocidArgFilePath) isDirectory:(false)
	#
	if boolExists = true then
		##ダイアログを前面に
		set strName to (name of current application) as text
		if strName is "osascript" then
			tell application "Finder" to activate
		else
			tell current application to activate
		end if
		set strMes to "同名のファイルがすでにあります\n上書きします？" as text
		try
			set objResponse to (display alert strMes buttons {"上書きする", "処理を中止する", "ファイル名を変更"} default button "上書きする" cancel button "処理を中止する" as informational giving up after 20)
		on error
			log "処理を中止しました"
			return false
		end try
		if true is equal to (gave up of objResponse) then
			log "時間切れですやりなおしてください"
			return false
		end if
		if "上書きする" is equal to (button returned of objResponse) then
			log "上書き保存します"
			set ocidReturnFilePath to ocidArgFilePath
		else if "ファイル名を変更" is equal to (button returned of objResponse) then
			log "ファイル名を変更"
			set ocidContainerDirFilePath to ocidArgFilePath's stringByDeletingLastPathComponent()
			set strFileName to ocidArgFilePath's lastPathComponent() as text
			set aliasContainerDirPath to (POSIX file (ocidContainerDirFilePath as text)) as alias
			##
			set strPromptText to "名前を決めてください" as text
			set strMesText to "名前を決めてください" as text
			###ファイル名　ダイアログ
			set aliasFilePath to (choose file name strMesText default location aliasContainerDirPath default name strFileName with prompt strPromptText) as «class furl»
			set strFilePath to (POSIX path of aliasFilePath) as text
			set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
			set ocidReturnFilePath to ocidFilePathStr's stringByStandardizingPath()
		else if "処理を中止する" is equal to (button returned of objResponse) then
			return false
		else
			return false
		end if
	else if boolExists = false then
		log "そのままファイル生成"
		set ocidReturnFilePath to ocidArgFilePath
	end if
	return ocidReturnFilePath
	
end doChkExists