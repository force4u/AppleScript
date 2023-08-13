#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

###################################
#####ダイアログ
###################################a
###デフォルトロケーション
set ocidForDirArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidForDirArray's firstObject()
set aliasDefaultLocation to (ocidDesktopPathURL's absoluteURL()) as alias

set listChooseFileUTI to {"com.apple.web-internet-location", "com.microsoft.internet-shortcut"}

set strPromptText to "URLリンクファイルを選んでください" as text
set strMesText to "URLリンクファイルを選んでください" as text


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
set listAliasFilePath to (choose file strMesText with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI without multiple selections allowed, invisibles and showing package contents) as list

###################################
#####パス処理
###################################
set aliasFilePath to item 1 of listAliasFilePath as alias
set strFilePath to POSIX path of aliasFilePath as text
set ocidFilePathstr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathstr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false
####ファイル名を取得
set ocidFileName to ocidFilePathURL's lastPathComponent()
####拡張子を取得
set ocidFileExtension to ocidFilePathURL's pathExtension()
set strFileExtension to ocidFileExtension as text

###################################
#####アイコン取得　URL
###################################
if strFileExtension is "webloc" then
	set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL)
	set ocidURLStr to ocidPlistDict's valueForKey:("URL")
else if strFileExtension is "url" then
	set listContentsStrings to refMe's NSString's stringWithContentsOfURL:(ocidFilePathURL) usedEncoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
	set ocidContentsStrings to (item 1 of listContentsStrings)
	set ocidContentsArray to ocidContentsStrings's componentsSeparatedByString:("\r\n")
	set ocidLineStrings to ocidContentsArray's objectAtIndex:(1)
	set ocidURLStr to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
	ocidURLStr's setString:(ocidLineStrings)
	set ocidLength to ocidURLStr's |length|()
	set ocidRange to refMe's NSMakeRange(0, ocidLength)
	set ocidOption to (refMe's NSCaseInsensitiveSearch)
	ocidURLStr's replaceOccurrencesOfString:("URL=") withString:("") options:(ocidOption) range:(ocidRange)
else
	return "対象外です"
end if

###################################
#####favicon.ico アイコン取得　
###################################
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLStr)
set ocidHostName to ocidURL's |host|()
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
ocidURLComponents's setScheme:("https")
ocidURLComponents's setHost:(ocidHostName)
ocidURLComponents's setPath:("/favicon.ico")
set ocidFaviconURL to ocidURLComponents's |URL|()
set ocidURLRequest to refMe's NSMutableURLRequest's requestWithURL:(ocidFaviconURL)
ocidURLRequest's setHTTPMethod:"GET"
set listResponse to refMe's NSURLConnection's sendSynchronousRequest:(ocidURLRequest) returningResponse:(reference) |error|:(reference)
set ocidHTTPURLResponse to (item 2 of listResponse)
set strStatusCode to ocidHTTPURLResponse's statusCode() as text
if strStatusCode = "200" then
	log "favicon.icoデータ取得"
	set ocidIconData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidFaviconURL))
else
	###################################
	#####LINKタグを検索
	###################################
	set ocidHTMLStrings to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
	set listHTMLStrings to refMe's NSString's stringWithContentsOfURL:(ocidURL) usedEncoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
	ocidHTMLStrings's setString:(item 1 of listHTMLStrings)
	
	set ocidLength to ocidHTMLStrings's |length|()
	set ocidRange to refMe's NSMakeRange(0, ocidLength)
	set ocidOption to (refMe's NSCaseInsensitiveSearch)
	ocidHTMLStrings's replaceOccurrencesOfString:("\r") withString:("") options:(ocidOption) range:(ocidRange)
	set ocidLength to ocidHTMLStrings's |length|()
	set ocidRange to refMe's NSMakeRange(0, ocidLength)
	ocidHTMLStrings's replaceOccurrencesOfString:("\n") withString:("") options:(ocidOption) range:(ocidRange)
	set ocidLength to ocidHTMLStrings's |length|()
	set ocidRange to refMe's NSMakeRange(0, ocidLength)
	ocidHTMLStrings's replaceOccurrencesOfString:("\t") withString:("") options:(ocidOption) range:(ocidRange)
	set ocidLength to ocidHTMLStrings's |length|()
	set ocidRange to refMe's NSMakeRange(0, ocidLength)
	ocidHTMLStrings's replaceOccurrencesOfString:("><") withString:(">\n<") options:(ocidOption) range:(ocidRange)
	set ocidHTMLArray to ocidHTMLStrings's componentsSeparatedByString:("\n")
	set strHTMLLineStrings to (missing value)
	repeat with itemHTMLArray in ocidHTMLArray
		set strHTMLArray to itemHTMLArray as text
		if strHTMLArray contains "<body" then
			exit repeat
		else if strHTMLArray contains "apple-touch-icon" then
			set strHTMLLineStrings to strHTMLArray
		else if strHTMLArray contains "icon" then
			set strHTMLLineStrings to strHTMLArray
		end if
	end repeat
	if strHTMLLineStrings is (missing value) then
		return "アイコンデータ無し"
	else
		set ocidHREFStrings to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
		ocidHREFStrings's setString:(strHTMLLineStrings)
		log strHTMLLineStrings
		set ocidOption to (refMe's NSRegularExpressionCaseInsensitive)
		set strRegPattern to ("href=\"([^\\\"]+)\"")
		set listRegex to refMe's NSRegularExpression's regularExpressionWithPattern:(strRegPattern) options:(ocidOption) |error|:(reference)
		set ocidRegex to (item 1 of listRegex)
		set ocidLength to ocidHREFStrings's |length|()
		set ocidRange to refMe's NSMakeRange(0, ocidLength)
		set ocidMach to ocidRegex's firstMatchInString:(ocidHREFStrings) options:0 range:(ocidRange)
		set ocidHrefValue to ocidHREFStrings's substringWithRange:(ocidMach's rangeAtIndex:1)
		set ocidHrefValueStr to refMe's NSString's stringWithString:(ocidHrefValue)
		###hrefがパス指定の場合の分岐
		set boolScheme to ocidHrefValueStr's hasPrefix:("https")
		if boolScheme is true then
			set ocidFaviconURL to refMe's NSURL's alloc()'s initWithString:(ocidHrefValueStr)
		else
			set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
			ocidURLComponents's setScheme:("https")
			ocidURLComponents's setHost:(ocidHostName)
			ocidURLComponents's setPath:(ocidHrefValueStr)
			set ocidFaviconURL to ocidURLComponents's |URL|()
		end if
		set ocidIconData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidFaviconURL))
		
	end if
	
end if
###################################
####アイコン付与
###################################
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolAddIcon to appSharedWorkspace's setIcon:(ocidIconData) forFile:(ocidFilePathURL's |path|) options:(refMe's NSExclude10_4ElementsIconCreationOption)


