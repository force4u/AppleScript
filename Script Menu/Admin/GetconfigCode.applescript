#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#モデル名を取得します
#例："MacBook Pro (13-inch, M1, 2020)"
# BaseURL https://checkcoverage.apple.com
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

set strLocale to "ja_JP"


property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()
#################################################
######ファイル保存先 書類＞＞Apple >> IOPlatformUUID
#################################################
set ocidUserLibraryPathArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidFilePathURL to ocidUserLibraryPathArray's objectAtIndex:0
set ocidSaveDirPathURL to ocidFilePathURL's URLByAppendingPathComponent:"Apple/IOPlatformUUID"
############################
#####属性
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
############################
###フォルダを作る
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#####################################
######PLISTパス
#####################################
set ocidFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:"ioreg.plist"
set strFilePath to (ocidFilePathURL's |path|()) as text
###古いファイルはゴミ箱に
set boolResults to (appFileManager's trashItemAtURL:ocidFilePathURL resultingItemURL:(missing value) |error|:(reference))

#####################################
set strCommandText to "/usr/sbin/ioreg -c IOPlatformExpertDevice -a " as text
set strPlistData to (do shell script strCommandText) as text
###戻り値をストリングに
set ocidPlistStrings to refMe's NSString's stringWithString:strPlistData
###NSDATAにして
set ocidPlisStringstData to ocidPlistStrings's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
###ファイルに書き込み(使い回し用）-->不要な場合は削除して
ocidPlisStringstData's writeToURL:ocidFilePathURL atomically:true
###PLIST初期化して
set listResults to refMe's NSPropertyListSerialization's propertyListWithData:(ocidPlisStringstData) options:0 format:(refMe's NSPropertyListXMLFormat_v1_0) |error|:(reference)
###シリアル番号を取得する
set ocidPlistDataArray to item 1 of listResults
set ocidDeviceSerialNumberArray to (ocidPlistDataArray's valueForKeyPath:"IORegistryEntryChildren.IOPlatformSerialNumber")
set ocidDeviceSerialNumber to ocidDeviceSerialNumberArray's firstObject()
###configCodeにする（後ろから４文字）
set intTextlength to (ocidDeviceSerialNumber's |length|) as integer
set ocidRenge to refMe's NSMakeRange((intTextlength - 4), 4)
set strConfigCode to (ocidDeviceSerialNumber's substringWithRange:(ocidRenge)) as text

###################################################
######URLを整形する
set strURL to "https://support-sp.apple.com/sp/product"
set ocidURLStr to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's URLWithString:(ocidURLStr)
####コンポーネント
set ocidComponents to refMe's NSURLComponents's alloc()'s initWithURL:(ocidURL) resolvingAgainstBaseURL:false
set ocidComponentArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
##JSON指定
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("cc") value:(strConfigCode)
ocidComponentArray's addObject:(ocidQueryItem)
#####アーティスト名から artist idを取得する
set ocidQueryItem to (refMe's NSURLQueryItem's alloc()'s initWithName:("lang") value:(strLocale))
(ocidComponentArray's addObject:(ocidQueryItem))
###検索クエリーとして追加
(ocidComponents's setQueryItems:(ocidComponentArray))
####コンポーネントをURLに展開
set ocidNewURL to ocidComponents's |URL|()
log ocidNewURL's absoluteString() as text



###XML読み込み
set ocidOption to (refMe's NSXMLDocumentTidyXML)
set listReadXMLDoc to refMe's NSXMLDocument's alloc()'s initWithContentsOfURL:(ocidNewURL) options:(ocidOption) |error|:(reference)
set ocidReadXMLDoc to (item 1 of listReadXMLDoc)
###ROOTエレメント
set ocidRootElement to ocidReadXMLDoc's rootElement()
###子要素の数
set numCntChild to ocidRootElement's childCount() as integer
###第一階層だけの子要素
repeat with numCntChild from 0 to (numCntChild - 1)
	log (ocidRootElement's childAtIndex:numCntChild)'s |name| as text
	log (ocidRootElement's childAtIndex:numCntChild)'s stringValue as text
end repeat
set ocidConfigCode to ocidRootElement's elementsForName:"configCode"
log ocidConfigCode's stringValue as text



################################
######ダイアログ
################################
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

set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.imac-g4-20.icns" as alias
try
	set recordResponse to (display dialog "モデル名です" with title "モデル名" default answer (ocidConfigCode's stringValue as text) buttons {"クリップボードにコピー", "OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 20 without hidden answer)
	
on error
	log "エラーしました"
	return "エラーしました"
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else if button returned of recordResponse is "クリップボードにコピー" then
	set strText to text returned of recordResponse as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	##結果をペーストボードにテキストで入れる
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	return
else
	log "キャンセルしました"
	return "キャンセルしました"
end if


return (ocidConfigCode's stringValue as text)
