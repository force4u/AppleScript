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

on run {argText}
	
	repeat with itemText in argText
		set ocidText to (refMe's NSString's stringWithString:(itemText))
		###NSURLを使わないのでクエリー用に％エンコードしておく
		set strEncText to doUrlEncode(ocidText)
		set ocidEncText to (refMe's NSString's stringWithString:(strEncText))
		###########################
		###URL整形
		set strURL to ("https://miraitranslate.com/trial/") as text
		set ocidBaseURL to (refMe's NSString's stringWithString:(strURL))
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
		
		
		###########################
		###【日本語判定】大まかな日本語陵域
		set ocidPattern to (refMe's NSString's stringWithString:("[ぁ-んァ-ン一-鿿]+"))
		###正規表現を定義↑のパターンでセット
		set listRegex to (refMe's NSRegularExpression's regularExpressionWithPattern:(ocidPattern) options:(0) |error|:(reference))
		##error referenceしているので戻り値はリストだから
		set ocidRegex to (item 1 of listRegex)
		###入力文字列のレンジ
		set ocidImputRange to refMe's NSMakeRange(0, ocidText's |length|())
		###文字列の中に正規表現が最初に当てはまるレンジは？
		set ocidRange to (ocidRegex's rangeOfFirstMatchInString:(ocidText) options:0 range:(ocidImputRange))
		###レンジのロケーションを取り出して
		set ocidLocation to ocidRange's location()
		##NSNotFoundなら
		if ocidLocation = refNSNotFound then
			log "日本語を含みません　日本語に翻訳します"
			##
			set ocidEncBaseURL to (ocidBaseURL's stringByAppendingPathComponent:("#en/ja/"))
		else
			###あるなら
			set ocidEncBaseURL to (ocidBaseURL's stringByAppendingPathComponent:("#ja/en/"))
			
		end if
		###########################
		###
		set ocidGetURL to (ocidEncBaseURL's stringByAppendingPathComponent:(ocidEncText))
		set strGetURL to ocidGetURL as text
		
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
		
	end repeat
end run



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
