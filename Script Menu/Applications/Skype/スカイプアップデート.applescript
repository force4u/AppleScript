#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#キャッシュをゴミ箱に入れた後で
#最新版をコピーします
#　動作しますが、ちょっと考え中
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

##エラーメッセージ送信時のメールアドレス
property strSendMailAdd : "foo@hoge.com" as text
##対象のアプリケーションのバンドルID
property strBundleID : "com.skype.skype" as text
##ダウンロードURL
set strURL to ("https://get.skype.com/go/getskype-skypeformac") as text

#####################
##ユーザーインストール先
#####################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidUserAllApplicationsPath to (appFileManager's URLsForDirectory:(refMe's NSAllApplicationsDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserAllApplicationsDir to ocidUserAllApplicationsPath's firstObject()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set numPermissionDem to doOct2Dem(700) as integer
ocidAttrDict's setValue:numPermissionDem forKey:(refMe's NSFilePosixPermissions)
############################
###フォルダを作る
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidUserAllApplicationsDir) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
############################
###localizedを作成
set ocidLocalizedDirPathURL to ocidUserAllApplicationsDir's URLByAppendingPathComponent:".localized" isDirectory:false
set ocidLocalizedDirPath to ocidLocalizedDirPathURL's |path|()
####空のファイルを作成する
set ocidBlankData to refMe's NSData's alloc()'s init()
set ocidAttrFile to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrFile's setValue:493 forKey:(refMe's NSFilePosixPermissions)
set boolMakeNewFile to appFileManager's createFileAtPath:ocidLocalizedDirPath |contents|:ocidBlankData attributes:ocidAttrFile
##############################
###　ダウンロード
##############################
###保存先 ディレクトリ
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
###フォルダ作る
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###ファイル名取得
try
	set strCommandText to ("/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' " & strURL & " | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev") as text
	set strFileName to (do shell script strCommandText) as text
on error strErrorMes number errorNumber
	doErrorMes(strErrorMes, errorNumber)
	return "ファイル名の取得に失敗しました"
end try
###保存URL
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
set strSaveFilePath to (ocidSaveFilePathURL's |path|()) as text
###ダウンロード
try
	set strCommandText to ("/usr/bin/curl -L -o \"" & strSaveFilePath & "\" \"" & strURL & "\" --connect-timeout 10;") as text
	do shell script strCommandText
on error strErrorMes number errorNumber
	doErrorMes(strErrorMes, errorNumber)
	return "ダウンロードに失敗しました"
end try
###################################
#まずは処理するアプリケーションを終了させる
###################################
doQuitApp2UTI(strBundleID)

###################################
#まずは処理するアプリケーションを終了させる
###################################
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
if ocidAppBundle ≠ (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else if ocidAppBundle = (missing value) then
	set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
end if
if ocidAppPathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
		on error
			return "アプリケーションが見つかりませんでした"
		end try
	end tell
	set strAppPath to POSIX path of aliasAppApth as text
	set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
	set strAppPath to strAppPathStr's stringByStandardizingPath()
	set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true
end if

###################################
#アプリケーションをゴミ箱に
###################################
if ocidAppPathURL is missing value then
	log "アプリケーションが見つかりません"
else
	set listResult to (appFileManager's trashItemAtURL:(ocidAppPathURL) resultingItemURL:(missing value) |error|:(reference))
end if
###################################
########キャッシュを削除する
###################################
set ocidUserLibraryPath to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
###LibraryフォルダURL
set ocidLibraryPathURL to ocidUserLibraryPath's firstObject()
####Caches
set ocidChkDirURL to ocidLibraryPathURL's URLByAppendingPathComponent:"Caches/com.skype.skype.ShipIt"
###中身をゴミ箱に入れる
doGo2TrashDirContentsURL(ocidChkDirURL)
###com.apple.dt.Xcode
set ocidChkDirURL to ocidLibraryPathURL's URLByAppendingPathComponent:"Caches/com.skype.skype"
###中身をゴミ箱に入れる
doGo2TrashDirContentsURL(ocidChkDirURL)
####LOG
set ocidChkDirURL to ocidLibraryPathURL's URLByAppendingPathComponent:"Logs/Skype Helper (Renderer)"
###中身をゴミ箱に入れる
doGo2TrashDirContentsURL(ocidChkDirURL)
###ユーザーApplicationSupport
set ocidUserApplicationSupportPath to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserApplicationSupportPathURL to ocidUserApplicationSupportPath's objectAtIndex:0
###Microsof
set ocidMicrosoftDirURL to ocidUserApplicationSupportPathURL's URLByAppendingPathComponent:"Microsoft"
set ocidChkDirURL to ocidMicrosoftDirURL's URLByAppendingPathComponent:"Skype for Desktop/Cache/"
doGo2TrashDirContentsURL(ocidChkDirURL)
set ocidChkDirURL to ocidMicrosoftDirURL's URLByAppendingPathComponent:"Skype for Desktop/GPUCache/"
doGo2TrashDirContentsURL(ocidChkDirURL)
set ocidChkDirURL to ocidMicrosoftDirURL's URLByAppendingPathComponent:"Skype for Desktop/Code Cache/"
doGo2TrashDirContentsURL(ocidChkDirURL)
###きっちりやる時はこちらも
set ocidChkDirURL to ocidMicrosoftDirURL's URLByAppendingPathComponent:"Skype for Desktop/Partitions/"
doGo2TrashDirContentsURL(ocidChkDirURL)
###テンポラリ
set ocidTempDirPathURL to appFileManager's temporaryDirectory()
set ocidChkDirURL to ocidTempDirPathURL's URLByAppendingPathComponent:"Skype/"
doGo2TrashDirContentsURL(ocidChkDirURL)
set ocidChkDirURL to ocidTempDirPathURL's URLByAppendingPathComponent:"Skype Helper/"
doGo2TrashDirContentsURL(ocidChkDirURL)
set ocidChkDirURL to ocidTempDirPathURL's URLByAppendingPathComponent:"Skype Helper (GPU)/"
doGo2TrashDirContentsURL(ocidChkDirURL)
set ocidChkDirURL to ocidTempDirPathURL's URLByAppendingPathComponent:"Skype Helper (Renderer)/"
doGo2TrashDirContentsURL(ocidChkDirURL)
###テンポラリキャッシュ
set ocidContainerDirURL to ocidTempDirPathURL's URLByDeletingLastPathComponent()
set ocidChkDirURL to ocidContainerDirURL's URLByAppendingPathComponent:"C/com.skype.skype/"
doGo2TrashDirContentsURL(ocidChkDirURL)
set ocidChkDirURL to ocidContainerDirURL's URLByAppendingPathComponent:"C/com.skype.skype.Helper/"
doGo2TrashDirContentsURL(ocidChkDirURL)
set ocidChkDirURL to ocidContainerDirURL's URLByAppendingPathComponent:"C/com.skype.skype.Helper-(GPU)/"
doGo2TrashDirContentsURL(ocidChkDirURL)
set ocidChkDirURL to ocidContainerDirURL's URLByAppendingPathComponent:"C/com.skype.skype.Helper-(Renderer)/"
doGo2TrashDirContentsURL(ocidChkDirURL)

###################################
##本処理
###################################


set strCommandText to ("/usr/bin/hdiutil attach \"" & strSaveFilePath & "\" -noverify -nobrowse -noautoopen") as text
do shell script strCommandText

set strCommandText to ("/usr/bin/ditto \"/Volumes/Skype/Skype.app\" $HOME/Applications/Skype.app") as text
do shell script strCommandText


set strCommandText to ("/usr/bin/hdiutil detach /Volumes/Skype -force") as text
do shell script strCommandText



#################################
### エラー処理
#################################
to doErrorMes(argMes, argNo)
	###メッセージ整形
	tell application "Finder"
		set aliasPathToMe to (path to me) as alias
		set strFileName to name of aliasPathToMe
	end tell
	set strErrorMes to "ファイル名：" & strFileName & "\rエラー番号：" & argNo & "\rエラーメッセージ：" & argMes as text
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
	set aliasIconPath to POSIX file "//System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Accounts.icns"
	set strTitle to ("エラーメッセージ") as text
	set strMes to ("エラーが発生しました\rエラーメッセージを担当まで送信してください") as text
	
	set recordResult to (display dialog strMes with title strTitle default answer strErrorMes buttons {"クリップボードにコピー", "キャンセル", "メール"} default button "メール" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer) as record
	if (button returned of recordResult) is "メール" then
		doSendMail(strErrorMes)
	end if
	if (button returned of recordResult) is "クリップボードにコピー" then
		try
			set strText to text returned of recordResult as text
			####ペーストボード宣言
			set appPasteboard to refMe's NSPasteboard's generalPasteboard()
			set ocidText to (refMe's NSString's stringWithString:(strText))
			appPasteboard's clearContents()
			appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
		on error
			tell application "Finder"
				set the clipboard to strTitle as text
			end tell
		end try
	end if
end doErrorMes

#################################
### メール送信
#################################
to doSendMail(argMailMes)
	###本文
	set strBody to argMailMes as text
	###件名
	set strSubject to "【エラー報告】エラーが発生したので報告します" as text
	##送信先は自分自身
	set strMailAdd to doGetMyEmailAdd() as text
	###BCCに送信アドレス
	set strBCCAdd to strSendMailAdd as text
	###本文をNSString'sに
	set ocidBody to refMe's NSString's stringWithString:(strBody)
	###CC必要な場合
	set strCCAdd to "" as text
	###スキーム
	set strScheme to "mailto" as text
	###URL初期化
	set ocidEmailURL to refMe's NSURL's alloc()'s init()
	###コンポーネント初期化
	set ocidEmailComponents to refMe's NSURLComponents's alloc()'s init()
	###スキーム mailtoを追加
	ocidEmailComponents's setScheme:(strScheme)
	###パスを追加（setHostじゃないよ）
	ocidEmailComponents's setPath:(strMailAdd)
	###クエリー追加
	set ocidQueryItemArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("subject") value:(strSubject)
	ocidQueryItemArray's addObject:ocidQueryItem
	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("body") value:(ocidBody)
	ocidQueryItemArray's addObject:ocidQueryItem
	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("cc") value:(strCCAdd)
	ocidQueryItemArray's addObject:ocidQueryItem
	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("bcc") value:(strBCCAdd)
	ocidQueryItemArray's addObject:ocidQueryItem
	ocidEmailComponents's setQueryItems:(ocidQueryItemArray)
	###URLに
	set ocidEmailURL to ocidEmailComponents's |URL|
	log ocidEmailURL's absoluteString() as text
	
	###デフォルトのeMailクライアント
	set strUTI to "com.apple.mail.email" as text
	set ocidUTType to refMe's UTType's typeWithIdentifier:(strUTI)
	set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set ocidAppPathURL to appShardWorkspace's URLForApplicationToOpenContentType:(ocidUTType)
	###URLをeMailクライアントで開く
	set ocidConfig to refMe's NSWorkspaceOpenConfiguration's configuration
	ocidConfig's setActivates:(true as boolean)
	ocidConfig's setHides:(false as boolean)
	appShardWorkspace's openURLs:({ocidEmailURL}) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidConfig) completionHandler:(missing value)
	
	
end doSendMail

#################################
###自分のメールアドレスの取得
#################################

to doGetMyEmailAdd()
	tell application id "com.apple.AddressBook"
		###自分のカード
		tell my card
			set strVcardText to vcard as text
		end tell
	end tell
	####Vcardの内容をリスト化（改行がWINDOWS）
	set AppleScript's text item delimiters to "\r\n"
	set listVcardText to every text item of strVcardText
	set AppleScript's text item delimiters to ""
	###EMAIL取得用
	set listEmailAdd to {} as list
	set strHomeEmail to "" as text
	set strWORKEmail to "" as text
	####Vcardの数だけ繰り返し
	repeat with itemVcardText in listVcardText
		##テキストで確定させて
		set strItemVcardText to itemVcardText as text
		##telから始まる場合
		if strItemVcardText starts with "EMAIL" then
			###カンマで区切って
			set AppleScript's text item delimiters to ":"
			set listItemVcardText to every text item of strItemVcardText
			set AppleScript's text item delimiters to ""
			set strType to (item 1 of listItemVcardText) as text
			if strType contains "HOME" then
				set strHomeEmail to (item 2 of listItemVcardText) as text
			else if strType contains "WORK" then
				set strWORKEmail to (item 2 of listItemVcardText) as text
			else
				###後半部分が電番
				set strEmail to (item 2 of listItemVcardText) as text
				####リストに格納して
				copy strEmail to end of listEmailAdd
			end if
		end if
	end repeat
	###一つに絞る場合
	if strWORKEmail is not "" then
		set strSendAdd to strWORKEmail
	else if strHomeEmail is not "" then
		set strSendAdd to strHomeEmail
	else
		set strSendAdd to (item 1 of listEmailAdd)
	end if
	return strSendAdd
end doGetMyEmailAdd


###################################
########ディレクトリの中身をゴミ箱へ
###################################
on doGo2TrashDirContentsURL(ocidDirUrl)
	###ファイルマネージャー初期化
	set appFileManager to refMe's NSFileManager's defaultManager()
	################################
	####渡された値がNSURL以外の場合の処理
	try
		set strClassName to class of ocidDirUrl as text
		####渡された値がテキストだったら
		if strClassName is "text" then
			set strDirUrl to ocidDirUrl as text
			####渡された値がエイリアスだったら
		else if strClassName is "alias" then
			set strDirPath to POSIX path of ocidDirUrl as text
		end if
		set ocidFilePath to (refMe's NSString's stringWithString:strDirPath)
		set ocidFilePathString to ocidFilePath's stringByStandardizingPath
		set ocidDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePathString isDirectory:true)
	on error
		######ocid形式の値だったら
		set strClassName to ocidDirUrl's className() as text
		###テキストなら
		if strClassName contains "NSCFString" then
			set ocidFilePathString to ocidDirUrl's stringByStandardizingPath
			set ocidDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePathString isDirectory:true)
			###NSURLなら
		else if strClassName is "NSURL" then
			set ocidDirPathURL to ocidDirUrl
		else
			error "NSURLを指定してください" number -9999
			return
		end if
	end try
	################################
	####渡されたパスが無い場合はエラー
	set ocidFilePathString to ocidDirPathURL's |path|()
	set boolFolderExists to (appFileManager's fileExistsAtPath:ocidFilePathString isDirectory:true)
	if boolFolderExists is false then
		log "パス先が実在しません"
		####パス先ない場合は作っておく
		set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
		ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
		set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
		return
	end if
	################################
	####ディレクトリか？の判断　ファイルならエラーで止める	
	set ocidResultArray to ocidDirPathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference)
	if (item 3 of ocidResultArray) is not (missing value) then
		doGetErrorData(ocidNSErrorData)
	end if
	set ocidResultValue to item 2 of ocidResultArray
	-->false
	set ocidFalse to (refMe's NSNumber's numberWithBool:false)'s boolValue
	if ocidResultValue is ocidFalse then
		##error "パス先がファイルですディレクトリを指定してください" number -9999
		log "パス先がファイルですディレクトリを指定してください"
		return
	end if
	##################################
	##内包リスト
	set listResult to appFileManager's contentsOfDirectoryAtURL:ocidDirPathURL includingPropertiesForKeys:{refMe's NSURLPathKey} options:0 |error|:(reference)
	###エラー発生時
	if (item 2 of listResult) is not (missing value) then
		doGetErrorData(item 2 of listResult)
	end if
	
	###結果
	set ocidPathArray to item 1 of listResult
	repeat with itemPathArray in ocidPathArray
		set ocidPathArrayURL to itemPathArray
		##ゴミ箱に入れる
		set listResult to (appFileManager's trashItemAtURL:ocidPathArrayURL resultingItemURL:(missing value) |error|:(reference))
		###エラー発生時
		if (item 2 of listResult) is not (missing value) then
			doGetErrorData(item 2 of listResult)
		end if
	end repeat
end doGo2TrashDirContentsURL


###################################
########ディレクトリの中身をゴミ箱へ サブパス指定式
###################################

to doChkDirSubPath2Trash(argChkURL, argSubPathText)
	###ファイルマネージャー初期化
	set appFileManager to refMe's NSFileManager's defaultManager()
	##内包リスト
	set listResult to appFileManager's contentsOfDirectoryAtURL:argChkURL includingPropertiesForKeys:{refMe's NSURLPathKey} options:0 |error|:(reference)
	###結果
	set ocidPathArray to item 1 of listResult
	####リストの数だけ
	repeat with itemPathArrayURL in ocidPathArray
		set ocidChkURL to (itemPathArrayURL's URLByAppendingPathComponent:argSubPathText)
		####渡されたパスが無い場合はエラー
		set ocidFilePathString to ocidChkURL's |path|()
		set boolFolderExists to (appFileManager's fileExistsAtPath:ocidFilePathString isDirectory:true)
		if boolFolderExists is false then
			log "パス先が実在しません:\n" & (ocidFilePathString as text)
		else
			log "処理する"
			set listSubPathResult to (appFileManager's contentsOfDirectoryAtURL:ocidChkURL includingPropertiesForKeys:{refMe's NSURLPathKey} options:0 |error|:(reference))
			set ocidSubPathArray to item 1 of listSubPathResult
			repeat with itemSubPathArray in ocidSubPathArray
				set ocidItemPathArrayURL to itemSubPathArray
				##ゴミ箱に入れる
				set listResult to (appFileManager's trashItemAtURL:ocidItemPathArrayURL resultingItemURL:(missing value) |error|:(reference))
			end repeat
			
		end if
		
	end repeat
	
end doChkDirSubPath2Trash



###################################
########アプリケーションを終了させる
###################################
to doQuitApp2UTI(argUTI)
	set strUTI to argUTI as text
	set ocidResultsArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:strUTI
	set numCntArray to ocidResultsArray count
	if numCntArray ≠ 0 then
		set ocidRunApp to ocidResultsArray's objectAtIndex:0
		
		###通常終了
		set boolDone to ocidRunApp's terminate()
		####強制終了
		set boolDone to ocidRunApp's forceTerminate()
		
		#### killallを使う場合
		set ocidExecAppURL to ocidRunApp's executableURL()
		set ocidFileName to ocidExecAppURL's lastPathComponent()
		set strFileName to ocidFileName as text
		
		set strCommandText to ("/usr/bin/killall -z " & strFileName & "") as text
		set ocidCommandText to refMe's NSString's stringWithString:strCommandText
		set ocidTermTask to refMe's NSTask's alloc()'s init()
		ocidTermTask's setLaunchPath:"/bin/zsh"
		ocidTermTask's setArguments:({"-c", ocidCommandText})
		set listDoneReturn to ocidTermTask's launchAndReturnError:(reference)
		
		
		####killを使う場合
		set ocidPID to ocidRunApp's processIdentifier()
		set strPID to ocidPID as text
		log strPID
		set strCommandText to ("/bin/kill -9 " & strPID & "") as text
		set ocidCommandText to refMe's NSString's stringWithString:strCommandText
		set ocidTermTask to refMe's NSTask's alloc()'s init()
		ocidTermTask's setLaunchPath:"/bin/zsh"
		ocidTermTask's setArguments:({"-c", ocidCommandText})
		set listDoneReturn to ocidTermTask's launchAndReturnError:(reference)
		
		
	end if
end doQuitApp2UTI


###################################
########エラー処理
###################################

to doGetErrorData(ocidNSErrorData)
	#####個別のエラー情報
	log "エラーコード：" & ocidNSErrorData's code() as text
	log "エラードメイン：" & ocidNSErrorData's domain() as text
	log "Description:" & ocidNSErrorData's localizedDescription() as text
	log "FailureReason:" & ocidNSErrorData's localizedFailureReason() as text
	log ocidNSErrorData's localizedRecoverySuggestion() as text
	log ocidNSErrorData's localizedRecoveryOptions() as text
	log ocidNSErrorData's recoveryAttempter() as text
	log ocidNSErrorData's helpAnchor() as text
	set ocidNSErrorUserInfo to ocidNSErrorData's userInfo()
	set ocidAllValues to ocidNSErrorUserInfo's allValues() as list
	set ocidAllKeys to ocidNSErrorUserInfo's allKeys() as list
	repeat with ocidKeys in ocidAllKeys
		if (ocidKeys as text) is "NSUnderlyingError" then
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedDescription() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedFailureReason() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedRecoverySuggestion() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedRecoveryOptions() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s recoveryAttempter() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s helpAnchor() as text
		else
			####それ以外の値はそのままテキストで読める
			log (ocidKeys as text) & ": " & (ocidNSErrorUserInfo's valueForKey:ocidKeys) as text
		end if
	end repeat
	
end doGetErrorData
###################################
#####パーミッション　８進→１０進
(*
###主要なモード NSFilePosixPermissions
777-->511
775-->509
770-->504
755-->493
750-->488
700-->448
555-->365
333-->219
*)
###################################

to doOct2Dem(argOctNo)
	set strOctalText to argOctNo as text
	set num3Line to first item of strOctalText as number
	set num2Line to 2nd item of strOctalText as number
	set num1Line to last item of strOctalText as number
	set numDecimal to (num3Line * 64) + (num2Line * 8) + (num1Line * 1)
	return numDecimal as integer
end doOct2Dem




to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
