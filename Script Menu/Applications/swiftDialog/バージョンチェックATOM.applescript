#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
githubのATOMを取得してバージョン番号を取得します

com.cocolog-nifty.quicktimer.icefloe *)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
##########################
#設定項目　
#GithubのリリースATOM
set strURL to ("https://github.com/swiftDialog/swiftDialog") as text
set strRssURL to ("" & strURL & "/releases.atom") as text

##########################
#URL
set ocidURLString to refMe's NSString's stringWithString:(strRssURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
##########################
#NSDATA
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listResponse to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidURL) options:(ocidOption) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "initWithContentsOfURL 正常処理"
	set ocidReadData to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	set strErrorNO to (item 2 of listResponse)'s code() as text
	set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
	refMe's NSLog("■：" & strErrorNO & strErrorMes)
	return "initWithContentsOfURL エラーしました" & strErrorNO & strErrorMes
end if
##########################
#NSXML
set ocidOption to (refMe's NSXMLDocumentTidyXML)
set listResponse to refMe's NSXMLDocument's alloc()'s initWithData:(ocidReadData) options:(ocidOption) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "initWithData 正常処理"
	set ocidReadXML to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	set strErrorNO to (item 2 of listResponse)'s code() as text
	set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
	refMe's NSLog("■：" & strErrorNO & strErrorMes)
	return "initWithData エラーしました" & strErrorNO & strErrorMes
end if
##########################
#バージョン取得 linkのURLを使う
set ocidRootElement to ocidReadXML's rootElement()
#リンクの最初の項目が最新
set listResponse to (ocidRootElement's nodesForXPath:("//entry/link/@href") |error|:(reference))
set ocidLinkNode to (item 1 of listResponse)'s firstObject()'s stringValue()
set ocidLinkURL to refMe's NSURL's alloc()'s initWithString:(ocidLinkNode)
set ocidVerNo to ocidLinkURL's lastPathComponent()
set ocidVerNo to (ocidVerNo's stringByReplacingOccurrencesOfString:("v") withString:(""))
set strVerNo to ocidVerNo as text

return strVerNo