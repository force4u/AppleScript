#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#パッケージのみ作成　署名はしないのでそのままでは使えない
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

##バンドルID
set strBundleID to ("com.cocolog-nifty.quicktimer") as text
##バージョン（面倒なので日付にした）
set strVersion to doGetDateNo("yyyyMMdd") as text


#############################
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
tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell

############UTIリスト
set listUTI to {"public.bash-script", "public.shell-script", "public.zsh-script"}
set strMes to ("シェルスクリプトファイルを選んでください") as text
set strPrompt to ("シェルスクリプトファイルを選んでください") as text
try
	###　ファイル選択時
	set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
###スクリプトのパス
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidBaseFilePath to ocidFilePath's stringByDeletingPathExtension()
set ocidFileName to ocidBaseFilePath's lastPathComponent()
set strFileName to ocidFileName as text
###テンポラリ内で生成
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
##UUIDをフォルダ名とする
set ocidUUID to refMe's NSUUID's alloc()'s init()
set strUUID to ocidUUID's UUIDString as text
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(strUUID) isDirectory:true
set ocidSaveDirPath to ocidSaveDirPathURL's |path|()
###作業用フォルダUUID
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtPath:(ocidSaveDirPath) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###必要なフォルダ
set ocidPkgDirPath to ocidSaveDirPath's stringByAppendingPathComponent:(strFileName)
set ocidNopayloadDirPath to ocidPkgDirPath's stringByAppendingPathComponent:("nopayload")
set ocidScriptsDirPath to ocidPkgDirPath's stringByAppendingPathComponent:("scripts")
###↑各種フォルダ生成
set listBoolMakeDir to appFileManager's createDirectoryAtPath:(ocidPkgDirPath) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set listBoolMakeDir to appFileManager's createDirectoryAtPath:(ocidNopayloadDirPath) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set listBoolMakeDir to appFileManager's createDirectoryAtPath:(ocidScriptsDirPath) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###postinstallファイルのコピー
set ocidPostinstallFilePath to ocidScriptsDirPath's stringByAppendingPathComponent:("postinstall")
set listDone to appFileManager's copyItemAtPath:(ocidFilePath) toPath:(ocidPostinstallFilePath) |error|:(reference)
#アクセス権777
set listDone to appFileManager's setAttributes:(ocidAttrDict) ofItemAtPath:(ocidPostinstallFilePath) |error|:(reference)
###PKG出来上がり予定パス
set strPkgFileName to (strFileName & "." & strVersion & ".pkg") as text
set ocidPkgFilePath to ocidPkgDirPath's stringByAppendingPathComponent:(strPkgFileName)
###コマンド用にテキスト形式に
set strPkgFilePath to ocidPkgFilePath as text
set strNopayloadDirPath to ocidNopayloadDirPath as text
set strScriptsDirPath to ocidScriptsDirPath as text

###パッケージ作成
##set strCommandText to ("/usr/bin/pkgbuild --identifier \"" & strBundleID & "\" --version \"" & strVersion & "\" --scripts \"" & strScriptsDirPath & "\" --root  \"" & strNopayloadDirPath & "\"  \"" & strPkgFilePath & "\"") as text

set strCommandText to ("/usr/bin/pkgbuild --nopayload --identifier \"" & strBundleID & "\" --version \"" & strVersion & "\" --scripts \"" & strScriptsDirPath & "\" --root  \"" & strNopayloadDirPath & "\"  \"" & strPkgFilePath & "\"") as text
do shell script strCommandText

##スクリプトと同階層に移動
set ocidContainerDirPath to ocidFilePath's stringByDeletingLastPathComponent()
set ocidMovePkgFilePath to ocidContainerDirPath's stringByAppendingPathComponent:(strPkgFileName)
set listDone to appFileManager's moveItemAtPath:(ocidPkgFilePath) toPath:(ocidMovePkgFilePath) |error|:(reference)

return


##############################
### 今の日付日間　テキスト
##############################
to doGetDateNo(argDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	set ocidTimeZone to refMe's NSTimeZone's alloc()'s initWithName:"Asia/Tokyo"
	ocidNSDateFormatter's setTimeZone:(ocidTimeZone)
	ocidNSDateFormatter's setDateFormat:(argDateFormat)
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
