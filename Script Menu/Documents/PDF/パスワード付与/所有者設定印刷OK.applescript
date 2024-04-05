#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "PDFKit"
use framework "Quartz"
use framework "QuartzCore"
use framework "CoreGraphics"
use scripting additions

property refMe : a reference to current application

####所有者パスワード
property boolOwnerPW : true as boolean
####アクアセス権
##	property intAllowNo : 0 as integer
(*
例：全部OKの場合 255 全部ロックは0
許可する番号を『足し算』する
低解像度印刷		(*1*) PDFAllowsLowQualityPrinting 
高解像度印刷		(*2*) refMe's PDFAllowsHighQualityPrinting
文書に変更			(*4*) refMe's PDFAllowsDocumentChanges
アッセンブリ		(*8*) refMe's PDFAllowsDocumentAssembly
コンテンツコピー(*16*) refMe's PDFAllowsContentCopying
アクセシビリティ(*32*) refMe's PDFAllowsContentAccessibility 
コメント注釈		(*64*) refMe's PDFAllowsCommenting 
フォーム入力		(*128*) refMe's PDFAllowsFormFieldEntry 
*)

on run
	###ダイアログを前面に出す
	tell current application
		set strName to name as text
	end tell
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidUserDesktopPathArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidUserDesktopPath to ocidUserDesktopPathArray's objectAtIndex:0
	set listChooseFileUTI to {"com.adobe.pdf"}
	set strPromptText to "PDFファイルを選んでください" as text
	set listDropObject to (choose file with prompt strPromptText default location (ocidUserDesktopPath as alias) of type listChooseFileUTI with invisibles and multiple selections allowed without showing package contents) as list
	open listDropObject
end run

on open listDropObject
	
	set recordOption to {|0開封PW付与|:999, |1低解像度印刷禁止|:1, |2高解像度印刷禁止|:2, |4文書に変更禁止|:4, |8内容変更禁止|:8, |16コンテンツコピー禁止|:16, |32補助装置利用禁止|:32, |64コメント注釈禁止|:64, |128フォーム入力禁止|:128} as record
	
	set ocidOptionDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidOptionDict's setDictionary:(recordOption)
	set ocidAllKeys to ocidOptionDict's allKeys()
	set ocidSortedArray to ocidAllKeys's sortedArrayUsingSelector:("localizedStandardCompare:")
	set listAllKeys to ocidSortedArray as list
	
	##############################
	###ダイアログを前面に出す
	tell current application
		set strName to name as text
	end tell
	###スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	###
	set strTitle to "『禁止設定する』オプション選択（複数可）" as text
	set strPrompt to "『禁止設定』するオプションを選択してください\r何も選択しない＝全部許可\r何も選択しない場合所有者PWの設定とページ抽出とコンテンツの変更は禁止になります\r\r複数選択はコマンド⌘キーを押しながらクリック" as text
	try
		set listResponse to (choose from list listAllKeys with title strTitle with prompt strPrompt default items (item 1 of listAllKeys) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed and empty selection allowed) as list
	on error
		log "エラーしました"
		return "エラーしました"
		error "エラーしました" number -200
	end try
	if listResponse = {} then
		log "何も選択していない"
		set boolOpenPW to false as boolean
		set intAllowNo to 0 as integer
	else if (item 1 of listResponse) is false then
		return "キャンセルしました"
		error "キャンセルしました" number -200
	else
		set boolOpenPW to false as boolean
		set intAllowNo to 0 as integer
		repeat with itemResponse in listResponse
			set intValue to (ocidOptionDict's valueForKey:(itemResponse)) as integer
			if intValue = 999 then
				set boolOpenPW to true as boolean
			else
				set intAllowNo to intAllowNo + intValue
			end if
		end repeat
	end if
	
	set intAllowNo to (255 - intAllowNo) as integer
	
	###############################
	##実際の処理するPDFのURLを格納するリスト
	set ocidDropPathURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
	###ドロップされたエイリアスの数だけ繰り返し
	repeat with itemDropObject in listDropObject
		###処理除外するエイリアスを判定する
		set strFilePaht to (POSIX path of itemDropObject) as text
		set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePaht))
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath))
		###フォルダか？判定
		set listURLvalue to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		set ocidURLvalue to (item 2 of listURLvalue)
		if ocidURLvalue = (refMe's NSNumber's numberWithBool:false) then
			set listURLvalue to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLContentTypeKey) |error|:(reference))
			set strURLvalue to (item 2 of listURLvalue)'s identifier() as text
			###getResourceValueの戻り値がNULLだった場合対策
			if strURLvalue is "" then
				tell application "Finder"
					set objInfo to info for aliasFilePath
					set strURLvalue to type identifier of objInfo as text
				end tell
			end if
			###UTIがPDFのエイリアスだけ処理する
			if strURLvalue is "com.adobe.pdf" then
				#####PDFDocumentとして読み込み
				set ocidChkDoc to (refMe's PDFDocument's alloc()'s initWithURL:(ocidFilePathURL))
				########################################
				#####暗号化チェック
				set boolEncrypted to ocidChkDoc's isEncrypted()
				if boolEncrypted is true then
					set strMes to "エラー:すでに暗号化されているので変更できません\n暗号化を解除してから再設定してください" as text
					display alert strMes buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 3
					return strMes
				end if
				########################################
				#####ロック確認
				set boolLocked to ocidChkDoc's isLocked()
				if boolLocked is true then
					set strMes to "エラー:すでにパスワードでロックされているので変更できません\nパスワードでロックを解除してから再設定してください" as text
					display alert strMes buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 3
					return strMes
				end if
				(ocidDropPathURLArray's addObject:(ocidFilePathURL))
			else
				set strMes to "エラー:PDF専用です" as text
				display alert strMes buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 3
				return strMes
			end if
		else
			set strMes to "エラー:PDF専用です" as text
			display alert strMes buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 3
			return strMes
		end if
	end repeat
	
	repeat with itemPathURL in ocidDropPathURLArray
		set ocidFileName to itemPathURL's lastPathComponent()
		set strBaseFileName to ocidFileName's stringByDeletingPathExtension() as text
		###PW設定は複製したPDFに対して行うため保存先ディレクトリを作る
		set strDirName to (strBaseFileName & "_PW設定済")
		set ocidContainerDirURL to itemPathURL's URLByDeletingLastPathComponent()
		set ocidDistDirPathURL to (ocidContainerDirURL's URLByAppendingPathComponent:(strDirName) isDirectory:(true))
		#同名チェック
		set appFileManager to refMe's NSFileManager's defaultManager()
		set ocidDistDirPath to ocidDistDirPathURL's |path|()
		set boolDirExists to (appFileManager's fileExistsAtPath:(ocidDistDirPath) isDirectory:(true))
		if boolDirExists = true then
			repeat with itemIntNo from 1 to (100) by 1
				set strDirName to (strBaseFileName & "_PW設定済 " & itemIntNo)
				set ocidDistDirPathURL to (ocidContainerDirURL's URLByAppendingPathComponent:(strDirName) isDirectory:(true))
				set ocidDistDirPath to ocidDistDirPathURL's |path|()
				set boolExistsDir to (appFileManager's fileExistsAtPath:(ocidDistDirPath) isDirectory:(true))
				if boolExistsDir is false then
					exit repeat
				end if
			end repeat
		else if boolDirExists is false then
			log "処理開始します"
		end if
	end repeat
	
	repeat with itemPathURL in ocidDropPathURLArray
		set ocidSavePdfURL to (ocidDistDirPathURL's URLByAppendingPathComponent:(ocidFileName))
		####ファイル移動先
		set appFileManager to refMe's NSFileManager's defaultManager()
		set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
		(ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions))
		set listResults to (appFileManager's createDirectoryAtURL:(ocidDistDirPathURL) withIntermediateDirectories:true attributes:ocidAttrDict |error|:(reference))
		####コピー
		set lisrBoolDone to (appFileManager's copyItemAtURL:(itemPathURL) toURL:(ocidSavePdfURL) |error|:(reference))
		#####PDFDocumentとして読み込み
		set ocidActivDoc to (refMe's PDFDocument's alloc()'s initWithURL:(ocidSavePdfURL))
		########################################
		#####パスワード生成　UUIDを利用
		set strTextFileName to strBaseFileName & ".PassWord.txt"
		set ocidTextFilePathURL to (ocidDistDirPathURL's URLByAppendingPathComponent:strTextFileName)
		#####生成したUUIDからハイフンを取り除く
		set ocidUUIDString to (refMe's NSMutableString's alloc()'s initWithCapacity:0)
		set ocidConcreteUUID to refMe's NSUUID's UUID()
		(ocidUUIDString's setString:(ocidConcreteUUID's UUIDString()))
		set ocidUUIDRange to (ocidUUIDString's rangeOfString:ocidUUIDString)
		(ocidUUIDString's replaceOccurrencesOfString:("-") withString:("") options:(refMe's NSRegularExpressionSearch) range:ocidUUIDRange)
		set strOwnerPassword to ocidUUIDString as text
		##保存用テキストにする
		set strTextFile to "所有者用Pw\n" & strOwnerPassword & "\n" as text
		if boolOpenPW is true then
			#####生成したUUIDからハイフンを取り除く
			set ocidUUIDString to (refMe's NSMutableString's alloc()'s initWithCapacity:0)
			set ocidConcreteUUID to refMe's NSUUID's UUID()
			(ocidUUIDString's setString:(ocidConcreteUUID's UUIDString()))
			set ocidUUIDRange to (ocidUUIDString's rangeOfString:ocidUUIDString)
			(ocidUUIDString's replaceOccurrencesOfString:("-") withString:("") options:(refMe's NSRegularExpressionSearch) range:ocidUUIDRange)
			##保存用テキストにする
			set strUserPassword to ocidUUIDString as text
			set strTextFile to strTextFile & "利用者用Pw（他者に教える場合はこちら↓）\n" & strUserPassword & "\n" as text
		end if
		set ocidPWString to (refMe's NSString's stringWithString:strTextFile)
		set ocidUUIDData to (ocidPWString's dataUsingEncoding:(refMe's NSUTF8StringEncoding))
		##PWをテキストで保存する
		set boolResults to (ocidUUIDData's writeToURL:ocidTextFilePathURL atomically:true)
		########################################
		#####保存OPTION
		set ocidOptionDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
		if boolOwnerPW = true then
			(ocidOptionDict's setObject:(strOwnerPassword) forKey:(refMe's PDFDocumentOwnerPasswordOption))
		end if
		if boolOpenPW = true then
			####開封パスワード
			(ocidOptionDict's setObject:(strUserPassword) forKey:(refMe's PDFDocumentUserPasswordOption))
		end if
		###セキュリティ設定
		(ocidOptionDict's setObject:(intAllowNo) forKey:(refMe's PDFDocumentAccessPermissionsOption))
		##################
		###保存
		##################
		set boolResults to (ocidActivDoc's writeToURL:(ocidSavePdfURL) withOptions:(ocidOptionDict))
	end repeat
end open