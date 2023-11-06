#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
UUIDが違うと、同じ設定内容でも『別』となります
UUID変更時は古い設定を削除してから
*)
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


#####設定項目 会社名や組織名でOK
property strOrganization : ("com.cocolog-nifty.quicktimer") as text
property strPayloadScopeType : ("User") as text
#####設定項目　有効期限の切り替えタイミング
###【A】24時間　の場合はA
###【B】日付が変わったらの場合はBを
property strTiming : ("B") as text

on run
	set aliasDefaultLocation to (path to desktop from user domain) as alias
	set listUTI to {"com.apple.mobileconfig"} as list
	set strPromptText to "mobileconfigファイルをえらんでください\n有効期限を明日までに設定します" as text
	set strMesText to "mobileconfigファイルをえらんでください\n有効期限を明日までに設定します" as text
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
		####PayloadVersionは現在の日付に
		set numVerSion to (ocidPlistDict's valueForKey:"PayloadVersion") as integer
		log "現在のバージョン：" & numVerSion
		###変更
		(ocidPlistDict's setValue:ocidVerSionNo forKey:"PayloadVersion")
		set numVerSion to (ocidPlistDict's valueForKey:"PayloadVersion") as integer
		log "変更後のバージョン：" & numVerSion
		###
		####PayloadOrganization 現在のタイプを取得して
		set strPayloadOrganization to (ocidPlistDict's valueForKey:"PayloadOrganization") as text
		###未設定なら設定する
		if strPayloadOrganization is "missing value" then
			(ocidPlistDict's setValue:(strOrganization) forKey:("PayloadOrganization"))
			set strPayloadOrganization to strOrganization
		end if
		###UUID生成
		set ocidUUID to refMe's NSUUID's alloc()'s init()
		set strUUID to ocidUUID's UUIDString as text
		###PayloadUUIDにセット 同じUUIDを使う場合はコメントアウト
		(ocidPlistDict's setValue:(strUUID) forKey:("PayloadUUID"))
		###組織名＋UUIDを 同じUUIDを使う場合はコメントアウト
		set strPayloadIdentifier to (strOrganization & "." & strUUID) as text
		###PayloadIdentifierにセット 同じUUIDを使う場合はコメントアウト
		(ocidPlistDict's setValue:(strPayloadIdentifier) forKey:("PayloadIdentifier"))
		####PayloadOrganization 現在のタイプを取得して
		set strPayloadOrganization to (ocidPlistDict's valueForKey:"PayloadOrganization") as text
		###未設定なら設定する
		if strPayloadOrganization is "missing value" then
			(ocidPlistDict's setValue:(strOrganization) forKey:("PayloadOrganization"))
			set strPayloadOrganization to strOrganization
		end if
		###ConsentText
		set strNextDate to doGetNextDateNo("yyyyMMdd") as text
		set ocidConsentTextDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
		set strValue to ("このプロファイルは" & strNextDate & "日に自動で削除されます") as text
		(ocidConsentTextDict's setValue:(strValue) forKey:("default"))
		####ConsentText現在を取得して
		set strConsentText to (ocidPlistDict's valueForKey:"ConsentText") as text
		###未設定なら設定する
		if strConsentText is "missing value" then
			(ocidPlistDict's setObject:(ocidConsentTextDict) forKey:("ConsentText"))
		end if
		###TargetDeviceType	0はALL １はiOS 5はmacOS
		set ocidTypeNo to (refMe's NSNumber's numberWithInteger:5)'s integerValue
		(ocidPlistDict's setValue:(ocidTypeNo) forKey:("TargetDeviceType"))
		####PayloadScope現在を取得して
		set strPayloadScope to (ocidPlistDict's valueForKey:"PayloadScope") as text
		###未設定なら設定する
		if strPayloadScope is "missing value" then
			(ocidPlistDict's setValue:(strPayloadScopeType) forKey:("PayloadScope"))
		end if
		##############################
		###PayloadRemovalDisallowedにセット
		(ocidPlistDict's setValue:(refMe's NSNumber's numberWithBool:false) forKey:("PayloadRemovalDisallowed"))
		###HasRemovalPasscodeにセット
		(ocidPlistDict's setValue:(refMe's NSNumber's numberWithBool:false) forKey:("HasRemovalPasscode"))
		if strTiming is ("A") then
			###【A】RemovalDate 24時間の場合
			set strNextDate to doGetNextDateNo("yyyy-MM-dd'T'HH:mm:ss'Z'") as text
			(ocidPlistDict's setObject:(strNextDate) forKey:("RemovalDate"))
		else if strTiming is ("B") then
			###【B】日付が変わったらの場合
			set strNextDate to doGetNextDateNo("yyyy-MM-dd") as text
			set strNextDate to (strNextDate & "T00:00:01Z")
			set ocidNextDateTime to doGetText2Date({strNextDate, "yyyy-MM-dd'T'HH:mm:ss'Z'"})
			(ocidPlistDict's setObject:(ocidNextDateTime) forKey:("RemovalDate"))
		end if
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
			####PayloadTypeを取得して
			set strPayloadType to (itemPayloadContentArray's valueForKey:"PayloadType") as text
			###ディスクリプションにセット
			(itemPayloadContentArray's setValue:(strPayloadType) forKey:("PayloadDescription"))
			###UUID生成
			set ocidUUID to refMe's NSUUID's alloc()'s init()
			set strUUID to ocidUUID's UUIDString as text
			###PayloadUUIDにセット　同じUUIDを使う場合はコメントアウト
			(itemPayloadContentArray's setValue:(strUUID) forKey:("PayloadUUID"))
			###PayloadType＋UUIDを 同じUUIDを使う場合はコメントアウト
			set PayloadType to (strPayloadType & "." & strUUID) as text
			###PayloadIdentifierにセット
			(itemPayloadContentArray's setValue:(PayloadType) forKey:("PayloadIdentifier"))
			####PayloadDescription 現在の内容を取得して
			set strPayloadDescription to (itemPayloadContentArray's valueForKey:"PayloadDescription") as text
			###未設定なら設定する
			if strPayloadDescription is "missing value" then
				(itemPayloadContentArray's setValue:(strPayloadType) forKey:("PayloadDescription"))
			end if
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





##############################
### テキストから時間
##############################
to doGetText2Date({argDateText, argDateFormat})
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	set ocidTimeZone to refMe's NSTimeZone's alloc()'s initWithName:"Asia/Tokyo"
	ocidNSDateFormatter's setTimeZone:(ocidTimeZone)
	ocidNSDateFormatter's setDateFormat:(argDateFormat)
	set ocidDateAndTime to ocidNSDateFormatter's dateFromString:(argDateText)
	return ocidDateAndTime
end doGetText2Date

##############################
### 今の日付日間　テキスト
##############################
to doGetDateNo(argDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	set ocidTimeZone to refMe's NSTimeZone's alloc()'s initWithName:"Asia/Tokyo"
	ocidNSDateFormatter's setTimeZone:(ocidTimeZone)
	ocidNSDateFormatter's setDateFormat:(argDateFormat)
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo


##############################
### 明日の日付時間　テキスト
##############################
to doGetNextDateNo(argDateFormat)
	####日付情報の取得
	set ocidNowDate to current application's NSDate's |date|()
	####カレンダー初期化
	set ocidNowCalendar to refMe's NSCalendar's alloc()'s initWithCalendarIdentifier:(refMe's NSGregorianCalendar)
	####日付時間コンポーネント
	set ocidDateComponent to refMe's NSDateComponents's alloc()'s init()
	####１日足す
	ocidDateComponent's setDay:(1)
	####カレンダーオプション
	set ocidOption to (refMe's NSCalendarWrapComponents)
	####今のカレンダーにコンポーネント分の値を追加する
	set ocidNextDate to ocidNowCalendar's dateByAddingComponents:ocidDateComponent toDate:(ocidNowDate) options:(ocidOption)
	#####テキスト出力
	###日付のフォーマットを定義
	set ocidNSDateFormatter to refMe's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"en_US_POSIX")
	set ocidTimeZone to refMe's NSTimeZone's alloc()'s initWithName:"Asia/Tokyo"
	ocidNSDateFormatter's setTimeZone:(ocidTimeZone)
	ocidNSDateFormatter's setDateFormat:(argDateFormat)
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:(ocidNextDate)
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetNextDateNo

##############################
### 明日の日付時間　コンポーネント
##############################
to doGetNextDateComponents()
	####日付情報の取得
	set ocidNowDate to current application's NSDate's |date|()
	####カレンダー初期化
	set ocidNowCalendar to refMe's NSCalendar's alloc()'s initWithCalendarIdentifier:(refMe's NSGregorianCalendar)
	####日付時間コンポーネント
	set ocidDateComponent to refMe's NSDateComponents's alloc()'s init()
	####１日足す
	ocidDateComponent's setDay:(1)
	####カレンダーオプション
	set ocidOption to (refMe's NSCalendarWrapComponents)
	####今のカレンダーにコンポーネント分の値を追加する
	set ocidNextDate to ocidNowCalendar's dateByAddingComponents:ocidDateComponent toDate:(ocidNowDate) options:(ocidOption)
end doGetNextDateComponents
