#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
Inkscapeのインストールが必須になります
https://inkscape.org/release/1.3/mac-os-x/
Inkscape内臓の
Ghostscriptを利用してPSとEPSをPDFに変換します
*)
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set strBundleID to "org.inkscape.Inkscape" as text
################################
###ダイアログ 変換するファイル
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
set listUTI to {"com.adobe.encapsulated-postscript", "com.adobe.postscript"}
set strMes to ("ファイルを選んでください") as text
set strPrompt to ("ファイルを選んでください") as text
try
	set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles, multiple selections allowed and showing package contents) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if listAliasFilePath is {} then
	return "選んでください"
end if



################################
###ダイアログ 変換PDFバージョン
set listPdfVer to {"ps2pdf", "ps2pdf12", "ps2pdf13", "ps2pdf14"}
###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listPdfVer with title "短め" with prompt "長め" default items (item 1 of listPdfVer) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
else
	set strResponse to (item 1 of listResponse) as text
end if
################################
###バンドルIDからアプリケーションのインストール先を求める
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
if ocidAppBundle is missing value then
	set appNSWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set ocidAppBundlePathURL to (appNSWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
else
	set ocidAppBundleStr to ocidAppBundle's bundlePath()
	set ocidAppBundlePath to ocidAppBundleStr's stringByStandardizingPath
	set ocidAppBundlePathURL to (refMe's NSURL's fileURLWithPath:(ocidAppBundlePath))
end if
if ocidAppBundlePathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
		on error
			return "アプリケーションが見つかりませんでした"
		end try
	end tell
	set strAppPath to POSIX path of aliasAppApth as text
	set ocidAppBundlePathStr to refMe's NSString's stringWithString:(strAppPath)
	set ocidAppBundlePath to ocidAppBundlePathStr's stringByStandardizingPath()
	set ocidAppBundlePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAppBundlePath) isDirectory:true
end if
###コマンドのあるディレクトリ
set ocidBinDirPathURL to ocidAppBundlePathURL's URLByAppendingPathComponent:("Contents/Resources/bin/")
###ダイアログの戻り値を加えてバイナリへのパス
set ocidBinPathURL to ocidBinDirPathURL's URLByAppendingPathComponent:(strResponse)
set strBinPath to ocidBinPathURL's |path| as text
log strBinPath
################################
###本処理
repeat with itemAliasFilePath in listAliasFilePath
	###パス
	set strFilePath to (POSIX path of itemAliasFilePath) as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	##コンテナ
	set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
	set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
	set ocidFileName to ocidBaseFilePathURL's lastPathComponent()
	set ocidSaveFileName to (ocidFileName's stringByAppendingPathExtension:("pdf"))
	set ocidSaveFilePathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:(ocidSaveFileName))
	set strSaveFilePath to ocidSaveFilePathURL's |path| as text
	###コマンド整形
	set strCommandText to ("\"" & strBinPath & "\" \"" & strFilePath & "\" \"" & strSaveFilePath & "\"") as text
	##実行はターミナルで（エラーメッセージ出るからね）
	tell application "Terminal"
		launch
		activate
		set objWindowID to (do script "\n\n")
		delay 1
		do script strCommandText in objWindowID
		delay 2
		do script "\n\n" in objWindowID
		#		do script "exit" in objWindowID
		#		set theWid to get the id of window 1
		#		delay 1
		#		close front window saving no
	end tell
	
end repeat
