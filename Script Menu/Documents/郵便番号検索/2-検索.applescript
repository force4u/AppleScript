#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807


#############################
###DBファイルへのパス
tell application "Finder"
	set aliasPathToMe to (path to me) as alias
	set aliasContainerDirPath to (container of aliasPathToMe) as alias
end tell
set strContainerDirPath to (POSIX path of aliasContainerDirPath) as text
set ocidContainerDirPathStr to refMe's NSString's stringWithString:(strContainerDirPath)
set ocidContainerDirPath to ocidContainerDirPathStr's stringByStandardizingPath()
set ocidContainerDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidContainerDirPath) isDirectory:true)
set ocidDBFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("data/postno.db")
set strDbFilePathURL to (ocidDBFilePathURL's |path|()) as text


#############################
### クリップボードの中身取り出し
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
		set strReadString to "" as text
	end if
end if
set strMes to ("住所で検索　一部分でも可\r神奈川とかで指定すると検索結果が多くなります") as text
set strQueryText to strReadString as text

##############################
###ダイアログ
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
	set recordResult to (display dialog strMes with title "郵便番号検索" default answer strQueryText buttons {"OK", "キャンセル"} default button "OK" with icon aliasIconPath giving up after 20 without hidden answer) as record
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
###戻り値整形
set ocidResponseText to (refMe's NSString's stringWithString:(strReturnedText))
###タブと改行を除去しておく
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidTextM's appendString:(ocidResponseText)
##改行除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\n") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\r") withString:("")
##タブ除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\t") withString:("")
##############################
###ひらがなのみの場合はカタカナに
set listRegex to refMe's NSRegularExpression's regularExpressionWithPattern:("^[ぁ-んー]+$") options:(0) |error|:(reference)
set ocidRegex to (item 1 of listRegex)
set ocidTextRange to refMe's NSMakeRange(0, (ocidTextM's |length|()))
log ocidTextRange
set numMach to ocidRegex's numberOfMatchesInString:(ocidTextM) options:0 range:(ocidTextRange)
if (numMach as integer) = 1 then
	set ocidTransform to (refMe's NSStringTransformHiraganaToKatakana)
	set ocidTextM to (ocidTextM's stringByApplyingTransform:(ocidTransform) |reverse|:false)
end if
###数字がなければ全角に
set ocidTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
set ocidTextM to (ocidTextM's stringByApplyingTransform:(ocidTransform) |reverse|:true)
##############################
##カタカナと漢字混在で検索方法が異なる
set listRegex to refMe's NSRegularExpression's regularExpressionWithPattern:("^[ァ-ヶー]+$") options:(0) |error|:(reference)
set ocidRegex to (item 1 of listRegex)
set ocidTextRange to refMe's NSMakeRange(0, (ocidTextM's |length|()))
set numMach to ocidRegex's numberOfMatchesInString:(ocidTextM) options:0 range:(ocidTextRange)
set strSearchText to ocidTextM as text
if (numMach as integer) = 1 then
	set strCommandText to ("/usr/bin/sqlite3 \"" & strDbFilePathURL & "\" -tabs \"SELECT COUNT(*)  FROM postalcode WHERE prefecture_kana LIKE '%" & strSearchText & "%' OR city_kana LIKE  '%" & strSearchText & "%' OR town_kana LIKE  '%" & strSearchText & "%';\"") as text
	log strCommandText
else
	set strCommandText to ("/usr/bin/sqlite3 \"" & strDbFilePathURL & "\" -tabs \"SELECT COUNT(*)  FROM postalcode WHERE prefecture LIKE '%" & strSearchText & "%' OR city LIKE  '%" & strSearchText & "%' OR town LIKE  '%" & strSearchText & "%';\"") as text
	log strCommandText
end if
set numQueryCnt to (do shell script strCommandText) as integer
##############################
###
if numQueryCnt > 100 then
	log "検索結果１００件超です"
	###ダイアログを前面に出す
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
	set numMin to (0.03 * numQueryCnt) as integer
	set strAlertMes to "検索結果１００件超です（" & numQueryCnt & "件）\r継続すると結果表示まで約：" & numMin & "秒かかります" as text
	try
		set recordResponse to (display alert ("【選んでください】\r" & strAlertMes) buttons {"継続", "終了"} default button "継続" cancel button "終了" as informational giving up after 10) as record
	on error
		log "エラーしました"
		return "キャンセルしました。処理を中止します。再度実行してください"
	end try
	if true is equal to (gave up of recordResponse) then
		return "時間切れです。処理を中止します。再度実行してください"
	end if
else if numQueryCnt = 0 then
	log "検索結果０件です"
end if


if (numMach as integer) = 1 then
	set strCommandText to ("/usr/bin/sqlite3 \"" & strDbFilePathURL & "\" -tabs \"SELECT * FROM postalcode WHERE prefecture_kana LIKE '%" & strSearchText & "%' OR city_kana LIKE  '%" & strSearchText & "%' OR town_kana LIKE  '%" & strSearchText & "%';\"") as text
	log strCommandText
else
	set strCommandText to ("/usr/bin/sqlite3 \"" & strDbFilePathURL & "\" -tabs \"SELECT * FROM postalcode WHERE prefecture LIKE '%" & strSearchText & "%' OR city LIKE  '%" & strSearchText & "%' OR town LIKE  '%" & strSearchText & "%';\"") as text
	log strCommandText
end if
set strResponse to (do shell script strCommandText) as text


########################################
##
set AppleScript's text item delimiters to "\r"
set listResponse to every text item of strResponse
set AppleScript's text item delimiters to ""

########################################
##HTML 基本構造
###スタイル
set strStylle to "<style>#bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 80%;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 5px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>"
###ヘッダー部
set strHead to "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>[検索語句]" & strSearchText & "</title>" & strStylle & "</head><body>"
###ボディ
set strBody to ""
###最後
set strHtmlEndBody to "</body></html>"
###HTML書き出し用のテキスト初期化
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####
(ocidHTMLString's appendString:strHead)
#########
###テーブルの開始部
set strHTML to ("<div id=\"bordertable\"><table><caption title=\"タイトル\">検索結果:" & strReturnedText & "</caption>") as text
set strHTML to (strHTML & "<thead title=\"項目名称\"><tr><th title=\"項目１\" scope=\"row\" > 連番 </th><th title=\"項目２\" scope=\"col\"> 郵便番号 </th><th title=\"項目３\" scope=\"col\"> 住所 </th><th title=\"項目４\"  scope=\"col\"> 読み </th><th title=\"項目５\"  scope=\"col\">団体コード</th><th title=\"項目６\"  scope=\"col\">リンク</th></tr></thead><tbody title=\"検索結果一覧\" >") as text
set numLineNo to 1 as integer
repeat with itemLine in listResponse
	set AppleScript's text item delimiters to "\t"
	set listLineText to every text item of itemLine
	set AppleScript's text item delimiters to ""
	
	set strCityCode to (item 1 of listLineText) as text
	set strPostNo to (item 3 of listLineText) as text
	set strAddText to ((item 7 of listLineText) & (item 8 of listLineText) & (item 9 of listLineText)) as text
	set strKana to ((item 4 of listLineText) & (item 5 of listLineText) & (item 6 of listLineText)) as text
	
	set strLinkURL to ("https://www.post.japanpost.jp/cgi-zip/zipcode.php?zip=" & strPostNo & "")
	set strMapURL to ("https://www.google.com/maps/search/郵便番号+" & strPostNo & "")
	set strMapAppURL to ("http://maps.apple.com/?q=郵便番号+" & strPostNo & "")
	set strLINK to "<a href=\"" & strLinkURL & "\" target=\"_blank\">郵政</a>&nbsp;|&nbsp;<a href=\"" & strMapURL & "\" target=\"_blank\">Google</a>&nbsp;|&nbsp;<a href=\"" & strMapAppURL & "\" target=\"_blank\">Map</a>"
	
	set strHTML to (strHTML & "<tr><th title=\"項番１\"  scope=\"row\">" & numLineNo & "</th><td title=\"項目２\"><b>" & strPostNo & "</b></td><td title=\"項目３\">" & strAddText & "</td><td title=\"項目４\"><small>" & strKana & "</small></td><td title=\"項目５\">" & strCityCode & "</td><td title=\"項目６\">" & strLINK & "</td></tr>") as text
	
	set numLineNo to numLineNo + 1 as integer
end repeat


set strHTML to (strHTML & "</tbody><tfoot><tr><th colspan=\"6\" title=\"フッター表の終わり\"  scope=\"row\">post.japanpost.jp</th></tr></tfoot></table></div>") as text
####テーブルまでを追加
(ocidHTMLString's appendString:(strHTML))
####終了部を追加
(ocidHTMLString's appendString:(strHtmlEndBody))

###ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###パス

set strFileName to (strSearchText & ".html") as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
###ファイルに書き出し
set listDone to ocidHTMLString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
####テキストエディタで開く
set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
(*
tell application "TextEdit"
	activate
	open file aliasFilePath
end tell
*)
tell application "Safari"
	activate
	open file aliasFilePath
end tell




