#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#    "実行後しばらく時間がかかります３０秒"
#
#
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

set strBundleID to "com.apple.configurator.ui" as text

log "実行後しばらく時間がかかります３０秒"

set strCommandText to "date +%s"
set numDate to do shell script strCommandText
##フォルダを作って
set strCommandText to "mkdir -pm 777 /tmp/" & numDate & "" as text
do shell script strCommandText
##ファイル名を定義
set strCNFGdeviceECIDsPlistFilePath to ("/tmp/" & numDate & "/CNFGdeviceECIDs.plist") as text
##
set strCommandText to "'/Applications/Apple Configurator.app/Contents/MacOS/cfgutil' --format plist -f get name ECID installedApps > " & strCNFGdeviceECIDsPlistFilePath & "" as text
try
	set strResponse to (do shell script strCommandText) as text
on error number 1
	display alert "【エラー】デバイスを有線接続してから実行してください"
	return "デバイス未接続"
	
end try

set listDevName to {}
tell application "System Events"
	tell property list file strCNFGdeviceECIDsPlistFilePath
		tell property list item "Output"
			set listDict to name of (every property list item)
			set numDictCnt to count of listDict
			repeat with objDic in listDict
				set objDic to objDic as text
				if objDic is not "Errors" then
					tell property list item objDic
						tell property list item "name"
							set strDevName to value
							copy strDevName to the end of listDevName
						end tell
					end tell
				end if
			end repeat
		end tell
	end tell
end tell


try
	set objResponse to (choose from list listDevName with title "選んでください" with prompt "データを取得するデバイスを選んでください" default items (item 1 of listDevName) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed)
on error
	log "エラーしました"
	return
end try
if objResponse is false then
	return
end if
set theResponse to (objResponse) as text

tell application "System Events"
	tell property list file strCNFGdeviceECIDsPlistFilePath
		tell property list item "Output"
			set listDict to name of (every property list item)
			repeat with objDic in listDict
				set objDic to objDic as text
				if objDic is not "Errors" then
					tell property list item objDic
						tell property list item "name"
							set strDevName to value
						end tell
						if strDevName is theResponse then
							tell property list item "ECID"
								set strECID to value
							end tell
						end if
					end tell
				end if
			end repeat
		end tell
	end tell
end tell

set strText to ""

tell application "System Events"
	tell property list file strCNFGdeviceECIDsPlistFilePath
		tell property list item "Output"
			tell property list item strECID
				tell property list item "installedApps"
					set listAppArray to (every property list item)
					repeat with objAppArray in listAppArray
						
						set listValue to every property list item of objAppArray
						set strDisplayName to value of item 1 of listValue
						set strBundleIdentifier to value of item 3 of listValue
						
						
						set strText to strText & strDisplayName & "\r" & strBundleIdentifier & "\r\r" as text
						
						
					end repeat
				end tell
			end tell
		end tell
	end tell
end tell



###ダイアログを出して
set aliasIconPath to POSIX file "/System/Applications/App Store.app/Contents/Resources/AppIcon.icns" as alias
set theResponse to 2 as number
try
	set objResponse to (display dialog "bundleId+ArtistId" with title "bundleId+ArtistId" default answer strText buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 10 without hidden answer)
on error
	log "エラーしました"
	return
end try
if true is equal to (gave up of objResponse) then
	
	
	
	###保存先フォルダ指定
	set aliasSaveDir to (path to desktop folder from user domain) as alias
	###ファイル名指定
	set theFileName to ("" & strECID & ".rtf") as text
	
	
	#############ここから本処理
	##保存先フォルダのUNIXパス
	set pathSaveDir to POSIX path of aliasSaveDir as text
	
	##ファイル名までをパスにしておく
	set pahtSaveFilePath to (pathSaveDir & theFileName) as text
	
	##ファイル名までのエイリアスパス
	set aliasSaveFilePath to POSIX file pahtSaveFilePath
	
	##テンポラリファイル用のファイル名を生成
	set strDate to (do shell script "date '+%s'")
	
	##テンポラリファイル用ファイルのパス
	set strTmpFilePath to "/tmp/" & strDate & ".txt"
	
	##テンポラリファイルを作成
	do shell script "touch " & strTmpFilePath & ""
	
	##テンポラリファイルをTRF形式に変換
	do shell script "/usr/bin/textutil -convert rtf " & strTmpFilePath & "  -output " & pahtSaveFilePath & ""
	delay 1
	##########ファイルを開いて上書き保存して新規書類確定
	tell application "TextEdit"
		activate
		open aliasSaveFilePath
		tell document 1
			set its text to strText
			save in aliasSaveFilePath
		end tell
	end tell
	
end if
if "OK" is equal to (button returned of objResponse) then
	set theResponse to (text returned of objResponse) as text
else
	return "キャンセル"
end if

###ファイルを開く
tell application "Finder"
	set aliasPlist to POSIX file strCNFGdeviceECIDsPlistFilePath as alias
	open aliasPlist
end tell
