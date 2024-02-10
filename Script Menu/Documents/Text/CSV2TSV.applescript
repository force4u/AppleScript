#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

###Wクリックで起動した場合
on run
	###ダイアログ
	tell current application
		set strName to name as text
	end tell
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	############ デフォルトロケーション
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
	set aliasDesktopDirPath to (ocidDesktopDirPathURL's absoluteURL()) as alias
	#
	set listUTI to {"public.comma-separated-values-text"}
	set strMes to ("ファイルを選んでください") as text
	set strPrompt to ("ファイルを選んでください") as text
	try
		###　ファイル選択時
		set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDesktopDirPath of type listUTI with invisibles, multiple selections allowed and showing package contents) as list
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	if listAliasFilePath is {} then
		return "選んでください"
	end if
	open listAliasFilePath
end run


on open listAliasFilePath
	
	repeat with itemAliasFilePath in listAliasFilePath
		##パス
		set aliasFilePath to itemAliasFilePath as alias
		set strFilePath to (POSIX path of aliasFilePath) as text
		set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
		#保存するタブ区切りテキストのパス
		set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
		set ocidSaveFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:("tsv"))
		#ファイルのテキストを読み込み
		set listResponse to (refMe's NSString's alloc()'s initWithContentsOfURL:(ocidFilePathURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
		set ocidReadString to (item 1 of listResponse)
		#出力用のテキスト
		set ocidOutPutString to (refMe's NSMutableString's alloc()'s initWithCapacity:(0))
		#改行を調べて
		set ocidCharSet to (refMe's NSCharacterSet's characterSetWithCharactersInString:("\n"))
		set ocidLineArrayN to (ocidReadString's componentsSeparatedByCharactersInSet:(ocidCharSet))
		set numCntLineNoN to (count of ocidLineArrayN) as integer
		set ocidCharSet to (refMe's NSCharacterSet's newlineCharacterSet)
		set ocidLineArrayNL to (ocidReadString's componentsSeparatedByCharactersInSet:(ocidCharSet))
		set numCntLineNoNL to (count of ocidLineArrayNL) as integer
		#改行方式でテキストを行毎処理としてリストにする
		if ocidLineArrayN = ocidLineArrayNL then
			log "UNIX改行です"
			set strNewlineCharacter to ("\n") as text
			set ocidLineArray to ocidLineArrayN
		else if numCntLineNoN = 1 then
			if numCntLineNoNL > 1 then
				log "Mac改行です"
				set strNewlineCharacter to ("\r") as text
				set ocidCharSet to (refMe's NSCharacterSet's characterSetWithCharactersInString:(strNewlineCharacter))
				set ocidLineArray to (ocidReadString's componentsSeparatedByCharactersInSet:(ocidCharSet))
			else
				return "処理中止"
			end if
		else if numCntLineNoNL > numCntLineNoN then
			log "Windows改行です"
			#WINDOWS改行はUNIX改行に置換してからArray処理する
			set strNewlineCharacter to ("\r\n") as text
			set ocidWindowsString to (refMe's NSMutableString's alloc()'s initWithCapacity:(0))
			(ocidWindowsString's setString:(ocidReadString))
			set ocidReadString to (ocidWindowsString's stringByReplacingOccurrencesOfString:(strNewlineCharacter) withString:("\n"))
			set ocidCharSet to (refMe's NSCharacterSet's characterSetWithCharactersInString:(strNewlineCharacter))
			set ocidLineArray to (ocidReadString's componentsSeparatedByCharactersInSet:(ocidCharSet))
		else
			return "処理中止"
		end if
		#クオテーション処理の有無を調べる
		set ocidFirstLine to ocidLineArray's firstObject()
		set ocidRange to refMe's NSMakeRange(0, 1)
		set strFirstChar to (ocidFirstLine's substringWithRange:(ocidRange)) as text
		if strFirstChar is "\"" then
			log "クオテーション形式のCSV"
			set strSchar to ("\",\"") as text
		else
			log "通常のCSV"
			set strSchar to (",") as text
		end if
		#行毎の処理
		repeat with itemLineString in ocidLineArray
			if (itemLineString as text) is "" then
				##空行＝最後の行に改行がある場合は終了
				exit repeat
			end if
			#行のテキストを可変テキストに入れて
			set ocidLineString to (refMe's NSMutableString's alloc()'s initWithCapacity:(0))
			(ocidLineString's setString:(itemLineString))
			#区切り文字でタブに置換
			set ocidTabLineString to (ocidLineString's stringByReplacingOccurrencesOfString:(strSchar) withString:("\t"))
			#出力用のテキストにセット
			(ocidOutPutString's appendString:(ocidTabLineString))
			#改行を付与
			(ocidOutPutString's appendString:(strNewlineCharacter))
		end repeat
		#保存
		set listDone to (ocidOutPutString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
		
	end repeat
	
end open
