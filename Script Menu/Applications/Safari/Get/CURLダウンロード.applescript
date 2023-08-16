#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# サファリ用　SafariのデベロッパーツールからのCURLsコピー用
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

##############################
###クリックボードの中のURLを取得
##############################
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
###クリックボードの中のURLを取得
set ocidPasteboardTypeString to ocidPasteboard's stringForType:(refMe's NSPasteboardTypeString)
##可変テキスト形式で格納
set ocidCurlURL to refMe's NSMutableString's alloc()'s initWithCapacity:0
ocidCurlURL's setString:ocidPasteboardTypeString
##CURLでコピーしているか？を判断
if (ocidCurlURL as text) starts with "curl" then
	log "処理開始"
	###サブルーチンに値を渡す
	set ocidDoSeparateURLArrayM to doSeparateURL(ocidCurlURL)
else
	return "CURLとしてコピーしてください"
end if
###サブルーチンからの戻り値を分割
set strURLwithQuery to (item 1 of ocidDoSeparateURLArrayM)'s absoluteString() as text
set ocidURL to (item 2 of ocidDoSeparateURLArrayM)
##ファイル名
set ocidFileName to ocidURL's lastPathComponent()
set strURL to ocidURL's absoluteString() as text
set strQuery to (item 3 of ocidDoSeparateURLArrayM) as text
set strHeader to (item 4 of ocidDoSeparateURLArrayM) as text

###ファイル保存先
set ocidUserDownloadsPath to (appFileManager's URLsForDirectory:(refMe's NSDownloadsDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDownLoadFolderPath to item 1 of ocidUserDownloadsPath
###ファイル名は同じにする
set ocidFilePathURL to ocidDownLoadFolderPath's URLByAppendingPathComponent:ocidFileName isDirectory:false
###保存先パス
set strFilePath to ocidFilePathURL's |path|() as text
###コマンド整形
set strCommandText to "/usr/bin/curl  '" & strURLwithQuery & "' -o '" & strFilePath & "' " & strHeader & "" as text
log strCommandText
###実行
try
	set strResponse to (do shell script strCommandText) as text
on error
	log strResponse
	return strResponse
end try


##############################
###CURLコピーの内容を分割　SAFARI用
(*
戻り値のocidDoSeparateURLArrayMは
{クエリー付きURL、URLのみ、クエリーのみ、ヘッダーのみ}
の形式で戻される
*)
##############################
to doSeparateURL(argCurlURL)
	###戻り値用のリスト
	set ocidDoSeparateURLArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:0
	###『'』でリスト化して２番目がURL
	set ocidDelimiters to (refMe's NSCharacterSet)'s characterSetWithCharactersInString:"'"
	set ocidCurlURLArray to argCurlURL's componentsSeparatedByCharactersInSet:ocidDelimiters
	###URL確定(クエリー入り)
	set ocidURLString to ocidCurlURLArray's objectAtIndex:1
	set ocidURL to refMe's NSURL's URLWithString:(ocidURLString)
	ocidDoSeparateURLArrayM's addObject:(ocidURL)
	
	###URL部分（クエリー無し）
	set ocidURLComponents to refMe's NSURLComponents's componentsWithURL:(ocidURL) resolvingAgainstBaseURL:true
	ocidURLComponents's setQueryItems:(missing value)
	set ocidBaseURL to ocidURLComponents's |URL|
	ocidDoSeparateURLArrayM's addObject:(ocidBaseURL)
	
	###クエリー部分
	set ocidQueryName to ocidURL's query()
	#log ocidQueryName as text
	if ocidQueryName is missing value then
		ocidDoSeparateURLArrayM's addObject:""
	else
		ocidDoSeparateURLArrayM's addObject:(ocidQueryName)
	end if
	
	###ヘッダー部処理
	###改行を取る
	set ocidCurlURLLength to argCurlURL's |length|()
	set ocidCurlURLRange to refMe's NSMakeRange(0, ocidCurlURLLength)
	set ocidOption to refMe's NSCaseInsensitiveSearch
	argCurlURL's replaceOccurrencesOfString:("\\n") withString:("") options:(ocidOption) range:(ocidCurlURLRange)
	##置換
	set ocidCurlURLLength to argCurlURL's |length|()
	set ocidCurlURLRange to refMe's NSMakeRange(0, ocidCurlURLLength)
	set ocidOption to refMe's NSCaseInsensitiveSearch
	argCurlURL's replaceOccurrencesOfString:("\n") withString:("") options:(ocidOption) range:(ocidCurlURLRange)
	##置換
	set ocidCurlURLLength to argCurlURL's |length|()
	set ocidCurlURLRange to refMe's NSMakeRange(0, ocidCurlURLLength)
	set ocidOption to refMe's NSCaseInsensitiveSearch
	argCurlURL's replaceOccurrencesOfString:("\\") withString:("") options:(ocidOption) range:(ocidCurlURLRange)
	##スペース区切りでARRAYに
	set ocidDelimiters to refMe's NSCharacterSet's characterSetWithCharactersInString:" "
	set ocidHeaderArray to argCurlURL's componentsSeparatedByCharactersInSet:(ocidDelimiters)
	##CURL部削除
	ocidHeaderArray's removeObjectAtIndex:0
	###URL部削除
	ocidHeaderArray's removeObjectAtIndex:0
	###残りがヘッダー
	set ocidHeaderText to ocidHeaderArray's componentsJoinedByString:(" ")
	
	ocidDoSeparateURLArrayM's addObject:ocidHeaderText
	###値を戻す
	return ocidDoSeparateURLArrayM
	
end doSeparateURL




