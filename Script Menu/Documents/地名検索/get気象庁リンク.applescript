#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

### 【１】JSONのURL
set strBaseURL to ("https://www.jma.go.jp/bosai/common/const/area.json") as text
set ocidURL to refMe's NSURL's alloc()'s initWithString:(strBaseURL)
### 【２】URLの内容JSONをNSdataに格納
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidURL) options:(ocidOption) |error|:(reference)
set ocidReadData to (item 1 of listReadData)
### 【３】NSPropertyListSerializationしてレコードに
set ocidOption to (refMe's NSJSONReadingMutableContainers)
set listJSONSerialization to (refMe's NSJSONSerialization's JSONObjectWithData:(ocidReadData) options:(ocidOption) |error|:(reference))
set ocidPlistDictM to item 1 of listJSONSerialization
### 【４】centersを取得
set ocidCentersDict to ocidPlistDictM's objectForKey:("centers")
set ocidCentersArray to ocidCentersDict's allKeys() as list
###【５】逆引きDictを作っておく
set ocidReverseCenterDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
repeat with itemAllKeys in ocidCentersArray
	set ocidRevValue to itemAllKeys as text
	set ocidCenter to (ocidCentersDict's valueForKey:(itemAllKeys))
	set strCenterName to (ocidCenter's valueForKey:("officeName")) as text
	set ocidItemDict to (refMe's NSDictionary's dictionaryWithObject:(ocidRevValue) forKey:(strCenterName))
	(ocidReverseCenterDict's addEntriesFromDictionary:(ocidItemDict))
end repeat
### 【６】ダイアログ用にセンター名を取得してリストにする
set listCenterName to {} as list
repeat with itemCentersArray in ocidCentersArray
	set ocidCenter to (ocidCentersDict's objectForKey:(itemCentersArray))
	set strCenterName to (ocidCenter's valueForKey:("officeName")) as text
	set end of listCenterName to strCenterName
end repeat

###########################
###【７】ダイアログ　センター選択
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listCenterName with title "選んでください" with prompt "【地方centers】選んでください" default items (item 1 of listCenterName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
else
	set strResponse to (item 1 of listResponse) as text
end if
####逆順DICTを使ってセンター番号を取得
set strCenterNo to (ocidReverseCenterDict's valueForKey:(strResponse)) as text
###########################
###【８】ダイアログで選んだセンターの子要素（office）番号を取得
set ocidCenter to (ocidCentersDict's valueForKey:(strCenterNo))
set ocidChildrenArray to ocidCenter's objectForKey:("children")
log ocidChildrenArray as list
###########################
###【９】office番号のリストから気象台レコードを作成する
set ocidOfficesDict to ocidPlistDictM's objectForKey:("offices")
###子要素 Class取り出し用のレコード
set ocidOfficeDictS to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set listOfficeName to {} as list
###センターの子要素　気象台の分だけ繰り返し
repeat with itemChildrenArray in ocidChildrenArray
	set ocidOfficeDict to (ocidOfficesDict's objectForKey:(itemChildrenArray as text))
	set strOfficeName to (ocidOfficeDict's valueForKey:("officeName")) as text
	set ocidClassArray to (ocidOfficeDict's objectForKey:("children"))
	set ocidItemDict to (refMe's NSDictionary's dictionaryWithObject:(ocidClassArray) forKey:(strOfficeName))
	(ocidOfficeDictS's addEntriesFromDictionary:(ocidItemDict))
	set end of listOfficeName to strOfficeName
end repeat
log listOfficeName as list
###########################
###【１０】ダイアログ オフィス選択
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listOfficeName with title "選んでください" with prompt "【地方centers】選んでください" default items (item 1 of listOfficeName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
else
	set strResponse to (item 1 of listResponse) as text
end if
###
set ocidClassArray to ocidOfficeDictS's objectForKey:(strResponse)
log ocidClassArray as list
###########################
###【１１】class10sから子要素を集める
set ocidClass10sDict to ocidPlistDictM's objectForKey:("class10s")
set ocidChildArray10sM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
repeat with itemClassArray in ocidClassArray
	set ocidClass10sArray to (ocidClass10sDict's objectForKey:(itemClassArray as text))
	set ocidClass10sChildrenArray to (ocidClass10sArray's objectForKey:("children"))
	repeat with itemChidArray in ocidClass10sChildrenArray
		(ocidChildArray10sM's addObject:(itemChidArray))
	end repeat
end repeat
log ocidChildArray10sM as list

###########################
###【１２】class15sから子要素を集める
set ocidClass15sDict to ocidPlistDictM's objectForKey:("class15s")
set ocidChildArray15sM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
repeat with itemClassArray in ocidChildArray10sM
	set ocidClass15sArray to (ocidClass15sDict's objectForKey:(itemClassArray as text))
	set ocidClass15sChildrenArray to (ocidClass15sArray's objectForKey:("children"))
	repeat with itemChidArray in ocidClass15sChildrenArray
		(ocidChildArray15sM's addObject:(itemChidArray))
	end repeat
end repeat

log ocidChildArray15sM as list

###########################
###【１３】class20sから子要素を集める
set ocidClass20sDict to ocidPlistDictM's objectForKey:("class20s")
###
set ocidDivDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidRevDivDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
repeat with itemClassArray in ocidChildArray15sM
	set ocidClass20sArray to (ocidClass20sDict's objectForKey:(itemClassArray as text))
	set strClass20sKey to (ocidClass20sArray's objectForKey:("name")) as text
	set strClass20sValue to (itemClassArray) as text
	set ocidItemDict to (refMe's NSDictionary's dictionaryWithObject:(strClass20sValue) forKey:(strClass20sKey))
	set ocidItemRevDict to (refMe's NSDictionary's dictionaryWithObject:(strClass20sKey) forKey:(strClass20sValue))
	(ocidDivDict's addEntriesFromDictionary:(ocidItemDict))
	(ocidRevDivDict's addEntriesFromDictionary:(ocidItemRevDict))
end repeat
log ocidDivDict as record
log ocidRevDivDict as record
set listAllKey to (ocidDivDict's allKeys()) as list

###########################
###【１４】最終的な選択ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listAllKey with title "選んでください" with prompt "選んでください" default items (item 1 of listAllKey) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
else
	set strResponse to (item 1 of listResponse) as text
end if
set ocidValueNO to ocidDivDict's valueForKey:(strResponse)
set strValueNO to ocidValueNO as text
log strValueNO



########################################
##HTML 基本構造
###スタイル
set strStylle to "<style>#bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 80%;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 5px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>"
###ヘッダー部
set strHead to "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>[" & strValueNO & "]" & strResponse & "</title>" & strStylle & "</head><body>"
###最後
set strHtmlEndBody to "</body></html>"
###HTML書き出し用のテキスト初期化
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####
(ocidHTMLString's appendString:strHead)

#########
###テーブルの開始部
set strHTML to ("<div id=\"bordertable\"><table><caption title=\"タイトル\">検索語句：" & strResponse & " 検索結果:" & strValueNO & "件</caption>") as text
set strHTML to (strHTML & "<thead title=\"項目名称\"><tr><th title=\"項目１\" scope=\"row\" >連番</th><th title=\"項目２\" scope=\"col\"> リンク１ </th><th title=\"項目３\" scope=\"col\">リンク２</th><th title=\"項目４\"  scope=\"col\">リンク３</th><th title=\"項目５\"  scope=\"col\"> リンク４</th><th title=\"項目６\"  scope=\"col\">リンク５</th><th title=\"項目７\"  scope=\"col\">リンク６</th><th title=\"項目８\"  scope=\"col\">リンク７</th></tr></thead><tbody title=\"検索結果一覧\" >") as text
(ocidHTMLString's appendString:(strHTML))
##############################
###リンク１
set strMapURL to ("https://www.jma.go.jp/bosai/#pattern=default&area_type=class20s&area_code=" & strValueNO & "")
set strLINK1 to "<a href=\"" & strMapURL & "\" target=\"_blank\">防災情報</a>"
###リンク２
set strMapURL to ("https://www.jma.go.jp/bosai/forecast/#area_type=class20s&area_code=" & strValueNO & "")
set strLINK2 to "<a href=\"" & strMapURL & "\" target=\"_blank\">天気予報</a>"
###リンク３
set strMapURL to ("https://www.jma.go.jp/bosai/map.html#contents=amedas&area_type=class20s&area_code=" & strValueNO & "")
set strLINK3 to "<a href=\"" & strMapURL & "\" target=\"_blank\">アメダス</a>"
###リンク４
set strMapURL to ("https://www.jma.go.jp/bosai/nowc/#area_type:class20s/area_code:" & strValueNO & "/")
set strLINK4 to "<a href=\"" & strMapURL & "\" target=\"_blank\">雨雲の動き</a>"
###リンク５
set strMapURL to ("https://www.jma.go.jp/bosai/probability/#area_type=class20s&lang=ja&area_code=" & strValueNO & "")
set strLINK5 to "<a href=\"" & strMapURL & "\" target=\"_blank\">早期注意情報</a>"
###リンク６
set strMapURL to ("https://www.jma.go.jp/bosai/map.html#contents=tsunami&area_type=class20s&from=bosaitop&area_code=" & strValueNO & "")
set strLINK6 to "<a href=\"" & strMapURL & "\" target=\"_blank\">津波</a>"
###リンク７
set strMapURL to ("https://www.jma.go.jp/bosai/map.html#contents=volcano&area_type=class20s&from=bosaitop&area_code=" & strValueNO & "")
set strLINK7 to "<a href=\"" & strMapURL & "\" target=\"_blank\">噴火</a>"

###HTMLにして
set strHTML to ("<tr><th title=\"連番\"  scope=\"row\">1</th><td title=\"リンク１\"><b>" & strLINK1 & "</b></td><td title=\"リンク２\">" & strLINK2 & "</td><td title=\"リンク３\">" & strLINK3 & "</td><td title=\"リンク４\">" & strLINK4 & "</td><td title=\"リンク５\">" & strLINK5 & "</td><td title=\"リンク６\">" & strLINK6 & "</td><td title=\"リンク７\">" & strLINK7 & "</td></tr>") as text
(ocidHTMLString's appendString:(strHTML))
set strHTML to ("</tbody><tfoot><tr><th colspan=\"8\" title=\"フッター表の終わり\"  scope=\"row\"><a href=\"https://www.jma.go.jp//\" target=\"_blank\">www.jma.go.jp</a></th></tr></tfoot></table></div>") as text
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

set strFileName to ((strValueNO) & ".html") as text
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


