#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#PlistのValue値を検索する
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807

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
set strMes to ("検索語句　市区町村関連") as text
set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
try
	set recordResult to (display dialog strMes with title "入力してください" default answer strReadString buttons {"OK", "キャンセル"} default button "OK" with icon aliasIconPath giving up after 10 without hidden answer) as record
on error
	log "エラーしました"
	return
end try

if "OK" is equal to (button returned of recordResult) then
	set strReturnedText to (text returned of recordResult) as text
else if (gave up of recordResult) is true then
	return "時間切れです"
else
	return "キャンセル"
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
##########################################
###【１】ドキュメントのパスをNSString
tell application "Finder"
	set aliasPathToMe to (path to me) as alias
end tell
set strPathToMe to (POSIX path of aliasPathToMe) as text
set ocidPathToMeStr to refMe's NSString's stringWithString:(strPathToMe)
set ocidPathToMe to ocidPathToMeStr's stringByStandardizingPath()
set ocidPathToMeURL to refMe's NSURL's fileURLWithPath:(ocidPathToMe)
set ocidPathToMeContainerDirURL to ocidPathToMeURL's URLByDeletingLastPathComponent()
set ocidFilePathURL to ocidPathToMeContainerDirURL's URLByAppendingPathComponent:("data/PrefecturesData.plist")
##########################################
###【２】PLISTを可変レコードとして読み込み
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL)
###データをArrayで取り出して
set ocidDataArray to ocidPlistDict's objectForKey:("data")
###
set ocidOutPutArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
###dataのarrayの数だけ繰り返し
repeat with itemDataDict in ocidDataArray
	##dataArrayのItemはDictなのでValueを取って
	set ocidAllValueKey to itemDataDict's allValues()
	##検索用に文字列にして
	set ocidAllValueStr to (ocidAllValueKey's componentsJoinedByString:(","))
	##検索してレンジを求める
	set ocidOption to (refMe's NSCaseInsensitiveSearch)
	set ocidLocation to (ocidAllValueStr's rangeOfString:(ocidTextM) options:(ocidOption))'s location()
	###NotFoundでは無い＝検索語句があったなので
	if ocidLocation ≠ refNSNotFound then
		###対象のitemDictを出力用のArrayに格納する
		(ocidOutPutArrayM's addObject:(itemDataDict))
	end if
end repeat
log ocidOutPutArrayM as list

#############################################
###HTML保存先ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
###保存先ディレクトリ作成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###パス
set strFileName to ((ocidTextM as text) & ".html") as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false

##HTML 基本構造
###スタイル
set strStylle to "<style>#bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 580px;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 5px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>"
###ヘッダー部
set strHead to "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>[Plist2HTML]" & (ocidTextM as text) & "</title>" & strStylle & "</head><body>"
###ボディ
set strBody to ""
###最後
set strHtmlEndBody to "</body></html>"
###HTML書き出し用のテキスト初期化
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
###bodyまでを追加
(ocidHTMLString's appendString:(strHead))
#############################################
###
###テーブルの開始部
set strHTML to ("<div id=\"bordertable\"><table><caption title=\"タイトル\">市区町村</caption>") as text
set strHTML to (strHTML & "<thead title=\"項目名称\"><tr><th title=\"項目１\" scope=\"row\" > 連番 </th><th title=\"項目２\"  scope=\"col\">都道府県</th><th title=\"項目３\" scope=\"col\"> 名称 </th><th title=\"項目４\" scope=\"col\">市番号</th><th title=\"項目５\"  scope=\"col\">かな</th><th title=\"項目６\"  scope=\"col\">カナ</th></tr></thead><tbody title=\"市区町村一覧\" >") as text
set numLineNo to 1 as integer
repeat with itemData in ocidOutPutArrayM
	###Arrayから値の取り出して
	set strCity to (itemData's valueForKey:("city")) as text
	set strCityCode to (itemData's valueForKey:("cityCode")) as text
	set strHiragana to (itemData's valueForKey:("hiragana")) as text
	set strKana to (itemData's valueForKey:("fullWidthKana")) as text
	set strPrefectures to (itemData's valueForKey:("prefectures")) as text
	(*
	set ocidLocDic to (itemData's objectForKey:("location"))
	set strLat to (ocidLocDic's valueForKey:("latitude")) as text
	set strLon to (ocidLocDic's valueForKey:("longitude")) as text
	set strMapURL to ("https://www.google.com/maps/@" & strLat & "," & strLon & ",13z")
	*)
	##	set strLINK to "<a href=\"" & strMapURL & "\" target=\"_blank\">LINK</a>"
	set strHTML to (strHTML & "<tr><th title=\"項番１\"  scope=\"row\">" & numLineNo & "</th><td title=\"項目２\">" & strPrefectures & "</td><td title=\"項目３\">" & strCity & "</td><td title=\"項目４\">" & strCityCode & "</td><td title=\"項目５\">" & strHiragana & "</td><td title=\"項目６\">" & strKana & "</td></tr>") as text
	set numLineNo to numLineNo + 1 as integer
end repeat


set strHTML to (strHTML & "</tbody><tfoot><tr><th colspan=\"6\" title=\"フッター表の終わり\"  scope=\"row\">JAPAN POSTAL CODE WEB API</th></tr></tfoot></table></div>") as text
####テーブルまでを追加
(ocidHTMLString's appendString:(strHTML))
####終了部を追加
(ocidHTMLString's appendString:(strHtmlEndBody))

###ファイルに書き出し
set listDone to ocidHTMLString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
####テキストエディタで開く
set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
tell application "TextEdit"
	activate
	open file aliasFilePath
end tell