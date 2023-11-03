#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　macOS14対応
#	NSData 取得したデータを保存そのまま保存してOPENする
# 保存先は $HOME/Documents/Mobileconfig
#登録はNSWorkspaceを利用
#  com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

###【１】URL
tell application id "com.apple.systempreferences" to quit
########################
## クリップボードの中身取り出し
########################
##クリップボードにテキストが無い場合
set strMes to "https://raw.githubusercontent.com/force4u/AppleScript/main/Script%20Menu/Applications/Script%20Editor/Script%20Menu/Mobileconfig/Mobileconfig/com.apple.scriptmenu.mobileconfig" as text
###初期化
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to ocidPasteboard's types
###テキストがあれば
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	###値を格納する
	tell application "Finder"
		set strDefaultAnswer to (the clipboard as text) as text
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
##############################
#####ダイアログ
##############################
##前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###アイコンパス
set strDialogMes to "MobileconfigへのURLを入力してください"
set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
try
	#	set recordResult to (display dialog strDialogMes with title "入力してください" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" with icon aliasIconPath giving up after 10 without hidden answer) as record
	set recordResult to (display dialog strDialogMes with title "入力してください" default answer strMes buttons {"OK", "キャンセル"} default button "OK" with icon aliasIconPath giving up after 10 without hidden answer) as record
on error
	log "エラーしました"
	return "キャンセル"
end try

if "OK" is equal to (button returned of recordResult) then
	set strFileURL to (text returned of recordResult) as text
else if (gave up of recordResult) is true then
	return "時間切れです"
else
	return "キャンセル"
end if

set ocidFileURLStr to refMe's NSString's stringWithString:(strFileURL)
set ocidFileURLStr to ocidFileURLStr's stringByRemovingPercentEncoding
set ocidFileURL to refMe's NSURL's URLWithString:(ocidFileURLStr)
#保存用にファイル名取っておく
set ocidFileName to ocidFileURL's lastPathComponent()
#%エンコードされたファイル名は戻しておく
set ocidSaveFileName to ocidFileName's stringByRemovingPercentEncoding

###【２】URL読み込み
#【２-1】NSdataに読み込む（エラー制御したいため-->いきなりNSMutableDictionaryでもOK）
set ocidOption to refMe's NSDataReadingMappedIfSafe
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidFileURL) options:(ocidOption) |error|:(reference)
if (item 2 of listReadData) ≠ (missing value) then
	return "コンテンツの収集に失敗しました エラー　URL　missing value"
else
	log "【２-1】" & (item 2 of listReadData)
	set ocidPlistData to (item 1 of listReadData)
end if

###【３】ファイルの保存先（書類フォルダ）
###保存先ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidUserDocumentPathArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentPathURL to ocidUserDocumentPathArray's firstObject()
#保存先ディレクトリを作る 700
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set ocidSaveDirPathURL to ocidDocumentPathURL's URLByAppendingPathComponent:("Mobileconfig") isDirectory:false
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
log "【３】" & (item 1 of listBoolMakeDir)
##保存ファイルのパス
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidSaveFileName)

###【５】保存
set boolDone to ocidPlistData's writeToURL:(ocidSaveFilePathURL) atomically:true
log "【５】" & boolDone

###【６】登録実行
tell application "System Settings" to activate
--システム環境設定が開くのを待つ
repeat
	set doLaunchApp to get running of application "System Settings"
	if doLaunchApp is false then
		tell application "System Settings" to activate
		delay 0.5
	else
		exit repeat
	end if
end repeat
try
	set strCommandText to "open -b com.apple.systempreferences \"/System/Library/PreferencePanes/Profiles.prefPane\"" as text
	do shell script strCommandText
on error
	tell application id "com.apple.systempreferences"
		activate
		reveal anchor "Main" of pane id "com.apple.Profiles-Settings.extension"
	end tell
end try
repeat 10 times
	tell application id "com.apple.systempreferences"
		activate
		reveal anchor "Main" of pane id "com.apple.Profiles-Settings.extension"
		tell current pane
			set strPaneID to id as text
			properties
		end tell
	end tell
	if strPaneID is "com.apple.settings.PrivacySecurity.extension" then
		exit repeat
	else
		delay 0.5
	end if
end repeat

tell application "Finder"
	
	set strFilePath to ocidSaveFilePathURL's |path| as text
	
	set theCmdCom to ("open  \"" & strFilePath & "\" | open \"x-apple.systempreferences:com.apple.preferences.configurationprofiles\"") as text
	do shell script theCmdCom
end tell

log "【６】Done"

###【７】保存ファイル表示
#選択状態で開く
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appShardWorkspace's selectFile:(ocidSaveFilePathURL's |path|) inFileViewerRootedAtPath:(ocidDocumentPathURL's |path|)
log "【７】" & boolDone

###【８】システム設定を前面に
###システム設定を前面に
set ocidRunningApp to refMe's NSRunningApplication
set ocidAppArray to (ocidRunningApp's runningApplicationsWithBundleIdentifier:("com.apple.systempreferences"))
set ocidApp to ocidAppArray's firstObject()
ocidApp's activateWithOptions:(refMe's NSApplicationActivateAllWindows)
set boolDone to ocidApp's active
log "【８】" & boolDone

####日付情報の取得
to doGetDateNo(strDateFormat)
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo