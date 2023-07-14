#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


property refMe : a reference to current application


set objFileManager to refMe's NSFileManager's defaultManager()
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()


####ダイアログで使うデフォルトロケーション
set ocidGetUrlArray to (objFileManager's URLsForDirectory:(refMe's NSDownloadsDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidGetUrlArray's objectAtIndex:0
set aliasDefaultLocation to ocidDesktopDirPathURL as alias

####UTIリスト com.apple.webarchiveかplist
set listUTI to {"com.apple.webarchive", "com.apple.property-list"}


####ダイアログを出す
set aliasFilePath to (choose file with prompt "webarchive　ファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias

set strFilePath to (POSIX path of aliasFilePath) as text
####ドキュメントのパスをNSString
set ocidFilePath to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePath's stringByStandardizingPath
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false
###選んだファイルのディレクトリ
set ocidContainerDirURL to ocidFilePathURL's URLByDeletingLastPathComponent

##############################################
## 本処理
##############################################
###PLIST ROOT
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set listReadPlistData to refMe's NSMutableDictionary's dictionaryWithContentsOfURL:(ocidFilePathURL) |error|:(reference)
set ocidPlistDict to item 1 of listReadPlistData
##############################################
## 本処理　　　WebMainResource
##############################################
###ダウンロードしたURLのホスト名を保存先フォルダ名にする
set ocidWebMainResourceDict to ocidPlistDict's objectForKey:"WebMainResource"
set ocidMainURLString to ocidWebMainResourceDict's valueForKey:("WebResourceURL")
set ocidURLString to refMe's NSString's stringWithString:(ocidMainURLString)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidMainURLString)
set strHostName to ocidURL's |host|() as text
set strHostName to (strHostName & "/Images")
###イメージ保存先
set ocidSaveFileDirURL to (ocidContainerDirURL's URLByAppendingPathComponent:(strHostName))
###保存先ディレクトリを作成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
objFileManager's createDirectoryAtURL:ocidSaveFileDirURL withIntermediateDirectories:true attributes:ocidAttrDict |error|:(reference)

##############################################
## 本処理　　　WebSubresources
##############################################
###WebSubresources
set ocidWebSubresourcesArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
set ocidWebSubresourcesArray to ocidPlistDict's objectForKey:"WebSubresources"
###インラインイメージ用のカウント
set numInlineNO to 1 as text
repeat with itemWebSubresourcesDict in ocidWebSubresourcesArray
	set strMIME to (itemWebSubresourcesDict's objectForKey:"WebResourceMIMEType") as text
	if strMIME contains "image" then
		set ocidWebPath to (itemWebSubresourcesDict's objectForKey:"WebResourceURL")
		set strWebPath to ocidWebPath as text
		#####
		if strWebPath contains "data:image" then
			#####インラインSVGを保存するやっつけ感満載の処理…
			
			if strWebPath contains "data:image/svg+xml;charset=utf-8," then
				set strFileName to "svg-" & numInlineNO & ".svg" as text
				set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:strFileName)
				
				set AppleScript's text item delimiters to "data:image/svg+xml;charset=utf-8,"
				set listDelim to every text item of strWebPath
				set AppleScript's text item delimiters to ""
				set strInLineContents to item 2 of listDelim
				set ocidInlineContents to (refMe's NSString's stringWithString:strInLineContents)
				set ocidDencodedContents to (ocidInlineContents's stringByRemovingPercentEncoding)
				set boolDone to (ocidDencodedContents's writeToURL:ocidSaveFilePathURL atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
				
			else if strWebPath contains "data:image/svg+xml;charset=utf-8," then
				set strFileName to "svg-" & numInlineNO & ".svg" as text
				set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:strFileName)
				
				set AppleScript's text item delimiters to "data:image/svg+xml;charset=utf-8,"
				set listDelim to every text item of strWebPath
				set AppleScript's text item delimiters to ""
				set strInLineContents to item 2 of listDelim
				set ocidInlineContents to (refMe's NSString's stringWithString:strInLineContents)
				set ocidDencodedContents to (ocidInlineContents's stringByRemovingPercentEncoding)
				set boolDone to (ocidDencodedContents's writeToURL:ocidSaveFilePathURL atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
				
			else if strWebPath contains "data:image/svg+xml;base64," then
				set strFileName to "png-" & numInlineNO & ".svg" as text
				set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:strFileName)
				
				set AppleScript's text item delimiters to "data:image/svg+xml;base64,"
				set listDelim to every text item of strWebPath
				set AppleScript's text item delimiters to ""
				set strInLineContents to item 2 of listDelim
				set ocidInlineContents to (refMe's NSString's stringWithString:strInLineContents)
				set ocidData to (refMe's NSData's alloc()'s initWithBase64EncodedString:ocidInlineContents options:(refMe's NSDataBase64DecodingIgnoreUnknownCharacters))
				set boolResults to (ocidData's writeToURL:ocidSaveFilePathURL atomically:true)
				
			else if strWebPath contains "data:image/png;base64," then
				set strFileName to "png-" & numInlineNO & ".png" as text
				set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:strFileName)
				
				set AppleScript's text item delimiters to "data:image/png;base64,"
				set listDelim to every text item of strWebPath
				set AppleScript's text item delimiters to ""
				set strInLineContents to item 2 of listDelim
				set ocidInlineContents to (refMe's NSString's stringWithString:strInLineContents)
				set ocidData to (refMe's NSData's alloc()'s initWithBase64EncodedString:ocidInlineContents options:(refMe's NSDataBase64DecodingIgnoreUnknownCharacters))
				set boolResults to (ocidData's writeToURL:ocidSaveFilePathURL atomically:true)
				
			else if strWebPath contains "data:image/jpeg;base64," then
				set strFileName to "jpg-" & numInlineNO & ".jpg" as text
				set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:strFileName)
				
				set AppleScript's text item delimiters to "data:image/jpeg;base64,"
				set listDelim to every text item of strWebPath
				set AppleScript's text item delimiters to ""
				set strInLineContents to item 2 of listDelim
				set ocidInlineContents to (refMe's NSString's stringWithString:strInLineContents)
				set ocidData to (refMe's NSData's alloc()'s initWithBase64EncodedString:ocidInlineContents options:(refMe's NSDataBase64DecodingIgnoreUnknownCharacters))
				set boolResults to (ocidData's writeToURL:ocidSaveFilePathURL atomically:true)
				
			else if strWebPath contains "data:image/jpg;base64," then
				set strFileName to "jpg-" & numInlineNO & ".jpg" as text
				set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:strFileName)
				
				set AppleScript's text item delimiters to "data:image/jpg;base64,"
				set listDelim to every text item of strWebPath
				set AppleScript's text item delimiters to ""
				set strInLineContents to item 2 of listDelim
				set ocidInlineContents to (refMe's NSString's stringWithString:strInLineContents)
				set ocidData to (refMe's NSData's alloc()'s initWithBase64EncodedString:ocidInlineContents options:(refMe's NSDataBase64DecodingIgnoreUnknownCharacters))
				set boolResults to (ocidData's writeToURL:ocidSaveFilePathURL atomically:true)
				
			else
				log "インラインイメージはとりあえず処理しない"
			end if
			set numInlineNO to numInlineNO + 1 as text
		else
			set ocidWebURL to (refMe's NSURL's alloc()'s initWithString:ocidWebPath)
			set ocidFileName to ocidWebURL's lastPathComponent()
			set strExtensionName to ocidWebURL's pathExtension() as text
			if strExtensionName is "" then
				log "拡張子がない"
				ocidFileName's stringByDeletingPathExtension()
				if strMIME contains "png" then
					set ocidFileName to (ocidFileName's stringByAppendingPathExtension:"png")
				else if strMIME contains "jpeg" then
					set ocidFileName to (ocidFileName's stringByAppendingPathExtension:"jpg")
				else if strMIME contains "jpg" then
					set ocidFileName to (ocidFileName's stringByAppendingPathExtension:"jpg")
				else if strMIME contains "webp" then
					set ocidFileName to (ocidFileName's stringByAppendingPathExtension:"webp")
				else if strMIME contains "gif" then
					set ocidFileName to (ocidFileName's stringByAppendingPathExtension:"gif")
				else if strMIME contains "svg" then
					set ocidFileName to (ocidFileName's stringByAppendingPathExtension:"svg")
				end if
			end if
			set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:ocidFileName)
			set ocidImageDataBase64 to (itemWebSubresourcesDict's objectForKey:"WebResourceData")
			set boolResults to (ocidImageDataBase64's writeToURL:ocidSaveFilePathURL atomically:true)
		end if
	else
		log "イメージ以外は処理しない"
	end if
	set ocidImageDataBase64 to ""
end repeat
##############################################
## 本処理　　　WebSubframeArchives
##############################################

###WebSubframe
set ocidWebSubframeArray to ocidPlistDict's objectForKey:"WebSubframeArchives"
###インラインイメージ用のカウント
set numInlineNO to 1 as text
repeat with itemWebSubframeDict in ocidWebSubframeArray
	set ocidWebSubresourcesArray to (itemWebSubframeDict's objectForKey:"WebSubresources")
	repeat with itemWebSubresources in ocidWebSubresourcesArray
		
		
		
		set strMIME to (itemWebSubresources's objectForKey:"WebResourceMIMEType") as text
		if strMIME contains "image" then
			set ocidWebPath to (itemWebSubresources's objectForKey:"WebResourceURL")
			set strWebPath to ocidWebPath as text
			#####
			if strWebPath contains "data:image" then
				#####インラインSVGを保存するやっつけ感満載の処理…
				
				if strWebPath contains "data:image/svg+xml;charset=utf-8," then
					set strFileName to "svg-" & numInlineNO & ".svg" as text
					set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:strFileName)
					
					set AppleScript's text item delimiters to "data:image/svg+xml;charset=utf-8,"
					set listDelim to every text item of strWebPath
					set AppleScript's text item delimiters to ""
					set strInLineContents to item 2 of listDelim
					set ocidInlineContents to (refMe's NSString's stringWithString:strInLineContents)
					set ocidDencodedContents to (ocidInlineContents's stringByRemovingPercentEncoding)
					set boolDone to (ocidDencodedContents's writeToURL:ocidSaveFilePathURL atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
					
				else if strWebPath contains "data:image/svg+xml;charset=utf-8," then
					set strFileName to "svg-" & numInlineNO & ".svg" as text
					set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:strFileName)
					
					set AppleScript's text item delimiters to "data:image/svg+xml;charset=utf-8,"
					set listDelim to every text item of strWebPath
					set AppleScript's text item delimiters to ""
					set strInLineContents to item 2 of listDelim
					set ocidInlineContents to (refMe's NSString's stringWithString:strInLineContents)
					set ocidDencodedContents to (ocidInlineContents's stringByRemovingPercentEncoding)
					set boolDone to (ocidDencodedContents's writeToURL:ocidSaveFilePathURL atomically:true encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
					
				else if strWebPath contains "data:image/svg+xml;base64," then
					set strFileName to "png-" & numInlineNO & ".svg" as text
					set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:strFileName)
					
					set AppleScript's text item delimiters to "data:image/svg+xml;base64,"
					set listDelim to every text item of strWebPath
					set AppleScript's text item delimiters to ""
					set strInLineContents to item 2 of listDelim
					set ocidInlineContents to (refMe's NSString's stringWithString:strInLineContents)
					set ocidData to (refMe's NSData's alloc()'s initWithBase64EncodedString:ocidInlineContents options:(refMe's NSDataBase64DecodingIgnoreUnknownCharacters))
					set boolResults to (ocidData's writeToURL:ocidSaveFilePathURL atomically:true)
					
				else if strWebPath contains "data:image/png;base64," then
					set strFileName to "png-" & numInlineNO & ".png" as text
					set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:strFileName)
					
					set AppleScript's text item delimiters to "data:image/png;base64,"
					set listDelim to every text item of strWebPath
					set AppleScript's text item delimiters to ""
					set strInLineContents to item 2 of listDelim
					set ocidInlineContents to (refMe's NSString's stringWithString:strInLineContents)
					set ocidData to (refMe's NSData's alloc()'s initWithBase64EncodedString:ocidInlineContents options:(refMe's NSDataBase64DecodingIgnoreUnknownCharacters))
					set boolResults to (ocidData's writeToURL:ocidSaveFilePathURL atomically:true)
					
				else if strWebPath contains "data:image/jpeg;base64," then
					set strFileName to "jpg-" & numInlineNO & ".jpg" as text
					set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:strFileName)
					
					set AppleScript's text item delimiters to "data:image/jpeg;base64,"
					set listDelim to every text item of strWebPath
					set AppleScript's text item delimiters to ""
					set strInLineContents to item 2 of listDelim
					set ocidInlineContents to (refMe's NSString's stringWithString:strInLineContents)
					set ocidData to (refMe's NSData's alloc()'s initWithBase64EncodedString:ocidInlineContents options:(refMe's NSDataBase64DecodingIgnoreUnknownCharacters))
					set boolResults to (ocidData's writeToURL:ocidSaveFilePathURL atomically:true)
					
				else if strWebPath contains "data:image/jpg;base64," then
					set strFileName to "jpg-" & numInlineNO & ".jpg" as text
					set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:strFileName)
					
					set AppleScript's text item delimiters to "data:image/jpg;base64,"
					set listDelim to every text item of strWebPath
					set AppleScript's text item delimiters to ""
					set strInLineContents to item 2 of listDelim
					set ocidInlineContents to (refMe's NSString's stringWithString:strInLineContents)
					set ocidData to (refMe's NSData's alloc()'s initWithBase64EncodedString:ocidInlineContents options:(refMe's NSDataBase64DecodingIgnoreUnknownCharacters))
					set boolResults to (ocidData's writeToURL:ocidSaveFilePathURL atomically:true)
					
				else
					log "インラインイメージはとりあえず処理しない"
				end if
				set numInlineNO to numInlineNO + 1 as text
			else
				set ocidWebURL to (refMe's NSURL's alloc()'s initWithString:ocidWebPath)
				set ocidFileName to ocidWebURL's lastPathComponent()
				set strExtensionName to ocidWebURL's pathExtension() as text
				if strExtensionName is "" then
					log "拡張子がない"
					ocidFileName's stringByDeletingPathExtension()
					if strMIME contains "png" then
						set ocidFileName to (ocidFileName's stringByAppendingPathExtension:"png")
					else if strMIME contains "jpeg" then
						set ocidFileName to (ocidFileName's stringByAppendingPathExtension:"jpg")
					else if strMIME contains "jpg" then
						set ocidFileName to (ocidFileName's stringByAppendingPathExtension:"jpg")
					else if strMIME contains "webp" then
						set ocidFileName to (ocidFileName's stringByAppendingPathExtension:"webp")
					else if strMIME contains "gif" then
						set ocidFileName to (ocidFileName's stringByAppendingPathExtension:"gif")
					else if strMIME contains "svg" then
						set ocidFileName to (ocidFileName's stringByAppendingPathExtension:"svg")
					end if
				end if
				set ocidSaveFilePathURL to (ocidSaveFileDirURL's URLByAppendingPathComponent:ocidFileName)
				set ocidImageDataBase64 to (itemWebSubframeDict's objectForKey:"WebResourceData")
				
				if ocidImageDataBase64 ≠ (missing value) then
					set boolResults to (ocidImageDataBase64's writeToURL:ocidSaveFilePathURL atomically:true)
				end if
			end if
		else
			log "イメージ以外は処理しない"
		end if
		set ocidImageDataBase64 to ""
	end repeat
	
end repeat

##############################################
## 書き出し先をFinderで開く
##############################################
appShardWorkspace's openURL:ocidSaveFileDirURL



return





