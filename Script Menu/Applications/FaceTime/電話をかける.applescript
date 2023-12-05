#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


########################
## クリップボードの中身取り出し
########################
##クリップボードにテキストが無い場合
set strMes to ("電話番号を入力してください") as text
###初期化
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to ocidPasteboard's types
###テキストがあれば
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	###値を格納する
	tell application "Finder"
		set strDefaultAnswer to (the clipboard as text) as text
	end tell
	###Finderでエラーしたら
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strDefaultAnswer to ocidReadString as text
	else
		log "テキストなし"
		set strDefaultAnswer to strMes as text
	end if
end if
##############################
#####ダイアログ
##############################
##前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###アイコンパス
set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
try
	set recordResult to (display dialog strMes with title "入力してください" default answer strDefaultAnswer buttons {"OK", "キャンセル"} default button "OK" with icon aliasIconPath giving up after 30 without hidden answer) as record
on error
	log "エラーしました"
	return "キャンセル"
end try

if "OK" is equal to (button returned of recordResult) then
	set strReturnedText to (text returned of recordResult) as text
else if (gave up of recordResult) is true then
	return "時間切れです"
else
	return "キャンセル"
end if

##############################
#####本処理
##############################
###NSStringに格納
set ocidResponseText to (refMe's NSString's stringWithString:(strReturnedText))
###タブと改行を除去しておく
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidTextM's appendString:(ocidResponseText)
##改行除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\n") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\r") withString:("")
##タブ除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\t") withString:("")
##半角
set ocidNSStringTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
set ocidTextM to (ocidTextM's stringByApplyingTransform:(ocidNSStringTransform) |reverse|:false)
##ハイフン除去
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("-") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("−") withString:("")
###########################
###URL整形
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
###スキーム を追加
ocidURLComponents's setScheme:("tel")
###パスを追加（setHostじゃないよ）
ocidURLComponents's setPath:(ocidTextM)
##URLに戻して テキストにしておく
set ocidOpenURL to ocidURLComponents's |URL|()
set strOpenURL to ocidOpenURL's absoluteString() as text
###########################
### OPEN URL
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appShardWorkspace's openURL:(ocidOpenURL)

return

tell application id "com.apple.FaceTime"
	open location strOpenURL
end tell
(*
##別なアプリを指定している場合
tell application "Finder"
	open location strOpenURL
end tell
*)
