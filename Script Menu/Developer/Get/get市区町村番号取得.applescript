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

###########################
###都道府県番号レコード
set recordPrefCode to {|北海道|:"01", |青森県|:"02", |岩手県|:"03", |宮城県|:"04", |秋田県|:"05", |山形県|:"06", |福島県|:"07", |茨城県|:"08", |栃木県|:"09", |群馬県|:"10", |埼玉県|:"11", |千葉県|:"12", |東京都|:"13", |神奈川県|:"14", |新潟県|:"15", |富山県|:"16", |石川県|:"17", |福井県|:"18", |山梨県|:"19", |長野県|:"20", |岐阜県|:"21", |静岡県|:"22", |愛知県|:"23", |三重県|:"24", |滋賀県|:"25", |京都府|:"26", |大阪府|:"27", |兵庫県|:"28", |奈良県|:"29", |和歌山県|:"30", |鳥取県|:"31", |島根県|:"32", |岡山県|:"33", |広島県|:"34", |山口県|:"35", |徳島県|:"36", |香川県|:"37", |愛媛県|:"38", |高知県|:"39", |福岡県|:"40", |佐賀県|:"41", |長崎県|:"42", |熊本県|:"43", |大分県|:"44", |宮崎県|:"45", |鹿児島県|:"46", |沖縄県|:"47"} as record
###Dictに格納
set recordPrefCodeDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
recordPrefCodeDict's setDictionary:(recordPrefCode)
###キーと値をそれぞれArrayにしておく
set ocidAllKeys to recordPrefCodeDict's allKeys()
###	逆順Dictを初期化
set ocidReversePrefCodeDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
repeat with itemAllKeys in ocidAllKeys
	set ocidRevValue to itemAllKeys as text
	set ocidRevKey to (recordPrefCodeDict's valueForKey:(itemAllKeys)) as text
	set ocidItemDict to (refMe's NSDictionary's dictionaryWithObject:(ocidRevValue) forKey:(ocidRevKey))
	(ocidReversePrefCodeDict's addEntriesFromDictionary:(ocidItemDict))
end repeat
##AllValueを取って
set ocidAllValues to recordPrefCodeDict's allValues()
###AllValue値のArrayをソート
set ocidDescriptor to refMe's NSSortDescriptor's sortDescriptorWithKey:("self") ascending:(true) selector:("localizedStandardCompare:")
set ocidDescriptorArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
ocidDescriptorArray's addObject:(ocidDescriptor)
set ocidSortedValues to (ocidAllValues's sortedArrayUsingDescriptors:(ocidDescriptorArray))
###ダイアログ用のリスト
set listChooser to {} as list
###ソート済みの値Arrayを順番に
repeat with itemSortedValues in ocidSortedValues
	set strItemSortedValues to itemSortedValues as text
	set strPrefName to (ocidReversePrefCodeDict's valueForKey:(strItemSortedValues)) as text
	set end of listChooser to (strPrefName as text)
end repeat
###########################
###ダイアログを前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listChooser with title "選んでください" with prompt "選んでください" default items (item 1 of listChooser) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
else
	set strResponse to (item 1 of listResponse) as text
end if
set ocidValueNO to recordPrefCodeDict's valueForKey:(strResponse)
set strValueNO to ocidValueNO as text

###########################
##
set strBaseURL to ("https://www.land.mlit.go.jp/webland_english/api/CitySearch") as text
set strBaseURL to ("https://www.land.mlit.go.jp/webland/api/CitySearch") as text
set ocidURL to refMe's NSURL's alloc()'s initWithString:(strBaseURL)
##コンポーネント初期化
set ocidComponents to refMe's NSURLComponents's componentsWithURL:(ocidURL) resolvingAgainstBaseURL:true
##クエリー格納用Array
set ocidQueryItemArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("area") value:(strValueNO)
ocidQueryItemArray's addObject:(ocidQueryItem)
ocidComponents's setQueryItems:(ocidQueryItemArray)
### 【１】JSONのURL
set ocidAPIURL to ocidComponents's |URL|
log ocidAPIURL's absoluteString() as text

### 【２】URLの内容JSONをNSdataに格納
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidAPIURL) options:(ocidOption) |error|:(reference)
set ocidReadData to (item 1 of listReadData)

### 【３】NSPropertyListSerializationしてレコードに
set ocidOption to (refMe's NSJSONReadingMutableContainers)
set listJSONSerialization to (refMe's NSJSONSerialization's JSONObjectWithData:(ocidReadData) options:(ocidOption) |error|:(reference))
set ocidPlistDictM to item 1 of listJSONSerialization
### 【４】Data＝Arrayを取り出す
set ocidDataArray to ocidPlistDictM's objectForKey:("data")
### 【５】４のArrayをDictにしていく
set ocidDataDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
repeat with itemDataArray in ocidDataArray
	set strID to (itemDataArray's valueForKey:("id")) as text
	set strValue to (itemDataArray's valueForKey:("name")) as text
	set ocidItemDict to (refMe's NSDictionary's dictionaryWithObject:(strValue) forKey:(strID))
	(ocidDataDict's addEntriesFromDictionary:(ocidItemDict))
end repeat

###	【６】DictからAllKeyを取り出す
set ocidAllKeysArray to ocidDataDict's allKeys()
###	【７】逆順Dictを初期化
set ocidReverseDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
repeat with itemAllKeysArray in ocidAllKeysArray
	set ocidRevValue to itemAllKeysArray as text
	set ocidRevKey to (ocidDataDict's valueForKey:(itemAllKeysArray)) as text
	set ocidItemDict to (refMe's NSDictionary's dictionaryWithObject:(ocidRevValue) forKey:(ocidRevKey))
	(ocidReverseDict's addEntriesFromDictionary:(ocidItemDict))
end repeat
###	【８】５で取り出したDictからAllValue全ての値を取り出す
set ocidAllValueArray to ocidDataDict's allValues()

###ダイアログ用のリスト
set listAllValueArray to ocidAllValueArray as list
###########################
###ダイアログを前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listAllValueArray with title "選んでください" with prompt "選んでください" default items (item 1 of listAllValueArray) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
else
	set strResponse to (item 1 of listResponse) as text
end if
set strCtyNo to (ocidReverseDict's valueForKey:(strResponse)) as text

(* allValueとAllKeyが同じ順番なのを保証していないので使えないことが判明
###戻り値がArrayの何番目だったか？
set numIndex to ocidAllValueArray's indexOfObject:(strResponse)
###↑値と同じ番目にあるキーの値を市区町村コード
set strCtyNo to (ocidAllKeysArray's objectAtIndex:(numIndex)) as text
*)
###########################
###ダイアログを前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to POSIX file "/System/Applications/Maps.app/Contents/Resources/AppIcon.icns"
set strMes to ("戻り値です\r " & strResponse & "の市区町村番号：" & strCtyNo & "") as text
set recordResult to (display dialog strMes with title "bundle identifier" default answer strCtyNo buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)
if button returned of recordResult is "クリップボードにコピー" then
	try
		set strText to text returned of recordResult as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strTitle as text
		end tell
	end try
end if

log ocidDataDict as record
