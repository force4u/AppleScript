#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# 
#	
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

########################
## クリップボードの中身取り出し
###初期化
set appPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to appPasteboard's types
###テキストがあれば
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	###値を格納する
	tell application "Finder"
		set strReadString to (the clipboard as text) as text
	end tell
	###Finderでエラーしたら
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strReadString to ocidReadString as text
	else
		log "テキストなし"
		set strReadString to "入力してください" as text
	end if
end if


###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to (POSIX file "/System/Library/CoreServices/Tips.app/Contents/Resources/AppIcon.icns") as alias
set strTitle to ("入力してください") as text
set strMes to ("【英→日】翻訳します\rSafariで開きます\r") as text
set recordResult to (display dialog strMes with title strTitle default answer strReadString buttons {"キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 30 with icon aliasIconPath without hidden answer)

if (gave up of recordResult) is true then
	return "時間切れです"
else if (button returned of recordResult) is "キャンセル" then
	return "キャンセルです"
else
	set strReturnedText to (text returned of recordResult) as text
end if

set strEncText to doUrlEncode(strReturnedText)
set ocidEncText to refMe's NSString's stringWithString:(strEncText)
#############
###URL整形
set strURL to ("https://miraitranslate.com/trial/") as text
set ocidBaseURL to refMe's NSString's stringWithString:(strURL)
##
(*
auto	自動
ja	日本
en		英語
ko	韓国
zh	北京語
zt	台湾語
it	イタリア
id	インドネシア
uk	ウクライナ
es スペイン
th	タイ
de	ドイツ
fr	フランス
vi	ベトナム
pt	ポルトガル
ru	ロシア
*)
set ocidJa2EnURL to ocidBaseURL's stringByAppendingPathComponent:("#ja/en/")
set ocidEn2JaURL to ocidBaseURL's stringByAppendingPathComponent:("#en/ja/")
##
set ocidJa2EnURL to ocidJa2EnURL's stringByAppendingPathComponent:(ocidEncText)
set ocidEn2JaURL to ocidEn2JaURL's stringByAppendingPathComponent:(ocidEncText)
##
set strGetURL to ocidJa2EnURL as text
set strGetURL to ocidEn2JaURL as text

#############
###Safari
###Safariで開く
tell application "Safari" to launch
tell application "Safari"
	activate
	##ウィンドウの数を数えて
	set numCntWindow to (count of every window) as integer
	###ウィンドウがなければ
	if numCntWindow = 0 then
		###新規でウィンドウを作る
		make new document with properties {name:strReturnedText}
		tell front window
			open location strGetURL
		end tell
	else
		###ウィンドウがあるなら新規タブで開く
		tell front window
			make new tab
			tell current tab
				open location strGetURL
			end tell
		end tell
	end if
end tell

#################################
##クオテーションの置換用
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
	##テキスト形式に確定
	set strTextToEncode to ocidArgTextEncoded as text
	###値を戻す
	return strTextToEncode
end doUrlEncode


