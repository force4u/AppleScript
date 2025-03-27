#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
(*
ユーザー環境にswiftDialogがインストールされているか？のチェック

エラーコード
30 : アプリケーションが所定の場所にありません
31 : アプリケーションが見つからない　
40: アプリケーションのバージョン取得に失敗しました

v1 初回作成
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
##########################
#設定項目　
set strBundleID to ("au.csiro.dialog") as text
#想定のアプリケーションのパス
set strPrefAppPath to ("~/Library/Application Support/Dialog/Dialog.app")



#所定の場所にあるか？
set ocidPrefAppPathStr to refMe's NSString's stringWithString:(strPrefAppPath)
set ocidPrefAppPath to ocidPrefAppPathStr's stringByStandardizingPath()
set ocidPrefAppPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidPrefAppPath) isDirectory:false)
set appFileManager to refMe's NSFileManager's defaultManager()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidPrefAppPath) isDirectory:(true)
if boolDirExists = true then
	#OK所定の場所にあります
	set ocidAppPathURL to ocidPrefAppPathURL
else if boolDirExists = false then
	log "アプリケーションが所定の場所にありません"
	#アプリケーションを探す
	set listResponse to doChkAppPath(strBundleID)
	if listResponse is false then
		log "アプリケーションが見つかりませんでした"
		#戻しのエラーコードはお好みで
		return 31
	else
		log "アプリケーションが見つかりました"
		set {strAppPath, ocidAppPathURL} to listResponse
		log strAppPath
		return 30
	end if
end if

log ocidAppPathURL's |path|() as text
set listAppVersion to doChkVersion(ocidAppPathURL)
if listAppVersion is false then
	return 40
else
	set {strVersionPlist, strVerShortPlist} to listAppVersion
	return strVerShortPlist
end if




##########################
##########################
#【A】インストール済みチェック
to doChkAppPath(argBundleID)
	set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(argBundleID))
	if ocidAppBundle = (missing value) then
		#バンドルで見つからない場合　NSWorkspace
		set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
		set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(argBundleID))
		if ocidAppPathURL = (missing value) then
			#AppKitで見つからない場合 Finder
			try
				tell application "Finder"
					set aliasAppApth to (application file id argBundleID) as alias
					set strAppPath to (POSIX path of aliasAppApth) as text
				end tell
				set strAppPathStr to (refMe's NSString's stringWithString:(strAppPath))
				set strAppPath to strAppPathStr's stringByStandardizingPath()
				set ocidAppPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true)
			on error
				#見つからない
				return false
			end try
		end if
	else
		#バンドルで見つかる場合
		set ocidAppPathURL to ocidAppBundle's bundleURL()
	end if
	##########################
	#本当にあるか？チェック
	set ocidAppPath to ocidAppPathURL's |path|()
	set appFileManager to refMe's NSFileManager's defaultManager()
	set boolDirExists to appFileManager's fileExistsAtPath:(ocidAppPath) isDirectory:(true)
	if boolDirExists is true then
		log "インストール済み"
	else if boolDirExists is false then
		log "アプケーションを発見できません"
		return false
	end if
	log ocidAppPathURL's |path|() as text
	set strAppPath to ocidAppPathURL's |path|() as text
	set listResponse to {strAppPath, ocidAppPathURL} as list
	return listResponse
end doChkAppPath

##########################
#【E】バージョン確認
to doChkVersion(argAppPathURL)
	set ocidAppBundle to refMe's NSBundle's alloc()'s initWithURL:(argAppPathURL)
	set ocidVersion to (ocidAppBundle's objectForInfoDictionaryKey:("CFBundleVersion"))
	set ocidVerShort to (ocidAppBundle's objectForInfoDictionaryKey:("CFBundleShortVersionString"))
	if ocidVerShort = (missing value) then
		log "NSBundle バージョン番号取得できず"
	else
		log ocidVersion as text
		log ocidVerShort as text
	end if
	set ocidPlistFilePathURL to argAppPathURL's URLByAppendingPathComponent:("Contents/Info.plist") isDirectory:(false)
	set listResponse to refMe's NSDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL) |error|:(reference)
	if (item 2 of listResponse) = (missing value) then
		log "正常処理"
		set ocidPlistDict to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		set strErrorNO to (item 2 of listResponse)'s code() as text
		set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
		refMe's NSLog("■：" & strErrorNO & strErrorMes)
		log "エラーしました" & strErrorNO & strErrorMes
		return false
	end if
	set ocidVersionPlist to ocidPlistDict's valueForKey:("CFBundleVersion")
	set ocidVerShortPlist to ocidPlistDict's valueForKey:("CFBundleShortVersionString")
	set strVersionPlist to ocidVersionPlist as text
	set strVerShortPlist to ocidVerShortPlist as text
	if ocidVerShort = ocidVerShortPlist then
		set listResponse to {strVersionPlist, strVerShortPlist} as list
	else
		log "バージョン番号が不一致になりました"
		return false
	end if
	
	return listResponse
end doChkVersion

##########################
#【J】OSチェック
to doChkOsVer()
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSCoreServiceDirectory) inDomains:(refMe's NSSystemDomainMask))
	set ocidCoreServiceDirPathURL to ocidURLsArray's firstObject()
	set ocidPlistFilePathURL to ocidCoreServiceDirPathURL's URLByAppendingPathComponent:("SystemVersion.plist") isDirectory:(false)
	set listResponse to refMe's NSDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL) |error|:(reference)
	if (item 1 of listResponse) ≠ (missing value) then
		set ocidPlistDict to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		set strErrorNO to (item 2 of listResponse)'s code() as text
		set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
		refMe's NSLog("■：" & strErrorNO & strErrorMes)
		log "エラーしました" & strErrorNO & strErrorMes
		return false
	end if
	set ocidVerString to (ocidPlistDict's valueForKey:("ProductVersion"))'s doubleValue()
	return ocidVerString
end doChkOsVer

##########################
# 【M】Bash　実行
to doBashShellScript(argCommandText)
	set strCommandText to argCommandText as text
	log "\r" & strCommandText & "\r"
	set strExec to ("/bin/bash -c '" & strCommandText & "'") as text
	##########
	#コマンド実行
	try
		log "コマンド開始"
		set strResnponse to (do shell script strExec) as text
		log "コマンド終了"
	on error
		return false
	end try
	return strResnponse
end doBashShellScript

##########################
# 【N】ZSH　実行
to doZshShellScript(argCommandText)
	set strCommandText to argCommandText as text
	log "\r" & strCommandText & "\r"
	set strExec to ("/bin/zsh -c '" & strCommandText & "'") as text
	##########
	#コマンド実行
	try
		log "コマンド開始"
		set strResnponse to (do shell script strExec) as text
		log "コマンド終了"
	on error
		return false
	end try
	return strResnponse
end doZshShellScript

##########################
#【A】ディスク残を求める
to doGetDiskLeft()
	#ディスク残を求める
	set appFileManager to refMe's NSFileManager's defaultManager()
	set listResponse to appFileManager's attributesOfFileSystemForPath:("/System/Volumes/Data") |error|:(reference)
	if (item 2 of listResponse) = (missing value) then
		log "正常処理　attributesOfFileSystemForPath"
		set ocidAttrDict to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		set strErrorNO to (item 2 of listResponse)'s code() as text
		set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
		refMe's NSLog("■：" & strErrorNO & strErrorMes)
		log "エラーしました" & strErrorNO & strErrorMes
		return false
	end if
	#ディスク残を求める
	set ocidFreeSize to ocidAttrDict's objectForKey:(refMe's NSFileSystemFreeSize)
	set strFreeBite to ocidFreeSize's stringValue()
	set ocidFullSize to ocidAttrDict's objectForKey:(refMe's NSFileSystemSize)
	set strFullBite to ocidFullSize's stringValue()
	set ocidFreeBiteDeci to refMe's NSDecimalNumber's decimalNumberWithString:(strFreeBite)
	set ocidFullBiteDeci to refMe's NSDecimalNumber's decimalNumberWithString:(strFullBite)
	#指数はお好みで
	#	set realGB to "1073741824" as real
	set realGB to "1000000000" as real
	#割り算
	set ocidFreeGbDeci to ocidFreeBiteDeci's decimalNumberByDividingBy:(realGB)
	set ocidFullGbDeci to ocidFullBiteDeci's decimalNumberByDividingBy:(realGB)
	#小数点以下２桁
	set appNumberFormatter to refMe's NSNumberFormatter's alloc()'s init()
	appNumberFormatter's setPositiveFormat:("0.00")
	set ocidFreeGb to appNumberFormatter's stringFromNumber:(ocidFreeGbDeci)
	set ocidFullGb to appNumberFormatter's stringFromNumber:(ocidFullGbDeci)
	#戻り値変えるならここを変更
	set strReturnText to ("" & ocidFreeGb & "/" & ocidFullGb & " GB") as text
	if ocidFullGb = (missing value) or ocidFreeGb = (missing value) then
		return false
	else
		return strReturnText
	end if
end doGetDiskLeft
return