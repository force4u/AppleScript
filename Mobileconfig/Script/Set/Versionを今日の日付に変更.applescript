#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	UUIDに変更がないため『更新』となります
#	更新＝旧設定から新しいファイルに指示されている設定に上書きされます
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


on run
	set aliasDefaultLocation to (path to desktop from user domain) as alias
	set listUTI to {"com.apple.mobileconfig"} as list
	set strPromptText to "ファイルをえらんでください" as text
	set strMesText to "ファイルをえらんでください" as text
	try
		set listFilePath to (choose file strMesText with prompt strPromptText default location aliasDefaultLocation of type listUTI with invisibles and multiple selections allowed without showing package contents) as list
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	open listFilePath
end run


on open listFilePath
	set strDateno to doGetDateNo("yyyyMMdd")
	set ocidVerSionNo to (refMe's NSNumber's numberWithInteger:strDateno)'s intValue
	
	log strDateno
	repeat with itemFilePath in listFilePath
		set aliasFilePath to itemFilePath as alias
		set strFilePath to (POSIX path of aliasFilePath) as text
		set ocidFilePathStr to (refMe's NSString's stringWithString:strFilePath)
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false)
		##############################################
		## 本処理  ROOT 項目
		##############################################
		set ocidPlistDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
		set listReadPlistData to (refMe's NSMutableDictionary's dictionaryWithContentsOfURL:ocidFilePathURL |error|:(reference))
		set ocidReadDict to (item 1 of listReadPlistData)
		(ocidPlistDict's setDictionary:ocidReadDict)
		set numVerSion to (ocidPlistDict's valueForKey:"PayloadVersion") as integer
		log "現在のバージョン：" & numVerSion
		###変更
		(ocidPlistDict's setValue:ocidVerSionNo forKey:"PayloadVersion")
		set numVerSion to (ocidPlistDict's valueForKey:"PayloadVersion") as integer
		log "変更後のバージョン：" & numVerSion
		##############################################
		## 本処理  PayloadContent
		##############################################
		set ocidPayloadContentArray to (ocidPlistDict's objectForKey:"PayloadContent")
		repeat with itemPayloadContentArray in ocidPayloadContentArray
			set numVerSion to (itemPayloadContentArray's valueForKey:"PayloadVersion") as integer
			log "現在のバージョン：" & numVerSion
			###変更
			(itemPayloadContentArray's setValue:ocidVerSionNo forKey:"PayloadVersion")
			set numVerSion to (itemPayloadContentArray's valueForKey:"PayloadVersion") as integer
			log "変更後のバージョン：" & numVerSion
		end repeat
		##############################################
		## 保存
		##############################################
		set ocidPlistType to refMe's NSPropertyListXMLFormat_v1_0
		set listPlistEditDataArray to (refMe's NSPropertyListSerialization's dataWithPropertyList:ocidPlistDict format:ocidPlistType options:0 |error|:(reference))
		set ocidPlisSaveData to item 1 of listPlistEditDataArray
		set boolSaveDone to (ocidPlisSaveData's writeToURL:ocidFilePathURL options:(refMe's NSDataWritingAtomic) |error|:(reference))
		log boolSaveDone as list
	end repeat
	
end open




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