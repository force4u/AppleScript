
#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#カーソル位置に元号（令和）日付をスタンプします
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set strBundleID to ("jp.co.artman21.JeditOmega") as text

########################################
### エラー制御
########################################
tell application id strBundleID
	set numCntOpenDoc to (count document) as integer
end tell
if numCntOpenDoc = 0 then
	set aliasIconPath to doGetIconPath(strBundleID)
	#####ダイアログを前面に
	tell current application
		set strName to name as text
	end tell
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	set strMes to "ドキュメントを開いていません"
	set strTitle to "エラー"
	set recordResult to (display dialog strMes with title strTitle buttons {"OK"} default button "OK" giving up after 1 with icon aliasIconPath without hidden answer)
	return "ドキュメントがありません"
end if
########################################
### エラー制御
########################################
tell application "Jedit Ω"
	tell front document
		properties
		set strFileName to name as text
		set strFilePath to path as text
	end tell
end tell

if strFileName does not end with "sh" then
	set aliasIconPath to doGetIconPath(strBundleID)
	#####ダイアログを前面に
	tell current application
		set strName to name as text
	end tell
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	set strMes to "スクリプトファイルではありません"
	set strTitle to "エラー"
	display dialog strMes with title strTitle buttons {"OK"} default button "OK" giving up after 1 with icon aliasIconPath without hidden answer
	return strMes
end if
###実行可能にしておく
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
set listDone to appFileManager's setAttributes:(ocidAttrDict) ofItemAtPath:(ocidFilePath) |error|:(reference)
########################################
### ターミナルで実行
########################################
## 実行中チェック
tell application "Terminal"
	set numCntWindow to (count of every window) as integer
end tell
if numCntWindow = 0 then
	log "Windowないので新規で作る"
	tell application "Terminal"
		set objNewWindow to (do script "\n")
	end tell
else
	log "Windowがある場合は、何か実行中か？をチェック"
	tell application "Terminal"
		tell front window
			tell front tab
				set boolTabStatus to busy as boolean
				set listProcess to processes as list
			end tell
		end tell
		set objNewWindow to selected tab of front window
	end tell
	###前面のタブがbusy＝実行中なら新規Window作る
	if boolTabStatus = true then
		tell application "Terminal"
			set objNewWindow to (do script "\n")
		end tell
	else if listProcess = {} then
		tell application "Terminal"
			set objNewWindow to (do script "\n")
		end tell
	end if
end if
##############################
##　コマンド実行
set strCommandText to ("\"" & strFilePath & "\"") as text
tell application "Terminal"
	activate
	do script strCommandText in objNewWindow
end tell


########################################
### アイコンパス
########################################
to doGetIconPath(argBundleID)
	##初期化
	set appFileManager to refMe's NSFileManager's defaultManager()
	set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
	##バンドルIDからアプリケーションのインストール先を求める
	set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(argBundleID))
	if ocidAppBundle ≠ (missing value) then
		set ocidAppPathURL to ocidAppBundle's bundleURL()
	else if ocidAppBundle = (missing value) then
		set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(argBundleID))
	end if
	##予備（アプリケーションのURL）
	if ocidAppPathURL = (missing value) then
		tell application "Finder"
			try
				set aliasAppApth to (application file id argBundleID) as alias
				set strAppPath to POSIX path of aliasAppApth as text
				set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
				set strAppPath to strAppPathStr's stringByStandardizingPath()
				set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
			on error
				return "アプリケーションが見つかりませんでした"
			end try
		end tell
	end if
	###アイコン名をPLISTから取得
	set ocidPlistPathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/Info.plist") isDirectory:false
	set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
	set strIconFileName to (ocidPlistDict's valueForKey:("CFBundleIconFile")) as text
	###ICONのURLにして
	set strPath to ("Contents/Resources/" & strIconFileName) as text
	set ocidIconFilePathURL to ocidAppPathURL's URLByAppendingPathComponent:(strPath) isDirectory:false
	###拡張子の有無チェック
	set strExtensionName to (ocidIconFilePathURL's pathExtension()) as text
	if strExtensionName is "" then
		set ocidIconFilePathURL to ocidIconFilePathURL's URLByAppendingPathExtension:"icns"
	end if
	###ICONファイルが実際にあるか？チェック
	set boolExists to appFileManager's fileExistsAtPath:(ocidIconFilePathURL's |path|)
	###ICONがみつかない時用にデフォルトを用意する
	if boolExists is false then
		set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
	else
		set aliasIconPath to ocidIconFilePathURL's absoluteURL() as alias
	end if
	return aliasIconPath as alias
end doGetIconPath
