#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###処理対象のファイルUTI１つ
property strBundleID : ("com.apple.applescript.text")

on run
	set appFileManager to refMe's NSFileManager's defaultManager()
	tell current application
		set strName to name as text
	end tell
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
	set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
	set strMes to ("ファイルを選んでください") as text
	set strPrompt to ("ファイルを選んでください") as text
	set listUTI to {strBundleID} as list
	try
		###　ファイル選択時
		set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles, multiple selections allowed and showing package contents) as list
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	if listAliasFilePath is {} then
		return "選んでください"
	end if
	
	open listAliasFilePath
end run


on open listAliasFilePath
	
	repeat with itemAliasPath in listAliasFilePath
		###入力パス
		set strFilePath to (POSIX path of itemAliasPath) as text
		set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath))
		set aliasFilePath to (ocidFilePathURL's absoluteURL()) as alias
		###フォルダ除外
		set listBool to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		if (item 2 of listBool) = (refMe's NSNumber's numberWithBool:true) then
			log "ディレクトリは処理しない"
		end if
		###UTI取得
		set listContentTypeKey to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLContentTypeKey) |error|:(reference))
		set ocidContentType to (item 2 of listContentTypeKey)
		set strUTI to (ocidContentType's identifier) as text
		###対象のUTIファイルタイプだけ処理する
		if strUTI is strBundleID then
			###本処理
			tell application "CotEditor"
				open file aliasFilePath
				###ファイルOPENを待つ
				repeat 5 times
					set numCnt to (count of document) as integer
					if numCnt > 0 then
						exit repeat
					else
						delay 0.2
					end if
				end repeat
				###開いたドキュメント
				tell front document
					properties
					###改行をUNIX LFに
					set refLineEnc to line ending
					if refLineEnc is CRLF then
						log "改行コードはCRLF＝WINDOWSです"
						set line ending to LF
					else if refLineEnc is CR then
						log "改行コードはCR＝MacOSです"
						set line ending to LF
					end if
					###文字コードをUTF8に
					set strCharEnc to (IANA charset) as rich text
					if strCharEnc is not "utf-8" then
						convert to "utf-8" without lossy and BOM
					end if
					###上書きしてどじる
					save
					close
					###ウィンドウが閉じるのを待つ
					repeat 5 times
						set numCnt to (count of document) as integer
						if numCnt = 0 then
							exit repeat
						else
							delay 0.2
						end if
					end repeat
					
				end tell
			end tell
		else
			log "UTIが違えばは処理しない"
		end if
	end repeat
	log "処理終了"
end open
