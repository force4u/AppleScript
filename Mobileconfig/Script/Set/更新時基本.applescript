#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
UUIDが違うと、同じ設定内容でも『別』となります
UUID変更時は古い設定を削除してから

留意
ROOTのPayloadIdentifierは　ファイル名を使います
『ファイル名の命名』には留意ください
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
		##ファイル名
		set ocidFileName to ocidFilePathURL's lastPathComponent()
		##拡張子を除いたbasename
		set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
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
			(*
			PayloadContent Array内の　PayloadIdentifierは
			PayloadType . PayloadUUID にする
			*)
			####PayloadTypeを取得して
			set strPayloadType to (itemPayloadContentArray's valueForKey:"PayloadType") as text
			###UUID生成
			set ocidUUID to refMe's NSUUID's alloc()'s init()
			set strUUID to ocidUUID's UUIDString as text
			###PayloadUUIDにセット
			(itemPayloadContentArray's setValue:(strUUID) forKey:("PayloadUUID"))
			###PayloadType＋UUIDを
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
		
		########################
		####PayloadDescription 現在のタイプを取得して
		set strPayloadDescription to (ocidPlistDict's valueForKey:"PayloadDescription") as text
		###未設定なら設定する 最後に取得した PayloadType を設定する
		if strPayloadDescription is "missing value" then
			(ocidPlistDict's setValue:(strPayloadType) forKey:("PayloadDescription"))
		end if
		########################
		####TargetDeviceType 現在のタイプを取得して
		set strTargetDeviceType to (ocidPlistDict's valueForKey:"TargetDeviceType") as text
		###未設定なら設定する 指定する場合はここで　指定しない場合は０を入れる
		(*
0 = Any/unspecified
1 = iPhone/iPad/iPod Touch
2 = Apple Watch
3 = HomePod
4 = Apple TV
5 = Mac
*)
		if strTargetDeviceType is "missing value" then
			(ocidPlistDict's setValue:(refMe's NSNumber's numberWithInteger:0) forKey:("TargetDeviceType"))
		end if
		########################
		####PayloadScope 現在のタイプを取得して
		set strPayloadScope to (ocidPlistDict's valueForKey:"PayloadScope") as text
		###未設定なら設定する 最後に取得した Userを指定する
		if strPayloadScope is "missing value" then
			(ocidPlistDict's setValue:("User") forKey:("PayloadScope"))
		end if
		
		
		
		########################
		####ConsentText
		
		if strPayloadScope is "User" then
			set strAddText to ("この設定は削除してもかまいません") as text
			set strAddTextEn to ("This setting can be removed without issue.") as text
		else
			set strAddText to ("この設定は削除しないでください\n設定には管理者パスワードが必要です") as text
			set strAddTextEn to ("Please do not delete this setting.\nAdministrator password is required for this configuration.") as text
		end if
		set strConsentText to (ocidPlistDict's valueForKey:"ConsentText") as text
		###未設定なら設定する 最後に取得した PayloadType を設定する
		if strConsentText is "missing value" then
			set ocidConsentTextDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
			set strValue to (strPayloadType & " 初期設定 (default)\n" & strAddText & "\n") as text
			(ocidConsentTextDict's setValue:(strValue) forKey:("default"))
			set strValue to (strPayloadType & " Preferences (en)\n" & strAddTextEn & "\n") as text
			(ocidConsentTextDict's setValue:(strValue) forKey:("en"))
			set strValue to (strPayloadType & " 初期設定 (ja)\n" & strAddText & "\n") as text
			(ocidConsentTextDict's setValue:(strValue) forKey:("ja"))
			(ocidPlistDict's setObject:(ocidConsentTextDict) forKey:("ConsentText"))
		end if
		########################
		####PayloadDisplayName 現在のタイプを取得して
		set strPayloadDisplayName to (ocidPlistDict's valueForKey:"PayloadDisplayName") as text
		###未設定なら設定する 最後に取得した Userを指定する
		if strPayloadDisplayName is "missing value" then
			(ocidPlistDict's setValue:(strPayloadType) forKey:("PayloadDisplayName"))
		else if strPayloadDisplayName contain "Untitled" then
			(ocidPlistDict's setValue:(strPayloadType) forKey:("PayloadDisplayName"))
		end if
		
		
		########################
		####PayloadOrganization 現在のタイプを取得して
		set strPayloadOrganization to (ocidPlistDict's valueForKey:"PayloadOrganization") as text
		###未設定なら設定する
		if strPayloadOrganization is "missing value" then
			(ocidPlistDict's setValue:(strOrganization) forKey:("PayloadOrganization"))
		end if
		########################
		####HasRemovalPasscode 現在のタイプを取得して
		set strHasRemovalPasscode to (ocidPlistDict's valueForKey:"HasRemovalPasscode") as text
		###未設定なら設定する
		if strHasRemovalPasscode is "missing value" then
			(ocidPlistDict's setValue:(refMe's NSNumber's numberWithBool:false) forKey:("HasRemovalPasscode"))
		end if
		########################
		####PayloadRemovalDisallowed 現在のタイプを取得して
		set strPayloadRemovalDisallowed to (ocidPlistDict's valueForKey:"PayloadRemovalDisallowed") as text
		###未設定なら設定する
		if strPayloadRemovalDisallowed is "missing value" then
			(ocidPlistDict's setValue:(refMe's NSNumber's numberWithBool:false) forKey:("PayloadRemovalDisallowed"))
		end if
		
		########################
		####UUID生成
		set ocidUUID to refMe's NSUUID's alloc()'s init()
		set strUUID to ocidUUID's UUIDString as text
		###PayloadUUIDにセット
		(ocidPlistDict's setValue:(strUUID) forKey:("PayloadUUID"))
		(*
		ROOTのPayloadIdentifierは
		コマンドライン
		/usr/bin/profiles list　の戻り値になるので
		運用上『ファイル名』に紐づく（どの設定ファイルか？）がわかるようにする
		ここでは、ファイル名 . UUID　をPayloadIdentifierとして採用している
		*)
		##拡張子を除いたbasename　をPayloadIdentifier
		set strBaseFileName to ocidBaseFileName as text
		set strPayloadIdentifier to (strBaseFileName & "." & strUUID) as text
		###組織名＋UUIDを　PayloadIdentifier
		#		set strPayloadIdentifier to (strPayloadType & "." & strUUID) as text
		###PayloadType名＋UUIDを　PayloadIdentifier
		###PayloadContentのArrayの最後に取得したstrPayloadTypeが入る
		#		set strPayloadIdentifier to (strPayloadType & "." & strUUID) as text	
		###PayloadIdentifierにセット
		(ocidPlistDict's setValue:(strPayloadIdentifier) forKey:("PayloadIdentifier"))
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