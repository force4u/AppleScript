#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#【注意事項】ユーザー名パスワードを指定する場合パスワードが平文で保存されます
#そのため、ユーザー名パスワードを指定するのは非推奨です
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

################################
##デフォルトクリップボードから
################################
##クリップボードにテキストが無い場合
set strMes to ("ロケーションファイルのURLを入力してください") as text
###初期化
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to ocidPasteboard's types
###テキストがあれば
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	###値を格納する
	tell application "Finder"
		set strDefaultAnswer to (the clipboard) as text
	end tell
	###Finderでエラーしたら
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strDefaultAnswer to ocidReadString as text
	else
		log "テキストなし"
		set strDefaultAnswer to strMes as text
	end if
end if
################################
##保存先を作っておく
################################
##作るフォルダ名
set listDirName to {"AfpLoc", "CalLoc", "FileLoc", "FtpLoc", "MailLoc", "NewsLoc", "SmbLoc", "SSHloc", "WebLoc", "TelLoc", "VncLoc", "NfsLoc"} as list
###フォルダを作る先
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirPathURL to ocidURLsArray's firstObject()
set ocidContainerDirPathURL to ocidDocumentDirPathURL's URLByAppendingPathComponent:("Webloc")
##フォルダのパーミンション
set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
# 777-->511 755-->493 700-->448 766-->502 
(ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions))
repeat with itemDirName in listDirName
	set strDirName to itemDirName as text
	###フォルダを作っておく
	set ocidMakeDirPathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:(strDirName))
	set listBoolMakeDir to (appFileManager's createDirectoryAtURL:(ocidMakeDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
end repeat

################################
######ダイアログ
################################
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
set aliasIconPath to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns") as alias
try
	set strMes to ("URLを入力してください\r例：\nhttps://yahoo.co.jp\nsmb://USERID:PASSWORD@192.168.0.0/Public\nafp://192.168.0.0/Public\ntel:99900001234") as text
	set recordResponse to (display dialog strMes with title "URLを入力してください" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
on error
	log "エラーしました"
	return "エラーしました"
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else
	log "キャンセルしました"
	return "キャンセルしました"
end if
################################
###スキームチェック
################################
if strResponse starts with "http" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "afp" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "smb" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "cifs" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "webcal" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "ical" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "file" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "/" then
	set ocidFilePathStr to refMe's NSString's stringWithString:(strResponse)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	set strURL to ocidFilePathURL's absoluteString() as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "ftp" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "mail" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "news" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "ssh" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "tel" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "vnc" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else if strResponse starts with "nfs" then
	set strURL to strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
else
	##ダイアログにスキーム無しだった場合
	set listScheme to {"https", "afp", "smb", "cifs", "webcal", "ical", "file", "ftp", "mail", "tel", "news", "ssh", "vnc", "nfs"} as list
	###ダイアログ
	set strName to (name of current application) as text
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	try
		set listResponse to (choose from list listScheme with title "選んでください" with prompt "スキームを選んでください" default items (item 1 of listScheme) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	if (item 1 of listResponse) is false then
		return "キャンセルしました"
	end if
	set strURL to (item 1 of listResponse) & "://" & strResponse as text
	set strExtensionName to doScheme2ExtensionName(strURL) as text
end if

################################
###本処理
################################
###タブと改行の除去
set ocidURL to refMe's NSString's stringWithString:(strURL)
set ocidURLM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidURLM's appendString:(ocidURL)
##行末の改行
set ocidURLM to ocidURLM's stringByReplacingOccurrencesOfString:("\n") withString:("")
set ocidURLM to ocidURLM's stringByReplacingOccurrencesOfString:("\r") withString:("")
##タブ除去
set ocidURLM to ocidURLM's stringByReplacingOccurrencesOfString:("\t") withString:("")
##URLに
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLM)
##NSURLComponents
set ocidURLComponents to refMe's NSURLComponents's componentsWithURL:(ocidURL) resolvingAgainstBaseURL:(true)
##PLISTに必要な値の取り出し
set strScheme to ocidURLComponents's |scheme|() as text
set ocidHostName to ocidURLComponents's |host|()
if ocidHostName = (missing value) then
	set ocidPath to ocidURLComponents's |path|()
	if ocidPath = (missing value) then
		set strBaseFileName to ocidPath as text
	else
		set strBaseFileName to doGetDateNo("yyyyMMdd") as text
	end if
else
	set strBaseFileName to ocidHostName as text
end if
set ocidURLStr to ocidURL's absoluteString()
##############################
## 保存先ディレクトリ
##スキームとフォルダの関連付けレコード
set recordDirName to {afp:"AfpLoc", ical:"CalLoc", webcal:"CalLoc", |file|:"FileLoc", ftp:"FtpLoc", mail:"MailLoc", news:"NewsLoc", smb:"SmbLoc", cifs:"SmbLoc", ssh:"SSHloc", https:"WebLoc", tel:"TelLoc", vnc:"VncLoc", nfs:"NfsLoc"} as record
#ディレクトリ名を取得して
set ocidDirDictionary to refMe's NSMutableDictionary's dictionaryWithDictionary:(recordDirName)
set strDirName to ocidDirDictionary's valueForKey:(strScheme)
##ファイルの保存先
set ocidSaveDirPathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:(strDirName)
set ocidBaseFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strBaseFileName)
set ocidSaveFilePathURL to ocidBaseFilePathURL's URLByAppendingPathExtension:(strExtensionName)
log ocidSaveFilePathURL's |path| as text

###Finder 用のエイリアス
set aliasSaveDirPath to (ocidSaveDirPathURL's absoluteURL()) as alias

#########################
##############################
## PLIST maillocを作成
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(ocidURLStr) forKey:"URL"
set strDateno to doGetDateNo("yyyyMMdd")
ocidPlistDict's setValue:(strDateno) forKey:("version")
ocidPlistDict's setValue:(strDateno) forKey:("productVersion")
##これは自分用
ocidPlistDict's setValue:(strDateno) forKey:("kMDItemFSCreationDate")
#########################
####weblocファイルを作る
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistData to item 1 of listPlistEditDataArray
set boolWritetoUrlArray to ocidPlistData's writeToURL:(ocidSaveFilePathURL) options:0 |error|:(reference)
set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
#########################
#### WINDOWS用のURLファイル
set ocidSaveFilePathURL to ocidBaseFilePathURL's URLByAppendingPathExtension:("url")
set ocidFileContent to refMe's NSMutableString's stringWithCapacity:0
set strContents to ("[InternetShortcut]\r\nURL=" & ocidURLStr & "\r\n") as text
ocidFileContent's setString:(strContents)
set listDone to ocidFileContent's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)


################################
####保存先を開く
################################
tell application "Finder"
	
	set refNewWindow to make new Finder window
	tell refNewWindow
		set position to {10, 30}
		set bounds to {10, 30, 720, 480}
	end tell
	set target of refNewWindow to aliasSaveDirPath
	set selection to aliasSaveFilePath
end tell

################################
####バージョンで使う日付
################################
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

################################
###スキームから拡張子
################################
to doScheme2ExtensionName(argScheme)
	set strResponse to argScheme as text
	if strResponse starts with "http" then
		set strExtensionName to ("webloc") as text
	else if strResponse starts with "afp" then
		set strExtensionName to ("afploc") as text
	else if strResponse starts with "smb" then
		set strExtensionName to ("inetloc") as text
	else if strResponse starts with "cifs" then
		set strExtensionName to ("inetloc") as text
	else if strResponse starts with "webcal" then
		set strExtensionName to ("inetloc") as text
	else if strResponse starts with "ical" then
		set strExtensionName to ("inetloc") as text
	else if strResponse starts with "file" then
		set strExtensionName to ("fileloc") as text
	else if strResponse starts with "ftp" then
		set strExtensionName to ("ftploc") as text
	else if strResponse starts with "mail" then
		set strExtensionName to ("mailloc") as text
	else if strResponse starts with "news" then
		set strExtensionName to ("newsloc") as text
	else if strResponse starts with "ssh" then
		set strExtensionName to ("inetloc") as text
	else if strResponse starts with "vnc" then
		set strExtensionName to ("vncloc") as text
	else if strResponse starts with "nfs" then
		set strExtensionName to ("inetloc") as text
	else
		set strExtensionName to ("inetloc") as text
	end if
	return strExtensionName
end doScheme2ExtensionName



