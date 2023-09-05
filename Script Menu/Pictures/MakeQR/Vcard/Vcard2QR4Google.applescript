#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
(*

ICSファイルからQRコードを生成
イベント登録用のQRを作成します。
QRコードとしては、たぶんiOS専用　

20190714　初回作成
20190715 phpのエラー処理追加
20220106 phpでの％エンコードの処理をpython3に置き換え
20220122 繰り返しイベントのSEQUENCEを追加　処理を一部修正
20230828 python3の処理をocに置換
APIの仕様は
https://developers.google.com/chart/infographics/docs/qr_codes

*)
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807
#####################
### QRコード保存先　NSPicturesDirectory
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPicturesDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidPicturesDirURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidPicturesDirURL's URLByAppendingPathComponent:("QRcode/Contacts")
##フォルダ作成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#####################
###ダイアログのデフォルトロケーション
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
#######
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
set strPrompt to "QRコードを作成します。"
set strMes to "QRコードを作成します。"

set listUTI to {"public.vcard"} as list
set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI without invisibles, showing package contents and multiple selections allowed) as alias
#####################
###　ファイルのパス
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
#####################
###	テキストで読み込み
set listReadString to refMe's NSString's alloc()'s initWithContentsOfURL:(ocidFilePathURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
set ocidReadString to (item 1 of listReadString)
#####################
###	VCARDデータ整形
set strChl to "BEGIN:VCARD\nVERSION:3.0" as text
###
set ocidChrSet to refMe's NSCharacterSet's newlineCharacterSet()
set ocidStringsArray to ocidReadString's componentsSeparatedByCharactersInSet:(ocidChrSet)
###
set codiPridic to refMe's NSPredicate's predicateWithFormat_("(SELF BEGINSWITH %@)", "FN:")
set ocidFullName to ocidStringsArray's filteredArrayUsingPredicate:(codiPridic)
###
if (count of ocidFullName) = 0 then
	return "【エラー】フルネームが取得できませんでした"
else
	set ocidFullNameArray to (ocidFullName's firstObject())'s componentsSeparatedByString:(":")
	set strFullName to (last item of ocidFullNameArray) as list
	##ファイル名に開始日時を使う
	set strSaveFileName to ("VcardQR_" & strFullName & ".png") as text
	set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
	##
	set strChl to (strChl & "\n" & (ocidFullName's firstObject() as text)) as text
end if
####
set codiPridic to refMe's NSPredicate's predicateWithFormat_("(SELF BEGINSWITH %@)", "N:")
set ocidN to ocidStringsArray's filteredArrayUsingPredicate:(codiPridic)
if (count of ocidN) > 0 then
	set strChl to (strChl & "\n" & (ocidN's firstObject() as text)) as text
end if
####
set codiPridic to refMe's NSPredicate's predicateWithFormat_("(SELF CONTAINS %@)", "EMAIL;")
set ocidEMAIL to ocidStringsArray's filteredArrayUsingPredicate:(codiPridic)
if (count of ocidEMAIL) = 1 then
	set strChl to (strChl & "\n" & (ocidEMAIL's firstObject() as text)) as text
else if (count of ocidEMAIL) > 1 then
	set strChl to (strChl & "\n" & (ocidEMAIL's firstObject() as text)) as text
	set strChl to (strChl & "\n" & (ocidEMAIL's lastObject() as text)) as text
end if
##
set codiPridic to refMe's NSPredicate's predicateWithFormat_("(SELF BEGINSWITH %@)", "TEL;")
set ocidTEL to ocidStringsArray's filteredArrayUsingPredicate:(codiPridic)
if (count of ocidTEL) = 1 then
	set strChl to (strChl & "\n" & (ocidTEL's firstObject() as text)) as text
else if (count of ocidTEL) > 1 then
	set strChl to (strChl & "\n" & (ocidTEL's firstObject() as text)) as text
	set strChl to (strChl & "\n" & (ocidTEL's lastObject() as text)) as text
end if
##
set strChl to (strChl & "\n" & "END:VCARD") as text
#####################
###出来上がったEventテキスト
log strChl
##Vcardの内容テキストエンコード済み
set strChlEnc to doUrlEncode(strChl) as text
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
	set recordPercentMap to {|+|:"%2B", |=|:"%3D", |&|:"%26", |$|:"%24", |\\n|:"%0A", |\\r|:"%0D"} as record
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
