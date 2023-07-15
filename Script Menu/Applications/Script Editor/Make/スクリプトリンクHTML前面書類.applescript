#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application



tell application "Script Editor"
	tell front document
		set strContents to contents as text
		set strName to name as text
	end tell
end tell

################################
######%エンコードする
################################
set ocidContents to refMe's NSString's stringWithString:(strContents)
########   %エンコードする
##キャラクタセットを指定
set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
###ペーストボードの内容をキャラクタセットで変換
set ocidTextEncodeAS to ocidContents's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
###可変テキストに格納しておく
set ocidEncodedText to refMe's NSMutableString's alloc()'s initWithCapacity:0
ocidEncodedText's setString:(ocidTextEncodeAS)

########   置換　％エンコードの追加処理
###置換レコード
set recordPercentMap to {|+|:"%2B", |=|:"%3D", |&|:"%26", |$|:"%24"} as record
###ディクショナリにして
set ocidPercentMap to refMe's NSDictionary's alloc()'s initWithDictionary:recordPercentMap
###キーの一覧を取り出します
set ocidAllKeys to ocidPercentMap's allKeys()
###取り出したキー一覧を順番に処理
repeat with itemAllKey in ocidAllKeys
	##キーの値を取り出して
	set ocidMapValue to (ocidPercentMap's valueForKey:itemAllKey)
	##置換
	set ocidEncodedText to (ocidEncodedText's stringByReplacingOccurrencesOfString:(itemAllKey) withString:(ocidMapValue))
	##次の変換に備える
	set ocidTextToEncode to ocidEncodedText
end repeat
set strEncodedText to ocidTextToEncode as text

################################
######HTML生成
################################
set strAsLinkText to "<a href=\"applescript://com.apple.scripteditor?action=new&amp;script=" & strEncodedText & "&amp;name=" & strName & "\" title=\"Open in Script Edito\">【スクリプトエディタで開く】</a>" as text
################################
######ダイアログ
################################


#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set strIconPath to ("/System/Applications/Utilities/Script Editor.app/Contents/Resources/AppIcon.icns") as text
set aliasIconPath to (POSIX file strIconPath) as alias
set recordResult to (display dialog "リンクボタンHTML" with title "リンクボタンHTML" default answer strAsLinkText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 20 with icon aliasIconPath without hidden answer)

if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if

