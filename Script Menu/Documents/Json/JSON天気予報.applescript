#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
気象庁のJSON取得
Jsonの取得と解析は難しくないが
『海がない気象台』『観測所にはURLがない』とかがあることをお忘れなく
V2　色々直した
 com.cocolog-nifty.quicktimer.icefloe*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

####################
#設定項目
set strAreaUrl to "https://www.jma.go.jp/bosai/common/const/area.json"


####################
#出力用テキスト
set ocidOutPutArray to refMe's NSMutableArray's alloc()'s init()

####################
#URL
set ocidAreaUrlStr to refMe's NSString's stringWithString:(strAreaUrl)
set ocidAreaURL to refMe's NSURL's alloc()'s initWithString:(ocidAreaUrlStr)

####################
#NSDATA
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listResponse to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidAreaURL) options:(ocidOption) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "initWithContentsOfURL 正常処理"
	set ocidReadJsonData to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	set strErrorNO to (item 2 of listResponse)'s code() as text
	set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
	refMe's NSLog("■：" & strErrorNO & strErrorMes)
	return "initWithContentsOfURL エラーしました" & strErrorNO & strErrorMes
end if
####################
#JSON ルートがDICT
set ocidOption to (refMe's NSJSONReadingJSON5Allowed)
set listResponse to (refMe's NSJSONSerialization's JSONObjectWithData:(ocidReadJsonData) options:(ocidOption) |error|:(reference))
if (item 2 of listResponse) = (missing value) then
	log "JSONObjectWithData 正常処理"
	set ocidJsonDict to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	set strErrorNO to (item 2 of listResponse)'s code() as text
	set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
	refMe's NSLog("■：" & strErrorNO & strErrorMes)
	return "JSONObjectWithData エラーしました" & strErrorNO & strErrorMes
end if
####################
#centers 
set ocidCentersDict to ocidJsonDict's objectForKey:("centers")
set ocidCentersArray to ocidCentersDict's allKeys()
#ソート
set ocidCentersArray to ocidCentersArray's sortedArrayUsingSelector:("compare:")
#ダイアログ用の地方気象台名リスト
set listCenterName to {} as list
#逆引きDICT
set ocidReverseCenterDict to refMe's NSMutableDictionary's alloc()'s init()
repeat with itemKey in ocidCentersArray
	set ocidCenter to (ocidCentersDict's valueForKey:(itemKey))
	set strCenterName to (ocidCenter's valueForKey:("officeName")) as text
	copy strCenterName to end of listCenterName
	(ocidReverseCenterDict's setValue:(itemKey) forKey:(strCenterName))
end repeat

####################
#ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "SystemUIServer" to activate
else
	tell current application to activate
end if
try
	tell application "SystemUIServer"
		activate
		set valueResponse to (choose from list listCenterName with title "選んでください" with prompt "地方気象台を選んでください" default items (item 3 of listCenterName) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed)
	end tell
on error
	tell application "SystemUIServer" to quit
	log "Error choose from list"
	return false
end try
tell application "SystemUIServer" to quit
if (class of valueResponse) is boolean then
	log "Error キャンセルしました"
	error "ユーザによってキャンセルされました。" number -128
else if (class of valueResponse) is list then
	if valueResponse is {} then
		log "Error 何も選んでいません"
		return false
	else
		set strResponse to (item 1 of valueResponse) as text
	end if
end if
set ocidOutPutStrint to refMe's NSString's stringWithString:("天気予報: Center: " & strResponse & "\n")
(ocidOutPutArray's addObject:(ocidOutPutStrint))
####################
#逆引き辞書からセンター番号を取得
set ocidCenterNo to ocidReverseCenterDict's valueForKey:(strResponse)
#センター番号からOffice情報を取得
set ocidOfficeDict to (ocidCentersDict's objectForKey:(ocidCenterNo))
#Office情報 DICTから気象台番号を取得
set ocidOfficeNoArray to (ocidOfficeDict's objectForKey:("children"))
set ocidOfficeNoArray to ocidOfficeNoArray's sortedArrayUsingSelector:("compare:")

####################
#offices
set ocidOfficesDict to ocidJsonDict's objectForKey:("offices")
set ocidOfficesArray to ocidOfficesDict's allKeys()
#測候所はURLがないので除外
set appPredicate to refMe's NSPredicate's predicateWithFormat_("SELF CONTAINS %@", "測候所")
set ocidOfficesArrayRev to ocidOfficesArray's filteredArrayUsingPredicate:(appPredicate)
set ocidOfficesArray to ocidOfficesArrayRev's sortedArrayUsingSelector:("compare:")
#ダイアログ用の気象台名リスト
set listOfficesName to {} as list
#逆引きDICT
set ocidReverseOfficesDict to refMe's NSMutableDictionary's alloc()'s init()
repeat with itemKey in ocidOfficeNoArray
	set ocidOffice to (ocidOfficesDict's valueForKey:(itemKey))
	set strOfficeName to (ocidOffice's valueForKey:("officeName")) as text
	if strOfficeName does not contain "測候所" then
		copy strOfficeName to end of listOfficesName
		(ocidReverseOfficesDict's setValue:(itemKey) forKey:(strOfficeName))
	end if
end repeat


####################
#ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "SystemUIServer" to activate
else
	tell current application to activate
end if
try
	tell application "SystemUIServer"
		activate
		set valueResponse to (choose from list listOfficesName with title "選んでください" with prompt "気象台を選んでください" default items (last item of listOfficesName) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed)
	end tell
on error
	tell application "SystemUIServer" to quit
	log "Error choose from list"
	return false
end try
tell application "SystemUIServer" to quit
if (class of valueResponse) is boolean then
	log "Error キャンセルしました"
	error "ユーザによってキャンセルされました。" number -128
else if (class of valueResponse) is list then
	if valueResponse is {} then
		log "Error 何も選んでいません"
		return false
	else
		set strResponse to (item 1 of valueResponse) as text
	end if
end if
set ocidOutPutStrint to refMe's NSString's stringWithString:("Office: " & strResponse & " 発表\n")
(ocidOutPutArray's addObject:(ocidOutPutStrint))

#######################
#本処理　天気予報jSON取得
set ocidOfficeNo to ocidReverseOfficesDict's valueForKey:(strResponse)
set strOfficeNo to ocidOfficeNo as text
#日付
set strDate to doGetDateNo("yyyyMMddhhmmss") as text
###URL整形
set strURL to ("https://www.jma.go.jp/bosai/forecast/data/forecast/" & strOfficeNo & ".json?__time__=" & strDate & "") as text
log "\r" & strURL & "\r"
####################
#URL
set ocidUrlStr to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidUrlStr)

####################
#NSDATA
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listResponse to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidURL) options:(ocidOption) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "initWithContentsOfURL 正常処理"
	set ocidReadJsonData to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	set strErrorNO to (item 2 of listResponse)'s code() as text
	set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
	refMe's NSLog("■：" & strErrorNO & strErrorMes)
	return "initWithContentsOfURL エラーしました" & strErrorNO & strErrorMes
end if
####################
#JSON ルートがArray
set ocidOption to (refMe's NSJSONReadingJSON5Allowed)
set listResponse to (refMe's NSJSONSerialization's JSONObjectWithData:(ocidReadJsonData) options:(ocidOption) |error|:(reference))
if (item 2 of listResponse) = (missing value) then
	log "JSONObjectWithData 正常処理"
	set ocidJsonArray to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	set strErrorNO to (item 2 of listResponse)'s code() as text
	set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
	refMe's NSLog("■：" & strErrorNO & strErrorMes)
	return "JSONObjectWithData エラーしました" & strErrorNO & strErrorMes
end if
####################
#天気予報辞書　天気予報　と　習慣天気予報
set ocidDailyDict to ocidJsonArray's firstObject()
set ocidWeeklyDict to ocidJsonArray's firstObject()

####################
#各項目取得
set ocidTimeSeriesArray to ocidDailyDict's objectForKey:("timeSeries")
set ocidWeathers to ocidTimeSeriesArray's firstObject()
set ocidRainPops to ocidTimeSeriesArray's objectAtIndex:(1)
set ocidTemps to ocidTimeSeriesArray's lastObject()

####################
#天気予報
set strOutPutStrint to ("") as text
set ocidAreaArray to ocidWeathers's objectForKey:("areas")
repeat with itemArea in ocidAreaArray
	set strAreaName to ((itemArea's objectForKey:("area"))'s valueForKey:("name")) as text
	set ocidWeathersArray to (itemArea's objectForKey:("weathers"))
	set ocidWindsArray to (itemArea's objectForKey:("winds"))
	set ocidWavesArray to (itemArea's objectForKey:("waves"))
	
	repeat with itemNo from 0 to 2 by 1
		set strOutPutStrint to ("" & strOutPutStrint & strAreaName & "地方\n") as text
		if itemNo = 0 then
			set strOutPutStrint to ("" & strOutPutStrint & "今日の天気： ") as text
		else if itemNo = 1 then
			set strOutPutStrint to ("" & strOutPutStrint & "明日の天気： ") as text
		else if itemNo = 2 then
			set strOutPutStrint to ("" & strOutPutStrint & "明後日の天気： ") as text
		end if
		set strSetString to (ocidWeathersArray's objectAtIndex:(itemNo))
		set strOutPutStrint to ("" & strOutPutStrint & strSetString & "\n\t風： ") as text
		set strSetString to (ocidWindsArray's objectAtIndex:(itemNo))
		set strOutPutStrint to ("" & strOutPutStrint & strSetString & "\n") as text
		if ocidWavesArray ≠ (missing value) then
			set strSetString to (ocidWavesArray's objectAtIndex:(itemNo))
			set strOutPutStrint to ("" & strOutPutStrint & "\t波： " & strSetString & "\n") as text
		end if
	end repeat
	set strOutPutStrint to ("" & strOutPutStrint & "\n") as text
end repeat
set ocidOutPutStrint to refMe's NSString's stringWithString:(strOutPutStrint)
ocidOutPutArray's addObject:(ocidOutPutStrint)
####################
#降雨確率
set strOutPutStrint to ("降水確率(６時間毎)：\n") as text
set ocidAreaArray to ocidRainPops's objectForKey:("areas")
repeat with itemArea in ocidAreaArray
	set ocidAreaName to ((itemArea's objectForKey:("area"))'s valueForKey:("name"))
	set strOutPutStrint to ("" & strOutPutStrint & ocidAreaName & "地域: ") as text
	set ocidPopsString to ((itemArea's objectForKey:("pops"))'s componentsJoinedByString:("→"))
	set strOutPutStrint to ("" & strOutPutStrint & ocidPopsString & "\n") as text
end repeat
set ocidOutPutStrint to refMe's NSString's stringWithString:(strOutPutStrint)
ocidOutPutArray's addObject:(ocidOutPutStrint)
####################
#気温
set strOutPutStrint to ("気温(12時間毎)：\n") as text
set ocidAreaArray to ocidTemps's objectForKey:("areas")
repeat with itemArea in ocidAreaArray
	set ocidAreaName to ((itemArea's objectForKey:("area"))'s valueForKey:("name"))
	set strOutPutStrint to ("" & strOutPutStrint & ocidAreaName & "地域: ") as text
	set ocidTempString to ((itemArea's objectForKey:("temps"))'s componentsJoinedByString:("→"))
	set strOutPutStrint to ("" & strOutPutStrint & ocidTempString & "\n") as text
end repeat
set ocidOutPutStrint to refMe's NSString's stringWithString:(strOutPutStrint)
(ocidOutPutArray's addObject:(ocidOutPutStrint))

####################
#出力用テキスト
set ocidJoinText to ocidOutPutArray's componentsJoinedByString:("\n")
#保存先
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:(true)
#
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s init()
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)
if (item 1 of listDone) is false then
	set strErrorNO to (item 2 of listDone)'s code() as text
	set strErrorMes to (item 2 of listDone)'s localizedDescription() as text
	refMe's NSLog("■：" & strErrorNO & strErrorMes)
	log "createDirectoryAtURL エラーしました" & strErrorNO & strErrorMes
	return false
end if
###パス
set strFileName to "jma.txt" as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false

set listDone to ocidJoinText's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
if (item 1 of listDone) is true then
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set boolDone to appSharedWorkspace's openURL:(ocidSaveFilePathURL)
	
else if (item 1 of listDone) is false then
	log (item 2 of listDone)'s localizedDescription() as text
	return "保存に失敗しました"
end if


return ocidJoinText as text





to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo

