#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#  com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

set strBundleID to "com.microsoft.edgemac" as text

property refMe : a reference to current application

####ペーストボード初期化
set appPasteboard to refMe's NSPasteboard's generalPasteboard()
appPasteboard's clearContents()

#####WINDOWチェック
tell application id strBundleID
	set numCntWindow to (count of every window) as integer
	if numCntWindow = 0 then
		return "ウィンドウがありません"
	end if
end tell
#####
tell application "Microsoft Edge"
	tell front window
		tell active tab
			activate
			copy selection
		end tell
	end tell
end tell
###ペーストボード格納待ち
delay 0.1
####ペーストボード取得
set ocidPastBoardTypeArray to appPasteboard's types()
log ocidPastBoardTypeArray as list
if (count of ocidPastBoardTypeArray) = 0 then
	display alert "選択範囲がありませんでした"
	return "選択範囲がありませんでした"
end if
if (ocidPastBoardTypeArray as list) contains "NSStringPboardType" then
	###ペーストボードの中身をテキストで確定
	set ocidSelectionText to appPasteboard's stringForType:(refMe's NSStringPboardType)
else if (ocidPastBoardTypeArray as list) contains "public.utf8-plain-text" then
	set ocidSelectionText to appPasteboard's stringForType:("public.utf8-plain-text")
end if
set boolSuffix to ocidSelectionText's hasSuffix:("\n")
if boolSuffix = true then
	set numTextLengh to (ocidSelectionText's |length|()) as integer
	set ocidSelectionText to ocidSelectionText's substringToIndex:(numTextLengh - 1)
end if
set boolSuffix to ocidSelectionText's hasSuffix:("\n")
if boolSuffix = true then
	set numTextLengh to (ocidSelectionText's |length|()) as integer
	set ocidSelectionText to ocidSelectionText's substringToIndex:(numTextLengh - 1)
end if

set strSelectionText to ocidSelectionText as text
set strSelectionText to ("❝" & strSelectionText & "❞") as text

########################
tell application "Microsoft Edge"
	activate
	tell front window
		tell active tab
			set strURL to URL as text
			set strName to title as text
		end tell
	end tell
end tell



####################
###
set ocidTitleString to refMe's NSString's stringWithString:(strName)
set numTitleLengh to ocidTitleString's |length|() as integer
if numTitleLengh > 52 then
	set ocidRange to refMe's NSMakeRange(0, 50)
	set ocidTitle to ocidTitleString's substringWithRange:(ocidRange)
	set strTitle to ((ocidTitle as text) & "…") as text
else
	set ocidRange to refMe's NSMakeRange(0, numTitleLengh)
	set ocidTitle to ocidTitleString's substringWithRange:(ocidRange)
	set strTitle to ocidTitle as text
end if

####################
###ホスト名
set ocidURLString to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
set strURL to ocidURL's absoluteString() as text
set strHostName to ocidURL's |host|() as text
set ocidComponents to refMe's NSURLComponents's componentsWithURL:(ocidURL) resolvingAgainstBaseURL:(true)
ocidComponents's setQuery:(missing value)
ocidComponents's setFragment:(missing value)
set strURL to ocidComponents's |URL|'s absoluteString() as text
####################
###URLデコード
set strDecodeURL to doUrlDecode(strURL) as text
set strDecodeURL to doReplace(strDecodeURL, "https://", "")
set strDecodeURL to doReplace(strDecodeURL, "http://", "")
####################
set ocidDate to refMe's NSDate's now()
###日付
set ocidFormatter to refMe's NSDateFormatter's alloc()'s init()
set ocidLocale to refMe's NSLocale's currentLocale
ocidFormatter's setLocale:(ocidLocale)
###時間表示無し
ocidFormatter's setTimeStyle:(refMe's NSDateFormatterNoStyle)
ocidFormatter's setDateStyle:(refMe's NSDateFormatterLongStyle)
set ocidDateString to ocidFormatter's stringFromDate:(ocidDate)
set strDateString to ocidDateString as text

##set strQuoteText to ("\n--\n" & strSelectionText & "\r" & strTitle & "\r[" & strDecodeURL & "]\r引用元:[" & strHostName & "] アクセス日：" & strDateString) as text

set strQuoteText to ("\n--\n" & strSelectionText & "\r" & strTitle & "\r引用元:[" & strHostName & "] アクセス日：" & strDateString) as text

###エンコードして
set strCurrentTabUrl to doUrlEncode(strURL) as text
set strCurrentTabTitle to doUrlEncode(strQuoteText) as text
###送信用URLに整形して
set strBaseUrl to "https://twitter.com/intent/tweet?" as text
set strOpenUrl to ("" & strBaseUrl & "url=" & strCurrentTabUrl & "&text=" & strCurrentTabTitle & "") as text
###Edgeに渡す
tell application "Microsoft Edge"
	activate
	tell front window
		set objNewTab to make new tab
		tell objNewTab to set URL to strOpenUrl
	end tell
end tell

################################
## %エンコードをデコード
################################
on doUrlDecode(argText)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##デコード
	set ocidArgTextEncoded to ocidArgText's stringByRemovingPercentEncoding
	set strArgTextEncoded to ocidArgTextEncoded as text
	return strArgTextEncoded
end doUrlDecode

####################################
###### 置換
####################################

to doReplace(argOrignalText, argSearchText, argReplaceText)
	set strDelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to argSearchText
	set listDelim to every text item of argOrignalText
	set AppleScript's text item delimiters to argReplaceText
	set strReturn to listDelim as text
	set AppleScript's text item delimiters to strDelim
	return strReturn
end doReplace

####################################
###### ％エンコード
####################################
on doUrlEncode(argText)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##キャラクタセットを指定
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	##キャラクタセットで変換
	set ocidArgTextEncoded to ocidArgText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	######## 置換　％エンコードの追加処理
	###置換レコード
	set recordPercentMap to {|+|:"%2B", |=|:"%3D", |&|:"%26", |$|:"%24"} as record
	###ディクショナリにして
	set ocidPercentMap to refMe's NSDictionary's alloc()'s initWithDictionary:(recordPercentMap)
	###キーの一覧を取り出します
	set ocidAllKeys to ocidPercentMap's allKeys()
	###取り出したキー一覧を順番に処理
	repeat with itemAllKey in ocidAllKeys
		##キーの値を取り出して
		set ocidMapValue to (ocidPercentMap's valueForKey:(itemAllKey))
		##置換
		set ocidEncodedText to (ocidArgTextEncoded's stringByReplacingOccurrencesOfString:(itemAllKey) withString:(ocidMapValue))
		##次の変換に備える
		set ocidArgTextEncoded to ocidEncodedText
	end repeat
	##テキスト形式に確定
	set strTextToEncode to ocidEncodedText as text
	###値を戻す
	return strTextToEncode
end doUrlEncode
