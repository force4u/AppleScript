#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# open ssl で暗号化されたファイルを復号化します
# 復号化には暗号化した時に使用した暗号化パスワードが必要です
# ファイル名を変更している場合、拡張子の変更が必要な場合があります
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

#############################
###ダイアログ
#############################
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
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
set listUTI to {"public.item"}
set strMes to ("opensslで暗号化されたファイルを選んでください") as text
set strPrompt to ("ファイルを選んでください") as text
try
	###　ファイル選択時
	set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
#############################
###ダイアログ
#############################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/LockedIcon.icns") as alias
try
	set strMes to ("openssl復号化パスワードを入力してください") as text
	set recordResponse to (display dialog strMes with title "入力してください" default answer "符号化パスワードを入力" buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 30 without hidden answer)
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
###タブと改行の除去
set ocidPW to refMe's NSString's stringWithString:(strResponse)
set ocidPWM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidPWM's appendString:(ocidPW)
##行末の改行
set ocidPWM to ocidPWM's stringByReplacingOccurrencesOfString:("\n") withString:("")
set ocidPWM to ocidPWM's stringByReplacingOccurrencesOfString:("\r") withString:("")
##タブ除去
set ocidPWM to ocidPWM's stringByReplacingOccurrencesOfString:("\t") withString:("")
set strPW to ocidPWM as text
#############################
###パス処理
#############################
set strFilePath to (POSIX path of aliasFilePath) as text
####ドキュメントのパスをNSString
set ocidFilePath to refMe's NSString's stringWithString:(strFilePath)
####ドキュメントのパスをNSURLに
set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath)
###ファイル名を取得して拡張子を取っておく
set ocidFileName to ocidFilePathURL's lastPathComponent()
###保存用のディレクトリ名
set strSaveDirName to ((ocidFileName as text) & "_符号化済") as text
###コンテナ
set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
###保存先は
set ocidSaveDirPathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:(strSaveDirName)
###フォルダを作る
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###保存用ファイル名
set ocidSaveFileName to ocidFileName's stringByDeletingPathExtension()
###保存パス
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidSaveFileName)
###POSIX
set strSaveFilePath to ocidSaveFilePathURL's |path|() as text
#############################
###本処理
#############################
##sslパス
set strBinPath to ("/usr/bin/openssl") as text
set strCommandText to ("\"" & strBinPath & "\" enc -d -aes-256-cbc -in  \"" & strFilePath & "\"  -out \"" & strSaveFilePath & "\" -pass pass:\"" & strPW & "\"")

try
	set strResponse to (do shell script strCommandText)
on error strErrorMes
	set aliasPathToMe to path to me as alias
	set strPathToMe to (POSIX path of aliasPathToMe) as text
	set strErrorMes to (strPathToMe & "\r" & strResponse & "\r" & strErrorMes & "\r") as text
	
	#####ダイアログを前面に
	set strAppName to (name of current application) as text
	####スクリプトメニューから実行したら
	if strAppName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns" as alias
	set recordResult to (display dialog "一部エラーが発生しました\r確認してください" with title "エラーメッセージ" default answer strErrorMes buttons {"担当者にメールで送信", "キャンセル", "クリップボードにコピー"} default button "担当者にメールで送信" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer) as record
	
	if button returned of recordResult is "担当者にメールで送信" then
		set strURL to ("mailto:?Body=" & strErrorMes & "&subject=【エラー報告】エラーが発生しました")
		tell application "Finder"
			open location strURL
		end tell
	end if
	if button returned of recordResult is "クリップボードにコピー" then
		try
			set strText to text returned of recordResult as text
			####ペーストボード宣言
			set appPasteboard to refMe's NSPasteboard's generalPasteboard()
			set ocidText to (refMe's NSString's stringWithString:(strText))
			appPasteboard's clearContents()
			appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
		on error
			tell application "Finder"
				set the clipboard to strText as text
			end tell
		end try
	end if
end try
