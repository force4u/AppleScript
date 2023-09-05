#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
ダイアログ部ベーススクリプト
https://www.macscripter.net/t/edit-db123s-dialog-for-use-with-asobjc/73636/2
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
#use framework "Carbon"
use framework "CoreImage"
use scripting additions

#####################
###　基本設定
##	set strHidden to ("TRUE") as text
set strHidden to ("FALSE") as text
##	set strEncryption to ("WEP") as text
set strEncryption to ("WPA") as text

#####################
### 
property refMe : a reference to current application
property appDialogWindow : missing value
property strOneTextField : missing value
property strTwoTextField : missing value
property appCancelButton : missing value
property appOkButton : missing value
property strOne : missing value
property strTwo : missing value
property appOkClicked : false
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807
#####################
### QRコード保存先　NSPicturesDirectory
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPicturesDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidPicturesDirURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidPicturesDirURL's URLByAppendingPathComponent:("QRcode/Wifi")
##フォルダ作成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#####################
###ダイアログ
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if

set dialogResult to my doShowDialog()
if dialogResult is missing value then
	return "【エラー】キャンセルしました"
end if
set strSSID to strOne of dialogResult
set strPSkey to strTwo of dialogResult
(*
1. S: SSID
2. T: WEPのセキュリティプロトコル
3. P: WIFIのパスワード
4. H: サネットワークを隠す※非推奨
5. Hidden: ネットワークを隠す※一般的ではない
6. EAP: 認証方法
7. EAP-Method:EAP認証メソッド
*)
set strQRContents to ("WIFI:S:" & strSSID & ";T:" & strEncryption & ";P:" & strPSkey & ";H:" & strHidden & ";") as text
##############################
###保存ファイル名
set strDateNo to doGetDateNo({"yyyyMMddhhmmss", 1})
set strSaveFileName to ("WIFI" & "." & strSSID & "." & strDateNo & ".png") as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
#####################
###出来上がったEventテキスト
log strQRContents
##%エンコード
set strChlEnc to doUrlEncode(strQRContents) as text
##BASE URL
set theApiUrl to "https://chart.googleapis.com/chart?" as text
##API名
set theCht to "qr" as text
##仕上がりサイズpx(72の倍数推奨)　72 144 288 360 576 720 1080
set theChs to "540x540" as text
## テキストのエンコード ガラ携対応するならSJISを選択
set theChoe to "UTF-8" as text
##誤差補正　L M Q R
set theChld to "M" as text
##URLを整形
set strURL to ("" & theApiUrl & "&cht=" & theCht & "&chs=" & theChs & "&choe=" & theChoe & "&chld=" & theChld & "&chl=" & strChlEnc & "") as text
log strURL
#####################
###　NSURL
set ocidURLString to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
#####################
###　データを読み込む
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidURL) options:(ocidOption) |error|:(reference)
set ocidReadData to (item 1 of listReadData)
set ocidOption to (refMe's NSDataWritingAtomic)
###	保存
set boolDone to ocidReadData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference)
set strFilePath to ocidSaveFilePathURL's absoluteString() as text

#####################
###サファリで開く
tell application "Safari"
	activate
	make new document with properties {name:"QR-CODE by Google API"}
	tell front window
		open location strFilePath
	end tell
end tell

#####################
### Finderで保存先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's selectFile:(ocidSaveFilePathURL's |path|()) inFileViewerRootedAtPath:(ocidSaveDirPathURL's |path|())

return true



################################
# 日付 doGetDateNo(argDateFormat,argCalendarNO)
# argCalendarNO 1 NSCalendarIdentifierGregorian 西暦
# argCalendarNO 2 NSCalendarIdentifierJapanese 和暦
################################
to doGetDateNo({argDateFormat, argCalendarNO})
	##渡された値をテキストで確定させて
	set strDateFormat to argDateFormat as text
	set intCalendarNO to argCalendarNO as integer
	###日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義（日本語）
	set ocidFormatterJP to current application's NSDateFormatter's alloc()'s init()
	###和暦　西暦　カレンダー分岐
	if intCalendarNO = 1 then
		set ocidCalendarID to (current application's NSCalendarIdentifierGregorian)
	else if intCalendarNO = 2 then
		set ocidCalendarID to (current application's NSCalendarIdentifierJapanese)
	else
		set ocidCalendarID to (current application's NSCalendarIdentifierISO8601)
	end if
	set ocidCalendarJP to current application's NSCalendar's alloc()'s initWithCalendarIdentifier:(ocidCalendarID)
	set ocidTimezoneJP to current application's NSTimeZone's alloc()'s initWithName:("Asia/Tokyo")
	set ocidLocaleJP to current application's NSLocale's alloc()'s initWithLocaleIdentifier:("ja_JP_POSIX")
	###設定
	ocidFormatterJP's setTimeZone:(ocidTimezoneJP)
	ocidFormatterJP's setLocale:(ocidLocaleJP)
	ocidFormatterJP's setCalendar:(ocidCalendarJP)
	# ocidFormatterJP's setDateStyle:(current application's NSDateFormatterNoStyle)
	# ocidFormatterJP's setDateStyle:(current application's NSDateFormatterShortStyle)
	# ocidFormatterJP's setDateStyle:(current application's NSDateFormatterMediumStyle)
	# ocidFormatterJP's setDateStyle:(current application's NSDateFormatterLongStyle)
	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterFullStyle)
	###渡された値でフォーマット定義
	ocidFormatterJP's setDateFormat:(strDateFormat)
	###フォーマット適応
	set ocidDateAndTime to ocidFormatterJP's stringFromDate:(ocidDate)
	###テキストで戻す
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo


---URLエンコードのサブルーチン
####################################
###### ％エンコード
####################################
on doUrlEncode(argText)
	##テキスト
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##キャラクタセットを指定
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	##キャラクタセットで変換
	set ocidArgTextEncoded to ocidArgText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	######## 置換　％エンコードの追加処理
	###置換レコード
	set recordPercentMap to {|+|:"%2B", |=|:"%3D", |&|:"%26", |$|:"%24"} as record
	###ディクショナリにして
	set ocidPercentMap to refMe's NSDictionary's alloc()'s initWithDictionary:(recordPercentMap)
	###キーの一覧を取り出します
	set ocidAllKeys to ocidPercentMap's allKeys()
	###取り出したキー一覧を順番に処理
	repeat with itemAllKey in ocidAllKeys
		##キーの値を取り出して
		set ocidMapValue to (ocidPercentMap's valueForKey:(itemAllKey))
		##置換
		set ocidEncodedText to (ocidArgTextEncoded's stringByReplacingOccurrencesOfString:(itemAllKey) withString:(ocidMapValue))
		##次の変換に備える
		set ocidArgTextEncoded to ocidEncodedText
	end repeat
	##テキスト形式に確定
	set strTextToEncode to ocidEncodedText as text
	###値を戻す
	return strTextToEncode
end doUrlEncode


####################################
###### ダイアログ
####################################

on doShowDialog()
	if refMe's AEInteractWithUser(-1, missing value, missing value) ≠ 0 then
		return missing value
	end if
	if refMe's NSThread's isMainThread() then
		my doPerformDialog:(missing value)
	else
		its performSelectorOnMainThread:("doPerformDialog:") withObject:(missing value) waitUntilDone:true
	end if
	if my appOkClicked then
		return {strOne:my strOne as text, strTwo:my strTwo as text}
	end if
	return missing value
end doShowDialog

on doPerformDialog:(args)
	set strOneLabel to refMe's NSTextField's labelWithString:("SSIS:")
	strOneLabel's setFrame:(refMe's NSMakeRect(20, 85, 70, 20))
	
	set my strOneTextField to refMe's NSTextField's textFieldWithString:""
	strOneTextField's setFrame:(refMe's NSMakeRect(87, 85, 245, 20))
	strOneTextField's setEditable:true
	strOneTextField's setBordered:true
	strOneTextField's setPlaceholderString:("WIFIのアクセスポイント名")
	strOneTextField's setDelegate:(me)
	
	set strTwoLabel to refMe's NSTextField's labelWithString:("PSKey:")
	strTwoLabel's setFrame:(refMe's NSMakeRect(20, 55, 70, 20))
	
	set my strTwoTextField to refMe's NSTextField's textFieldWithString:("")
	strTwoTextField's setFrame:(refMe's NSMakeRect(87, 55, 245, 20))
	strTwoTextField's setEditable:true
	strTwoTextField's setBordered:true
	strTwoTextField's setPlaceholderString:("接続用暗号化パスワード")
	
	set my appCancelButton to refMe's NSButton's buttonWithTitle:"Cancel" target:me action:"doButtonAction:"
	appCancelButton's setFrameSize:{94, 32}
	appCancelButton's setFrameOrigin:{150, 10}
	appCancelButton's setKeyEquivalent:(character id 27)
	
	set my appOkButton to refMe's NSButton's buttonWithTitle:"OK" target:me action:"doButtonAction:"
	appOkButton's setFrameSize:{94, 32}
	appOkButton's setFrameOrigin:{245, 10}
	appOkButton's setKeyEquivalent:return
	appOkButton's setEnabled:false
	
	set ocidWindowSize to refMe's NSMakeRect(0, 0, 355, 125)
	set ocidWinStyle to (refMe's NSWindowStyleMaskTitled as integer) + (refMe's NSWindowStyleMaskClosable as integer)
	set my appDialogWindow to refMe's NSWindow's alloc()'s initWithContentRect:(ocidWindowSize) styleMask:(ocidWinStyle) backing:(refMe's NSBackingStoreBuffered) defer:true
	
	appDialogWindow's contentView()'s addSubview:(strOneLabel)
	appDialogWindow's contentView()'s addSubview:(strOneTextField)
	appDialogWindow's contentView()'s addSubview:(strTwoLabel)
	appDialogWindow's contentView()'s addSubview:(strTwoTextField)
	appDialogWindow's contentView()'s addSubview:(appCancelButton)
	appDialogWindow's contentView()'s addSubview:(appOkButton)
	
	appDialogWindow's setTitle:"WIFI接続用QRバーコード作成"
	appDialogWindow's setLevel:(refMe's NSModalPanelWindowLevel)
	appDialogWindow's setDelegate:(me)
	appDialogWindow's orderFront:(me)
	appDialogWindow's |center|()
	
	refMe's NSApp's activateIgnoringOtherApps:true
	refMe's NSApp's runModalForWindow:(appDialogWindow)
end doPerformDialog:

on doButtonAction:(sender)
	if sender is my appOkButton then
		set my strOne to strOneTextField's stringValue()
		set my strTwo to strTwoTextField's stringValue()
		set my appOkClicked to true
	end if
	my appDialogWindow's |close|()
end doButtonAction:

on controlTextDidChange:(objNotification)
	set sender to objNotification's object()
	if sender is my strOneTextField then
		if sender's stringValue() as text ≠ "" then
			my (appOkButton's setEnabled:true)
		else
			my (appOkButton's setEnabled:false)
		end if
	end if
end controlTextDidChange:

on windowWillClose:(objNotification)
	refMe's NSApp's stopModal()
end windowWillClose:
