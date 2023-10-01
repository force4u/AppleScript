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
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807

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
set strMes to ("【日英判定】翻訳します\rSafariで開きます\r") as text
set recordResult to (display dialog strMes with title strTitle default answer strReadString buttons {"キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 30 with icon aliasIconPath without hidden answer)

if (gave up of recordResult) is true then
	return "時間切れです"
else if (button returned of recordResult) is "キャンセル" then
	return "キャンセルです"
else
	set strReturnedText to (text returned of recordResult) as text
end if
set ocidText to refMe's NSString's stringWithString:(strReturnedText)
###########################
###URL整形 URLコンポーネントを使う
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
##スキームとホスト
ocidURLComponents's setScheme:("https")
ocidURLComponents's setHost:("translate.google.com")
##クエリーアイテムにセットするArray
set ocidQueryItemArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0

###########################
###【日本語判定】大まかな日本語陵域
set ocidPattern to refMe's NSString's stringWithString:("[ぁ-んァ-ン一-鿿]+")
###正規表現を定義↑のパターンでセット
set listRegex to refMe's NSRegularExpression's regularExpressionWithPattern:(ocidPattern) options:(0) |error|:(reference)
##error referenceしているので戻り値はリストだから
set ocidRegex to (item 1 of listRegex)
###入力文字列のレンジ
set ocidImputRange to refMe's NSMakeRange(0, ocidText's |length|())
###文字列の中に正規表現が最初に当てはまるレンジは？
set ocidRange to ocidRegex's rangeOfFirstMatchInString:(ocidText) options:0 range:(ocidImputRange)
###レンジのロケーションを取り出して
set ocidLocation to ocidRange's location()
##NSNotFoundなら
if ocidLocation = refNSNotFound then
	log "日本語を含みません　日本語に翻訳します"
	##元テキスト　autoも可
	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("sl") value:("en")
	ocidQueryItemArray's addObject:(ocidQueryItem)
	##翻訳後の言語
	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("tl") value:("ja")
	ocidQueryItemArray's addObject:(ocidQueryItem)
	##ユーザーインターフェイスの言語 USで英語 JP で日本語
	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("hl") value:("us")
	ocidQueryItemArray's addObject:(ocidQueryItem)
	
else
	###あるなら
	log "日本語を含みます 英語に翻訳します"
	##元テキスト　autoも可
	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("sl") value:("ja")
	ocidQueryItemArray's addObject:(ocidQueryItem)
	##翻訳後の言語
	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("tl") value:("en")
	ocidQueryItemArray's addObject:(ocidQueryItem)
	##ユーザーインターフェイスの言語 USで英語 JP で日本語
	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("hl") value:("jp")
	ocidQueryItemArray's addObject:(ocidQueryItem)
	
end if
###########################
###言語に影響ないクエリーの残り
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("op") value:("translate")
ocidQueryItemArray's addObject:(ocidQueryItem)
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("text") value:(strReturnedText)
ocidQueryItemArray's addObject:(ocidQueryItem)
##全てのクエリーをセット
ocidURLComponents's setQueryItems:(ocidQueryItemArray)
###URLに
set ocidURL to ocidURLComponents's |URL|
set strGetURL to ocidURL's absoluteString() as text

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


