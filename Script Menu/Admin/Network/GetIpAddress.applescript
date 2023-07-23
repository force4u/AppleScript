#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


####################################
######Macアドレス取得
###コマンド生成　実行
set strCommandText to "/usr/sbin/networksetup  -listallnetworkservices"
set strResults to (do shell script strCommandText) as text
###戻り値を改行でリストに
set ocidListallnetworkservices to refMe's NSString's stringWithString:(strResults)
set ocidChrSet to refMe's NSCharacterSet's characterSetWithCharactersInString:("\r")
set ocidNetworkNameArray to ocidListallnetworkservices's componentsSeparatedByCharactersInSet:(ocidChrSet)
(ocidNetworkNameArray's removeObjectAtIndex:(0))
set strMacAdd to "" as text
repeat with itemNetworkName in ocidNetworkNameArray
	set strServiceName to itemNetworkName as text
	###コマンド生成　実行
	set strCommandText to "/usr/sbin/networksetup  -getinfo \"" & strServiceName & "\"" as text
	set strResponse to (do shell script strCommandText) as text
	###戻り値を改行でリストに
	set ocidResponse to (refMe's NSString's stringWithString:(strResponse))
	set ocidChrSet to (refMe's NSCharacterSet's characterSetWithCharactersInString:("\r"))
	set ocidResponseArray to (ocidResponse's componentsSeparatedByCharactersInSet:(ocidChrSet))
	###Macアドレスだけ取得
	repeat with itemResponse in ocidResponseArray
		set strResponse to itemResponse as text
		if strResponse contains "Wi-Fi ID" then
			set strMacAdd to strServiceName & "：" & strResponse & "\r" & strMacAdd as text
		else if strResponse contains "Ethernet Address" then
			set strMacAdd to strServiceName & "：" & strResponse & "\r" & strMacAdd as text
		end if
	end repeat
end repeat

####################################
######　IPアドレス取得
set strURL to "https://www.cloudflare.com/cdn-cgi/trace?json" as text
set ocidURL to refMe's NSURL's URLWithString:(strURL)
###URLをリクエスト
set listContents to refMe's NSString's stringWithContentsOfURL:(ocidURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
set ocidContents to item 1 of listContents
###改行で
set ocidCharacterSet to refMe's NSCharacterSet's newlineCharacterSet
###リスト化して
set ocidStringArray to ocidContents's componentsSeparatedByCharactersInSet:(ocidCharacterSet)
###IPアドレスを取得
repeat with itemStringArray in ocidStringArray
	if (itemStringArray as text) starts with "ip" then
		set ocidIPArray to (itemStringArray's componentsSeparatedByString:"=")
		set ocidIPAdd to (ocidIPArray's objectAtIndex:1)
	end if
end repeat
###正順　IPアドレス
set strIPAdd to ocidIPAdd as text
set ocidIpAddArray to ocidIPAdd's componentsSeparatedByString:(".")
set ocidIpAddArrayRev to (ocidIpAddArray's reverseObjectEnumerator())'s allObjects()
###逆順 IPアドレス
set strIPAddRev to (ocidIpAddArrayRev's componentsJoinedByString:(".")) as text
####################################
###### URL部分
set strURLrev to ("https://cloudflare-dns.com/dns-query?name=" & strIPAddRev & ".in-addr.arpa&type=PTR") as text
set ocidURLrevStr to refMe's NSString's stringWithString:(strURLrev)
set ocidURLrevURL to refMe's NSURL's URLWithString:(ocidURLrevStr)
####################################
###### URLRequest部分
set ocidURLRequest to refMe's NSMutableURLRequest's alloc()'s init()
ocidURLRequest's setHTTPMethod:("GET")
ocidURLRequest's setURL:(ocidURLrevURL)
ocidURLRequest's addValue:("application/json") forHTTPHeaderField:("Content-Type")
ocidURLRequest's addValue:("application/dns-json") forHTTPHeaderField:("accept")
################################################
repeat 5 times
	###### データ取得
	set listServerResponse to refMe's NSURLConnection's sendSynchronousRequest:(ocidURLRequest) returningResponse:(missing value) |error|:(reference)
	###取得JSONデータ 
	set ocidJsonResponse to (item 1 of listServerResponse)
	####取得データをJSONで確定
	set listJsonData to refMe's NSJSONSerialization's JSONObjectWithData:ocidJsonResponse options:(refMe's NSJSONReadingMutableContainers) |error|:(reference)
	set ocidJsonData to (item 1 of listJsonData)
	####レコードに格納
	set ocidJsonDict to refMe's NSDictionary's alloc()'s initWithDictionary:(ocidJsonData)
	set numStatus to (ocidJsonDict's valueForKey:("Status")) as integer
	if numStatus = 0 then
		set ocidRevHost to (ocidJsonDict's valueForKey:("Question"))'s valueForKey:("name")
		set strRevHost to ocidRevHost as text
		exit repeat
	else
		delay 1
	end if
end repeat
if numStatus ≠ 0 then
	display alert "データの取得に失敗しました" giving up after 3
	return "データの取得に失敗しました"
end if
###ホスト名解決
set strCommandText to ("/usr/bin/dig -x " & strIPAdd & " +short")
set strHostName to (do shell script strCommandText) as text

set strCommandText to ("/sbin/ifconfig | grep \"inet.*broadcast\" |  awk '{print $2}'") as text
set strLocalIP to (do shell script strCommandText) as text

set strAns to ("ホスト名：" & strHostName & "\rグローバルIP：" & strIPAdd & "\r逆引き：" & strRevHost & "\rローカルIP：" & strLocalIP & "\r" & strMacAdd) as text
####################################
######ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
####################################
######ダイアログ

set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns" as alias
try
	set recordResponse to (display dialog strAns with title "IPアドレス" default answer strAns buttons {"クリップボードにコピー", "OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
on error
	log "エラーしました"
	return "エラーしました"
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else if button returned of recordResponse is "クリップボードにコピー" then
	set strText to text returned of recordResponse as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	##結果をペーストボードにテキストで入れる
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	return strText
else
	log "キャンセルしました"
	return "キャンセルしました" & strText
end if



