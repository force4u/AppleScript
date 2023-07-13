#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#			作成ちゅう
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
##############################
#### 選択範囲のテキストを取得
##############################

tell application "CotEditor"
	activate
	tell application "System Events"
		tell process "CotEditor"
			tell menu bar 1
				##	click menu item "すべてを選択" of menu "編集"
				try
					click menu item "リッチテキストとしてコピー" of menu "編集"
				end try
			end tell
		end tell
	end tell
end tell
##############################
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidReadRtfStrings to ocidPasteboard's stringForType:(refMe's NSPasteboardTypeRTF)
if ocidReadRtfStrings = (missing value) then
	tell application "CotEditor"
		activate
		tell application "System Events"
			tell process "CotEditor"
				tell menu bar 1
					##		click menu item "すべてを選択" of menu "編集"
					try
						click menu item "リッチテキストとしてコピー" of menu "編集"
					end try
				end tell
			end tell
		end tell
	end tell
	set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidReadRtfStrings to ocidPasteboard's stringForType:(refMe's NSPasteboardTypeRTF)
end if
log className() of ocidReadRtfStrings as text
###
set ocidRftData to ocidReadRtfStrings's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
###アトリビュートレコード
set ocidAttarDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidKey to (refMe's NSDocumentTypeDocumentAttribute)
set ocidValue to (refMe's NSRTFTextDocumentType)
ocidAttarDict's setObject:(ocidValue) forKey:(ocidKey)

set listRtf2AttrString to refMe's NSAttributedString's alloc()'s initWithData:(ocidRftData) options:(ocidAttarDict) documentAttributes:(missing value) |error|:(reference)
set ocidRtfData to (item 1 of listRtf2AttrString)



###アトリビュートレコード
set ocidAttarDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidKey to (refMe's NSDocumentTypeDocumentAttribute)
set ocidValue to (refMe's NSHTMLTextDocumentType)
ocidAttarDict's setObject:(ocidValue) forKey:(ocidKey)
###除外リスト
set ocidKey to (refMe's NSExcludedElementsDocumentAttribute)
set ocidValue to {"doctype", "xml", "html", "body", "meta", "head", "font"} as list
ocidAttarDict's setObject:(ocidValue) forKey:(ocidKey)
###文字数数えて
set ocidLength to ocidRtfData's |length|()
set ocidDataRange to refMe's NSMakeRange(0, ocidLength)
###HTMLに
set listHTMLData to ocidRtfData's dataFromRange:(ocidDataRange) documentAttributes:(ocidAttarDict) |error|:(reference)
set ocidHTMLData to (item 1 of listHTMLData)
-->ConcreteMutableData
set ocidHTMLString to refMe's NSString's alloc()'s initWithData:(ocidHTMLData) encoding:(refMe's NSUTF8StringEncoding)
set ocidHtmlStringM to refMe's NSMutableString's alloc()'s initWithCapacity:0
ocidHtmlStringM's setString:(ocidHTMLString)

######ここから置換　ここはお好みで
set listRgex to refMe's NSRegularExpression's regularExpressionWithPattern:"margin:[^;]+;\\s*" options:(refMe's NSRegularExpressionCaseInsensitive) |error|:(reference)
set ocidRgex to (item 1 of listRgex)
set ocidLength to ocidHtmlStringM's |length|()
set ocidRange to refMe's NSMakeRange(0, ocidLength)
ocidRgex's replaceMatchesInString:(ocidHtmlStringM) options:0 range:(ocidRange) withTemplate:"margin:1px;"

######ここから置換　ここはお好みで
set listRgex to refMe's NSRegularExpression's regularExpressionWithPattern:"font:[^;]+;\\s*" options:(refMe's NSRegularExpressionCaseInsensitive) |error|:(reference)
set ocidRgex to (item 1 of listRgex)
set ocidLength to ocidHtmlStringM's |length|()
set ocidRange to refMe's NSMakeRange(0, ocidLength)
ocidRgex's replaceMatchesInString:(ocidHtmlStringM) options:0 range:(ocidRange) withTemplate:""


set strStartTag to ("<div class=\"CotEditor\" style=\"background-color: #373837;font-family: Osaka-Mono,Menlo, Monaco, 'Courier New', monospace, Menlo, Monaco, 'Courier New', monospace;font-weight: normal;font-size: 16px;line-height: 17px;padding: 5px;\">") as text
set strEndTag to ("</div>")
set strOutPutText to (strStartTag & ocidHtmlStringM & strEndTag) as text


##set strText to listUTl as text
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
#####ダイアログに戻す
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" as alias
###ダイアログ
set recordResult to (display dialog "type identifier 戻り値です" with title "uniform type identifier" default answer strOutPutText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 20 with icon aliasIconPath without hidden answer)
###クリップボードコピー
if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if

