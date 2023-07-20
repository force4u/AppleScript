#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#https://www.dropboxforum.com/t5/Dropbox-desktop-client-builds/bd-p/101003016
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
##########################
##　最新のバージョン取得
##########################
##RSSのURL
set strRssURL to "https://www.dropboxforum.com/mxpez29397/rss/board?board.id=101003016" as text
set ocidRssURL to refMe's NSURL's URLWithString:(strRssURL)
###XML読み込み
set ocidOption to refMe's NSXMLDocumentTidyXML
set listXmlDoc to refMe's NSXMLDocument's alloc()'s initWithContentsOfURL:(ocidRssURL) options:(ocidOption) |error|:(reference)
set ocidReadXMLDoc to (item 1 of listXmlDoc)
###ROOT
set ocidRootElement to ocidReadXMLDoc's rootElement()
set numChild to (count of ocidRootElement's children) as integer
###第一階層　channel
set ocidChannel to (ocidRootElement's childAtIndex:0)
set numChild to (count of ocidChannel's children) as integer
###子要素の数だけ繰り返し
repeat with numCntChild from 0 to (numChild - 1)
	set strChldName to (ocidChannel's childAtIndex:numCntChild)'s |name| as text
	####要素名がitemなら
	if strChldName is "item" then
		###itemのtitleをテキストで取得して
		set ocidItemObject to ((ocidChannel's childAtIndex:numCntChild)'s childAtIndex:0)
		set ocidTitle to ocidItemObject's stringValue()
		###最初のStable項目＝最新
		if (ocidTitle as text) contains "Stable" then
			set ocidTitleArray to (ocidTitle's componentsSeparatedByString:(" "))
			###バージョンテキストを取得したらリピート終了
			set strVersion to (ocidTitleArray's lastObject()) as text
			exit repeat
		end if
	end if
end repeat
###取得したバージョン番号
log strVersion
##########################
##　ダウンロードするURLを生成
##########################
##CPUタイプのよる処理の分岐
set objSysInfo to system info
set theCpuType to (CPU type of objSysInfo) as text

if theCpuType contains "Intel" then
	#	set strURL to "https://www.dropbox.com/downloading?plat=mac&type=full"
	set strFileName to "Dropbox " & strVersion & ".dmg" as text
	#	set strURL to ("https://edge.dropboxstatic.com/dbx-releng/client/" & strFileName & "") as text
else
	#set strURL to "https://www.dropbox.com/downloading?plat=mac&type=full&arch=arm64"
	set strFileName to "Dropbox " & strVersion & ".arm64.dmg" as text
	#set strURL to ("https://edge.dropboxstatic.com/dbx-releng/client/" & strFileName & "") as text
end if
####ダウンロードするDMGファイル名とURLが確定
set ocidURL to refMe's NSURL's alloc()'s initWithString:("https://edge.dropboxstatic.com/dbx-releng/client/")
##ファイル名
set ocidURL to ocidURL's URLByAppendingPathComponent:(strFileName)
set strURL to ocidURL's absoluteString() as text
log strURL as text

##########################
##　ダウンロードするファイル
##########################
###テンポラリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTemporaryDirPathURL to appFileManager's temporaryDirectory
set ocidTemporaryItemsPathURL to ocidTemporaryDirPathURL's URLByAppendingPathComponent:("TemporaryItems")
###同一パスにならないようにUUIDを足す
set ocidUUID to refMe's NSUUID's alloc()'s init()
set coidUUID to ocidUUID's UUIDString()
set ocidLocalUUIDPathURL to ocidTemporaryItemsPathURL's URLByAppendingPathComponent:(coidUUID)
###DMG保存ディレクトリ
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
appFileManager's createDirectoryAtURL:(ocidLocalUUIDPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)
###ファイル名を足してDMGの保存パス
set ocidLocalPathURL to ocidLocalUUIDPathURL's URLByAppendingPathComponent:(strFileName)
set strLocalPath to (ocidLocalPathURL's |path|) as text
##########################
##　ダウンロード
##########################
try
	set strCommandText to ("/usr/bin/curl -L -o \"" & strLocalPath & "\"   \"" & strURL & "\" --connect-timeout 10") as text
	do shell script strCommandText
on error
	set strCommandText to ("/usr/bin/curl -L -o \"" & strLocalPath & "\"   \"" & strURL & "\" --http1.1 --connect-timeout 10") as text
	do shell script strCommandText
end try

##########################
##　関連プロセス終了
##########################
set listBundleID to {"com.dropbox.Electron.helper", "com.getdropbox.dropbox"}

repeat with itemUTI in listBundleID
	###NSRunningApplication
	set ocidRunningApplication to refMe's NSRunningApplication
	###起動中のすべてのリスト
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(itemUTI))
	###複数起動時も順番に終了
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate()
	end repeat
end repeat

##########################
##　関連プロセス終了
##########################
try
	tell application id "com.getdropbox.dropbox" to quit
end try
try
	do shell script "killall \"Dropbox Helper\""
	do shell script "killall \"Dropbox Helper (Renderer)\""
	do shell script "killall \"Dropbox Helper (Plugin)\""
	do shell script "killall \"Dropbox Helper (GPU)\""
	do shell script "killall \"Dropbox\""
	do shell script "killall \"DropboxActivityProvider\""
	do shell script "killall \"DropboxFileProviderCH\""
	do shell script "killall \"DropboxFileProvider\""
	do shell script "killall \"DropboxTransferExtension\""
end try
##########################
##　本処理
##########################
##appNSWorkspaceでドライブを表示しないマウント方法がわからない
set theComandText to ("/usr/bin/hdiutil attach  \"" & strLocalPath & "\" -noverify -nobrowse -noautoopen\n") as text
do shell script theComandText
####この方法だとサイレントにならない
###set theComandText to ("\"/Volumes/Dropbox Offline Installer/Dropbox.app/Contents/MacOS/Dropbox\" - nolaunch") as text
###do shell script theComandText with administrator privileges


##############################
## 実行するコマンド
set strCommandText to ("/usr/bin/sudo /usr/bin/ditto \"/Volumes/Dropbox Offline Installer/Dropbox.app\" \"/Applications/Dropbox.app\"") as text
##############################
## 実行中チェック
tell application "Terminal"
	set numCntWindow to (count of every window) as integer
end tell
delay 0.5
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
delay 0.5
##############################
##　コマンド実行
tell application "Terminal"
	activate
	do script strCommandText in objNewWindow
end tell
delay 1
log "コマンド実行中"
##############################
## コマンド終了チェック
(*
objNewWindowにWindowIDとTabIDが入っているので
objNewWindowに対してbusyを確認する事で
処理が終わっているか？がわかる
*)
## 無限ループ防止で１００回
repeat 100 times
	tell application "Terminal"
		set boolTabStatus to busy of objNewWindow
	end tell
	if boolTabStatus is false then
		log "コマンド処理終了しました"
		tell application "Terminal"
			tell front window
				tell front tab
					set listProcess to processes as list
				end tell
			end tell
		end tell
		set numCntProcess to (count of listProcess) as integer
		if numCntProcess ≤ 2 then
			exit repeat
		else
			delay 1
		end if
		--->このリピートを抜けて次の処理へ
	else if boolTabStatus is true then
		log "コマンド処理中"
		delay 1
		--->busyなのであと1秒まつ
	end if
end repeat
tell application "Terminal" to activate


##############################
## exit打って終了
tell application "Terminal"
	do script "exit" in objNewWindow
end tell
##############################
## exitの処理待ちしてClose
repeat 20 times
	tell application "Terminal"
		tell front window
			tell front tab
				set listProcess to processes as list
			end tell
		end tell
	end tell
	if listProcess = {} then
		tell application "Terminal"
			tell front window
				# tell front tab
				close saving no
				# end tell
			end tell
		end tell
		exit repeat
	else
		delay 1
	end if
end repeat

##########################
##　アンマウント
##########################
set strDiskPath to "/Volumes/Dropbox Offline Installer"
set ocidDiskPathStr to refMe's NSString's stringWithString:(strDiskPath)
set ocidDiskPath to ocidDiskPathStr's stringByExpandingTildeInPath()
set ocidDiskPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDiskPath) isDirectory:false)
set appNSWorkspace to refMe's NSWorkspace's sharedWorkspace()
(appNSWorkspace's unmountAndEjectDeviceAtURL:(ocidDiskPathURL) |error|:(reference))
try
	set theComandText to ("/usr/bin/hdiutil detach \"" & strDiskPath & "\" -force") as text
	do shell script theComandText
end try

