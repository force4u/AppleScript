#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application



set strMes to ("横サイズを入力") as text

########################
## クリップボードの中身取り出し
########################
###初期化
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to ocidPasteboard's types
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
		set strReadString to "1" as text
	end if
end if
##############################
#####ダイアログ
##############################
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
set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
try
	set recordResult to (display dialog strMes with title "入力してください" default answer strReadString buttons {"OK", "キャンセル", "再実行"} default button "OK" with icon aliasIconPath giving up after 10 cancel button "キャンセル" without hidden answer) as record
on error
	log "エラーしました"
	return
end try

if "OK" is equal to (button returned of recordResult) then
	set strReturnedText to (text returned of recordResult) as text
else if (gave up of recordResult) is true then
	return "時間切れです"

end if
###自分自身を再実行
if button returned of recordResult is "再実行" then
	tell application "Finder"
		set aliasPathToMe to (path to me) as alias
	end tell
	run script aliasPathToMe
end if


##############################
#####戻り値整形
##############################
set ocidResponseText to (refMe's NSString's stringWithString:(strReturnedText))
###タブと改行を除去しておく
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidTextM's appendString:(ocidResponseText)
##改行除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\n") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\r") withString:("")
##タブ除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\t") withString:("")
####戻り値を半角にする
set ocidNSStringTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
set ocidTextM to (ocidTextM's stringByApplyingTransform:ocidNSStringTransform |reverse|:false)
##カンマ置換
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:(",") withString:(".")
###数字以外の値を取る
#set ocidDecSet to refMe's NSCharacterSet's decimalDigitCharacterSet
#set ocidCharSet to ocidDecSet's invertedSet()
#set ocidCharArray to ocidResponseHalfwidth's componentsSeparatedByCharactersInSet:ocidCharSet
#set ocidInteger to ocidCharArray's componentsJoinedByString:""
###テキストにしてから
set strTextM to ocidTextM as text
###数値に
set strResponse to strTextM as number


##############################
#####HTML部
##############################
###スタイル
set strStylle to "<style>html {font-family: \"Osaka-Mono\",monospace;font-size: 24px;} #bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 580px;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 3px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>"
###ヘッダー部
set strHead to "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>[単位換算] Aspect Ratio</title>" & strStylle & "</head><body>"
###最後
set strHtmlEndBody to "</body></html>"

###HTML書き出し用のテキスト初期化
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####bodyまでを追加
(ocidHTMLString's appendString:(strHead))
###テーブルの開始部
set strHTML to ("<div id=\"bordertable\"><table><caption>単位換算 Aspect Ratio</caption>") as text
set strHTML to (strHTML & "<thead title=\"項目名称\"><tr><th title=\"代表的な呼称\" scope=\"row\" >代表的な呼称</th><th title=\"Aspect Ratio\" scope=\"col\">縦横比</th><th title=\"横\" scope=\"col\">横</th><th title=\"縦\"  scope=\"col\">縦</th></tr></thead><tbody title=\"縦横比の表\" >") as text
##############################
#####計算部
##############################
##項目を増やす場合はこのレコードを増やせばOK
set recordAspectRatio to {|01:SXGA|:{5, 4}, |02:XGA|:{4, 3}, |03:QWUXGA|:{16, 10}, |04:WQHD|:{16, 9}, |05:Cinema|:{256, 135}} as record
set ocidAspectRatioDict to refMe's NSDictionary's alloc()'s initWithDictionary:(recordAspectRatio)
set ocidAllKeys to ocidAspectRatioDict's allKeys()
set ocidDescriptor to refMe's NSSortDescriptor's sortDescriptorWithKey:("self") ascending:(true) selector:"localizedStandardCompare:"
set ocidAllKeys to ocidAllKeys's sortedArrayUsingDescriptors:({ocidDescriptor})

repeat with itemAllKeys in ocidAllKeys
	set strAllKeys to itemAllKeys as text
	log strAllKeys
	set ocidAspectRatioArray to (ocidAspectRatioDict's objectForKey:(itemAllKeys))
	###指数取り出し
	set numRatioW to (ocidAspectRatioArray's firstObject()) as integer
	set numRatioH to (ocidAspectRatioArray's lastObject()) as integer
	
	set numRealH to ((strResponse * numRatioH) / numRatioW) as integer
	#	log numRealW
	set strAspectRatio to (numRatioW & "x" & numRatioH) as text
	set strHTML to (strHTML & "<tr><th title=\"代表的な呼称\"  scope=\"row\">" & strAllKeys & "</th><td title=\"Aspect Ratio\">" & strAspectRatio & "</td><td title=\"横\">" & strResponse & "</td><td title=\"縦\">" & numRealH & "</td></tr>") as text
end repeat

set strHTML to (strHTML & "</tbody><tfoot></tfoot></table></div>") as text
####テーブルまでを追加
(ocidHTMLString's appendString:(strHTML))
####終了部を追加
(ocidHTMLString's appendString:(strHtmlEndBody))
##############################
#####出力部
##############################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
###
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

###保存パス
set strFileName to "W2H.html" as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
####
###ファイルに書き出し
set listDone to ocidHTMLString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
####テキストエディタで開く
set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias

tell application "TextEdit"
	activate
	open file aliasFilePath
end tell


