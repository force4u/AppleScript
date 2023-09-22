#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

################################
##### パス関連
################################
###ファイル名用に時間を取得する
set strDateno to doGetDateNo("yyyyMMddhhmmss") as text
###保存先
set strFilePath to "~/Desktop/image-" & strDateno & ".tiff" as text
set ocidFilePathStr to refMe's NSString's stringWithString:strFilePath
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false

################################
######ペーストボードを取得
################################
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
####タイプを取得
set ocidPastBoardTypeArray to ocidPasteboard's types
log ocidPastBoardTypeArray as list
#####イメージがあれば
set boolContain to ocidPastBoardTypeArray's containsObject:"public.tiff"
if boolContain is true then
	set ocidTiffData to ocidPasteboard's dataForType:(refMe's NSPasteboardTypeTIFF)
else
	return "イメージ以外なので中止"
end if
################################
#####NSimageにして
################################
set ocidImageData to refMe's NSImage's alloc()'s initWithData:ocidTiffData
set ocidTffRep to ocidImageData's TIFFRepresentation
################################
##### 保存
################################
#####TIFF限定ならdataForTypeで取得したデータをそのまま保存でもOK
## set boolFileWrite to (ocidTiffData's writeToURL:ocidFilePathURL atomically:true)
#####保存(PNG変換等も考えて今回はNSImage経由にしてみた)
set boolFileWrite to (ocidTffRep's writeToURL:ocidFilePathURL atomically:true)

################################
##### ファイル名用の時間
################################
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