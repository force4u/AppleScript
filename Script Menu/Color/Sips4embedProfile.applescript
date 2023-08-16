
#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()


property strBundleID : "com.apple.imageevents"


tell application id strBundleID to launch
tell application id strBundleID to activate

###################################
#####ダイアログ
###################################
###デフォルトロケーション
set ocidForDirArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidForDirArray's firstObject()
set aliasDefaultLocation to (ocidDesktopPathURL's absoluteURL()) as alias
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
set listChooseFileUTI to {"public.image"}
set strPromptText to "ファイルを選んでください" as text
set strMesText to "ファイルを選んでください" as text
set listAliasFilePath to (choose file strMesText with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with multiple selections allowed, invisibles and showing package contents) as list


###################################
#### ディスプレイ may be missing value
###################################
tell application "Image Events"
	set listNameOfDisplay to (every display) as list
	set numDisplay to (count of listNameOfDisplay) as integer
	repeat with itemNameOfDisplay in listNameOfDisplay
		log itemNameOfDisplay
		tell itemNameOfDisplay
			properties
		end tell
	end repeat
end tell
###################################
#### プロファイル
###################################
tell application "Image Events"
	set listProFile to (every profile) as list
	set listProFileName to {} as list
	repeat with itemProFile in listProFile
		tell itemProFile
			set strProFileName to name as text
		end tell
		set end of listProFileName to strProFileName
	end repeat
end tell

###################################
#####ダイアログ
###################################

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
try
	set listResponse to (choose from list listProFileName with title "選んでください" with prompt "添付するプロファイルを選んでください" default items (item 1 of listProFileName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text
###プロファイルを読み込み
tell application "Image Events"
	tell profile strResponse
		set aliasProfilePath to location as alias
	end tell
end tell
set strProfilePath to (POSIX path of aliasProfilePath) as text

###################################
#####本処理
###################################

repeat with itemAliasFilePath in listAliasFilePath
	log itemAliasFilePath
	set aliasFilePath to itemAliasFilePath as alias
	set strFilePath to (POSIX path of aliasFilePath) as text
	
	set strCommandText to ("/usr/bin/sips --embedProfile \"" & strProfilePath & "\" \"" & strFilePath & "\"") as text
	do shell script strCommandText
	
end repeat


