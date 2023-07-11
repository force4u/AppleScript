#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "Quartz"
use framework "QuartzCore"
use framework "CoreGraphics"
use scripting additions

property refMe : a reference to current application

####開封パスワード
property boolOpenPW : true as boolean
####所有者パスワード
property boolOwnerPW : true as boolean
####アクアセス権
property intAllowNo : 0 as integer
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
					set strMes to "エラー:すでに暗号化されているので変更できません" as text
					display alert strMes buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 3
					return strMes
				end if
				########################################
				#####ロック確認
				set boolLocked to ocidChkDoc's isLocked()
				if boolLocked is true then
					set strMes to "エラー:すでにパスワードでロックされているので変更できません" as text
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
		set ocidDistFolderURL to (ocidContainerDirURL's URLByAppendingPathComponent:(strDirName))
		set ocidSavePdfURL to (ocidDistFolderURL's URLByAppendingPathComponent:(ocidFileName))
		####ファイル移動先
		set appFileManager to refMe's NSFileManager's defaultManager()
		set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
		(ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions))
		set listResults to (appFileManager's createDirectoryAtURL:ocidDistFolderURL withIntermediateDirectories:true attributes:ocidAttrDict |error|:(reference))
		####コピー
		set lisrBoolDone to (appFileManager's copyItemAtURL:(itemPathURL) toURL:(ocidSavePdfURL) |error|:(reference))
		#####PDFDocumentとして読み込み
		set ocidActivDoc to (refMe's PDFDocument's alloc()'s initWithURL:(ocidSavePdfURL))
		########################################
		#####パスワード生成　UUIDを利用
		set strTextFileName to strBaseFileName & ".pw.txt"
		set ocidTextFilePathURL to (ocidDistFolderURL's URLByAppendingPathComponent:strTextFileName)
		#####生成したUUIDからハイフンを取り除く
		set ocidUUIDString to (refMe's NSMutableString's alloc()'s initWithCapacity:0)
		set ocidConcreteUUID to refMe's NSUUID's UUID()
		(ocidUUIDString's setString:(ocidConcreteUUID's UUIDString()))
		set ocidUUIDRange to (ocidUUIDString's rangeOfString:ocidUUIDString)
		(ocidUUIDString's replaceOccurrencesOfString:("-") withString:("") options:(refMe's NSRegularExpressionSearch) range:ocidUUIDRange)
		set strOwnerPassword to ocidUUIDString as text
		##保存用テキストにする
		set strTextFile to "所有者用Pw\n" & strOwnerPassword & "\n" as text
		#####生成したUUIDからハイフンを取り除く
		set ocidUUIDString to (refMe's NSMutableString's alloc()'s initWithCapacity:0)
		set ocidConcreteUUID to refMe's NSUUID's UUID()
		(ocidUUIDString's setString:(ocidConcreteUUID's UUIDString()))
		set ocidUUIDRange to (ocidUUIDString's rangeOfString:ocidUUIDString)
		(ocidUUIDString's replaceOccurrencesOfString:("-") withString:("") options:(refMe's NSRegularExpressionSearch) range:ocidUUIDRange)
		##保存用テキストにする
		set strUserPassword to ocidUUIDString as text
		set strTextFile to strTextFile & "利用者用（他者に教える場合はこちら↓）Pw\n" & strUserPassword & "\n" as text
		set ocidPWString to (refMe's NSString's stringWithString:strTextFile)
		set ocidUUIDData to (ocidPWString's dataUsingEncoding:(refMe's NSUTF8StringEncoding))
		##PWをテキストで保存する
		set boolResults to (ocidUUIDData's writeToURL:ocidTextFilePathURL atomically:true)
		########################################
		#####保存OPTION
		set ocidOptionDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
		if boolOwnerPW = true then
			(ocidOptionDict's setObject:strOwnerPassword forKey:(refMe's PDFDocumentOwnerPasswordOption))
		end if
		if boolOpenPW = true then
			####開封パスワード
			(ocidOptionDict's setObject:strUserPassword forKey:(refMe's PDFDocumentUserPasswordOption))
		end if
		###セキュリティ設定
		(ocidOptionDict's setObject:(intAllowNo) forKey:(refMe's PDFDocumentAccessPermissionsOption))
		##################
		###保存
		##################
		set boolResults to (ocidActivDoc's writeToURL:(ocidSavePdfURL) withOptions:(ocidOptionDict))
	end repeat
end open
