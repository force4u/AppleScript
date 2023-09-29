#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#タブ区切りテキストからPlistを生成する
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

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
set ocidFilePathURL to ocidPathToMeContainerDirURL's URLByAppendingPathComponent:("data/都道府県名.tsv")
##########################################
### 【２】テキスト読み込み
set listReadText to refMe's NSString's alloc()'s initWithContentsOfURL:(ocidFilePathURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
set ocidReadText to (item 1 of listReadText)
##########################################
### 【３】改行でArray
set ocidChrSet to refMe's NSCharacterSet's newlineCharacterSet()
set ocidRootArray to ocidReadText's componentsSeparatedByCharactersInSet:(ocidChrSet)
##########################################
###出力用のDICT
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
##ROOTのARRAY
set ocidCityArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
### 【４】行毎にタブ区切りでArrrayにする
repeat with itemLineText in ocidRootArray
	##タブ区切り
	set ocidChrSet to (refMe's NSCharacterSet's characterSetWithCharactersInString:("t"))
	##タブ区切りでArray
	set ocidLineArray to (itemLineText's componentsSeparatedByCharactersInSet:(ocidChrSet))
	##変換出力用のDICT
	set ocidCityDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	###
	set ocidArray1Str to (ocidLineArray's objectAtIndex:(0))
	(ocidCityDict's setObject:(ocidArray1Str) forKey:"cityCode")
	##
	set ocidArray2Str to (ocidLineArray's objectAtIndex:(1))
	(ocidCityDict's setObject:(ocidArray2Str) forKey:"prefectures")
	##
	set ocidArray3Str to (ocidLineArray's objectAtIndex:(2))
	(ocidCityDict's setObject:(ocidArray3Str) forKey:"city")
	##半角カナ
	set ocidArray4Str to (ocidLineArray's objectAtIndex:(3))
	(ocidCityDict's setObject:(ocidArray4Str) forKey:"prefectures-han-kana")
	##
	set ocidArray5Str to (ocidLineArray's objectAtIndex:(4))
	(ocidCityDict's setObject:(ocidArray5Str) forKey:"city-han-kana")
	##
	(ocidCityDict's setObject:((ocidArray4Str as text) & (ocidArray5Str as text)) forKey:"halfWidthKana")
	##
	set ocidNSStringTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
	set ocidPrefecturesKana to (ocidArray4Str's stringByApplyingTransform:(ocidNSStringTransform) |reverse|:true)
	(ocidCityDict's setObject:(ocidPrefecturesKana) forKey:"prefectures-kana")
	##
	set ocidCityKana to (ocidArray5Str's stringByApplyingTransform:(ocidNSStringTransform) |reverse|:true)
	(ocidCityDict's setObject:(ocidCityKana) forKey:"city-han-kana")
	##
	(ocidCityDict's setObject:((ocidPrefecturesKana as text) & (ocidCityKana as text)) forKey:"fullWidthKana")
	##
	set ocidNSStringTransform to (refMe's NSStringTransformHiraganaToKatakana)
	set ocidPrefecturesHira to (ocidArray4Str's stringByApplyingTransform:(ocidNSStringTransform) |reverse|:true)
	(ocidCityDict's setObject:(ocidPrefecturesHira) forKey:"prefectures-hirakana")
	##
	set ocidCityHira to (ocidArray5Str's stringByApplyingTransform:(ocidNSStringTransform) |reverse|:true)
	(ocidCityDict's setObject:(ocidCityHira) forKey:"city-hirakana")
	##
	(ocidCityDict's setObject:((ocidPrefecturesHira as text) & (ocidCityHira as text)) forKey:"hiragana")
	###
	(ocidCityArrayM's addObject:(ocidCityDict))
	
end repeat

ocidPlistDict's setObject:(ocidCityArrayM) forKey:("data")

set ocidFormat to (refMe's NSPropertyListBinaryFormat_v1_0)
set listPlistData to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFormat) options:0 |error|:(reference)
set ocidPlistData to (item 1 of listPlistData)
log className() of ocidPlistData as text
##########################################
set ocidContainerPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
set strSaveFileName to ("PrefecturesData.plist") as text
set ocidSaveFilePathURL to ocidContainerPathURL's URLByAppendingPathComponent:(strSaveFileName)
####【４】保存  ここは上書き
set ocidOption to (refMe's NSDataWritingAtomic)
set listDOne to ocidPlistData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference)

log (item 1 of listDOne)
if (item 1 of listDOne) = true then
	return "正常終了"
else
	return "保存に失敗しました"
end if