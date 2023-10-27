#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# https://apps.apple.com/us/genre/ios/id36
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set strBundleID to "com.apple.Safari" as text
################################
tell application "Safari"
	set numCntWindow to (count of every window) as integer
	if numCntWindow = 0 then
		return "ウィンドウがありません"
	end if
end tell

###サファリの最前面のURL
tell application "Safari"
	set numID to id of front window
	set objTab to current tab of window id numID
	tell window id numID
		tell objTab
			set strURL to URL
		end tell
	end tell
end tell
################################
set strURL to strURL as text
set ocidURLString to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
###
set strHostName to ocidURL's |host|() as text
if strHostName is not "apps.apple.com" then
	set strOpenURL to "https://apps.apple.com/us/genre/ios/id36"
	tell application "Safari"
		open location strOpenURL
	end tell
	return "ID取得出来ません"
end if
###ラストパス から　デベロッパIDを取得する
set strLastPath to (ocidURL's lastPathComponent()) as text
set ocidLastPath to refMe's NSString's stringWithString:(strLastPath)
set ocidID to ocidLastPath's stringByReplacingOccurrencesOfString:("id") withString:("")
set strIDno to ocidID as text

###データ取得用のURLに整形
set strLookupURL to ("https://itunes.apple.com/lookup?id=" & strIDno & "") as text
set ocidLookup to refMe's NSString's stringWithString:(strLookupURL)
set ocidLookupURL to refMe's NSURL's alloc()'s initWithString:(ocidLookup)
log ocidLookupURL's absoluteString() as text
####JSON
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidLookupURL) options:(refMe's NSDataReadingMappedIfSafe) |error|:(reference)
set coidReadData to item 1 of listReadData
###NSJSONSerialization
set listJSONSerialization to (refMe's NSJSONSerialization's JSONObjectWithData:(coidReadData) options:(refMe's NSJSONReadingMutableContainers) |error|:(reference))
set ocidJsonData to item 1 of listJSONSerialization
###
set ocidJsonDict to refMe's NSDictionary's alloc()'s initWithDictionary:(ocidJsonData)
set ocidResultsArray to ocidJsonDict's valueForKey:("results")
set ocidResultsDict to ocidResultsArray's firstObject()
## 	set listKeys to ocidResultsDict's allKeys()
set listKeys to {"primaryGenreName", "artworkUrl100", "currency", "sellerUrl", "artworkUrl512", "ipadScreenshotUrls", "fileSizeBytes", "genres", "languageCodesISO2A", "artworkUrl60", "supportedDevices", "trackViewUrl", "description", "bundleId", "version", "artistViewUrl", "userRatingCountForCurrentVersion", "isGameCenterEnabled", "appletvScreenshotUrls", "genreIds", "averageUserRatingForCurrentVersion", "releaseDate", "trackId", "wrapperType", "minimumOsVersion", "formattedPrice", "primaryGenreId", "currentVersionReleaseDate", "userRatingCount", "artistId", "trackContentRating", "artistName", "price", "trackCensoredName", "trackName", "kind", "features", "contentAdvisoryRating", "screenshotUrls", "releaseNotes", "isVppDeviceBasedLicensingEnabled", "sellerName", "averageUserRating", "advisories"} as list

repeat with itemKey in listKeys
	log (ocidResultsDict's valueForKey:(itemKey))
end repeat
set strTrackIName to (ocidResultsDict's valueForKey:("trackName")) as text
set strTrackId to (ocidResultsDict's valueForKey:("trackId")) as text
set strBundleID to (ocidResultsDict's valueForKey:("bundleId")) as text
set strVersion to (ocidResultsDict's valueForKey:("version")) as text
set strArtistId to (ocidResultsDict's valueForKey:("artistId")) as text
set strArtistName to (ocidResultsDict's valueForKey:("artistName")) as text

set strDefaultAnser to ("trackName: " & strTrackIName & "\r") as text
set strDefaultAnser to strDefaultAnser & ("trackId: " & strTrackId & "\r") as text
set strDefaultAnser to strDefaultAnser & ("bundleId: " & strBundleID & "\r") as text
set strDefaultAnser to strDefaultAnser & ("version: " & strVersion & "\r") as text
set strDefaultAnser to strDefaultAnser & ("artistId: " & strArtistId & "\r") as text
set strDefaultAnser to strDefaultAnser & ("artistName: " & strArtistName & "\r") as text


###ダイアログを出して
set aliasIconPath to POSIX file "/System/Applications/App Store.app/Contents/Resources/AppIcon.icns" as alias
set theResponse to 2 as number
try
	set recordResult to (display dialog "アプリ情報" with title "詳細情報" default answer strDefaultAnser buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
on error
	log "エラーしました"
	return
end try
if true is equal to (gave up of recordResult) then
	return "時間切れですやりなおしてください"
end if
if "OK" is equal to (button returned of recordResult) then
	set strResponse to (text returned of recordResult) as text
end if


###クリップボードコピー
if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if
