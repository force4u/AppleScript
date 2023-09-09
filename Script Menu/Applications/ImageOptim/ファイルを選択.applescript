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


###UTI
set strBundleID to "net.pornel.ImageOptim" as text


##終了させる
tell application id strBundleID to quit
####半ゾンビ化対策	
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate
end repeat

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
tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
try
	set listUTI to {"public.image"}
	set strMes to ("ファイルを選んでください") as text
	set strPrompt to ("ファイルを選んでください") as text
	set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles, multiple selections allowed and showing package contents) as list
on error
	log "エラーしました"
	return
end try

###ファイルの数だけ繰返し


repeat with itemAliasFilePath in listAliasFilePath
	set aliasFilePath to itemAliasFilePath as alias
	tell application id strBundleID to open file aliasFilePath
end repeat



##終了させる　これは結果みたい場合はコメントアウト
try
	#	tell application id strBundleID to quit
end try
return
