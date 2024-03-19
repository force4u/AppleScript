#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#　
#com.cocolog-nifty.quicktimer.icefloe
#　新規でステッキーズを生成します　色や文言はカスタマイズして利用してください
(*
v2 ZOrderの値を修正した


*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()
#
tell application id "com.apple.Stickies"
	quit
end tell
delay 0.5
#表示するテキスト
set strSetValue to ("新しいステッキーズ") as text
#アトリビュートテキストを生成する
set ocidAttarString to refMe's NSMutableAttributedString's alloc()'s initWithString:(strSetValue)
#セットするDICT
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
#フォントサイズ
#フォントファミリー指定はスタイル入りで
set ocidFont to refMe's NSFont's fontWithName:("BIZ UDPGothic Bold") |size|:(18)
#システムフォント指定
#set ocidFont to refMe's NSFont's boldSystemFontOfSize:(18)
ocidAttrDict's setObject:(ocidFont) forKey:(refMe's NSFontAttributeName)
#色指定
#set ocidSetColor to refMe's NSColor's colorWithDisplayP3Red:1.0 green:0 blue:0 alpha:1.0
#set ocidSetColor to refMe's NSColor's colorWithCalibratedRed:0.044 green:0.378 blue:0.673 alpha:1.0
set ocidSetColor to refMe's NSColor's grayColor()
ocidAttrDict's setObject:(ocidSetColor) forKey:(refMe's NSForegroundColorAttributeName)
#
set ocidRange to refMe's NSMakeRange(0, (ocidAttarString's |length|))
ocidAttarString's addAttributes:(ocidAttrDict) range:(ocidRange)

set ocidAttarData to ocidAttarString's RTFFromRange:(ocidRange) documentAttributes:(missing value)
#UUID＝rtfdファイル名=ディレクトリ名
set ocidConcreteUUID to refMe's NSUUID's UUID()
set ocidUUIDString to ocidConcreteUUID's UUIDString()
#ファイル名は固定
set strFileName to ("TXT.rtf") as text
#保存先ディレクトリ
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Containers/com.apple.Stickies/Data/Library/Stickies") isDirectory:(true)
#rtfdファイル＝ディレクトリのURL
set ocidUUIDDirPathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:(false)
set ocidRtfdDirPathURL to ocidUUIDDirPathURL's URLByAppendingPathExtension:("rtfd")
#ディレクトリを作る　アクセス権755
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidRtfdDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#RTFデータの保存先
set ocidSaveDilePathURL to ocidRtfdDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:(false)
#アトリビュートテキストのDATAを保存
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidAttarData's writeToURL:(ocidSaveDilePathURL) options:(ocidOption) |error|:(reference)
if (item 1 of listDone) is false then
	return "保存に失敗しました"
end if
################################
#PLIST　設定ファイルの読み込み
set ocidPlistFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(".SavedStickiesState") isDirectory:(false)
set ocidPlistArray to refMe's NSMutableArray's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL)
set numCntArray to (count of ocidPlistArray) as integer
#追加するDICT＝新しいステっキーズのデータ
set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
#数値系 前後関係のINDEX
set numSetValue to (numCntArray) as integer
ocidAddDict's setValue:(numSetValue) forKey:("ZOrder")
#開いているのが１　閉じているのが０
set numSetValue to (0) as integer
ocidAddDict's setValue:(numSetValue) forKey:("ExpandFrameY")
#日本語スペルチェックは無いのでデフォルト値
set numSetValue to (8455) as integer
ocidAddDict's setValue:(numSetValue) forKey:("SpellCheckingTypes")
#テキスト系
ocidAddDict's setValue:(ocidUUIDString) forKey:("UUID")
#開いた時のサイズ
ocidAddDict's setValue:("{300, 200}") forKey:("ExpandedSize")
#ポジション　左上原点 xy wh
ocidAddDict's setValue:("{{30, 335}, {300, 200}}") forKey:("Frame")
#BOOL系
set ocidBool to (refMe's NSNumber's numberWithBool:false)
ocidAddDict's setValue:(ocidBool) forKey:("Translucent")
set ocidBool to (refMe's NSNumber's numberWithBool:true)
ocidAddDict's setValue:(ocidBool) forKey:("Floating")
#色データはテキスト形式のDICTを個別で作成　
#ControlColor
set ocidSetObjectDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set numSetValue to (0.859) as number
ocidSetObjectDict's setValue:(numSetValue) forKey:("Red")
set numSetValue to (0.772) as number
ocidSetObjectDict's setValue:(numSetValue) forKey:("Green")
set numSetValue to (0.012) as number
ocidSetObjectDict's setValue:(numSetValue) forKey:("Blue")
set numSetValue to (1) as integer
ocidSetObjectDict's setValue:(numSetValue) forKey:("Alpha")
ocidAddDict's setObject:(ocidSetObjectDict) forKey:("ControlColor")
#HighlightColor
set ocidSetObjectDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set numSetValue to (0.737) as number
ocidSetObjectDict's setValue:(numSetValue) forKey:("Red")
set numSetValue to (0.662) as number
ocidSetObjectDict's setValue:(numSetValue) forKey:("Green")
set numSetValue to (0.007) as number
ocidSetObjectDict's setValue:(numSetValue) forKey:("Blue")
set numSetValue to (1) as integer
ocidSetObjectDict's setValue:(numSetValue) forKey:("Alpha")
ocidAddDict's setObject:(ocidSetObjectDict) forKey:("HighlightColor")
#SpineColor
set ocidSetObjectDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set numSetValue to (0.997) as number
ocidSetObjectDict's setValue:(numSetValue) forKey:("Red")
set numSetValue to (0.917) as number
ocidSetObjectDict's setValue:(numSetValue) forKey:("Green")
set numSetValue to (0.239) as number
ocidSetObjectDict's setValue:(numSetValue) forKey:("Blue")
set numSetValue to (1) as integer
ocidSetObjectDict's setValue:(numSetValue) forKey:("Alpha")
ocidAddDict's setObject:(ocidSetObjectDict) forKey:("SpineColor")
#StickyColor
set ocidSetObjectDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set numSetValue to (0.996) as number
ocidSetObjectDict's setValue:(numSetValue) forKey:("Red")
set numSetValue to (0.956) as number
ocidSetObjectDict's setValue:(numSetValue) forKey:("Green")
set numSetValue to (0.611) as number
ocidSetObjectDict's setValue:(numSetValue) forKey:("Blue")
set numSetValue to (1) as integer
ocidSetObjectDict's setValue:(numSetValue) forKey:("Alpha")
ocidAddDict's setObject:(ocidSetObjectDict) forKey:("StickyColor")
#作成した設定を読み込んだPLITに追加
ocidPlistArray's addObject:(ocidAddDict)
#SavedStickiesStateはテキスト形式のXMLなのでXML形式で保存
set ocidNSbplist to refMe's NSPropertyListXMLFormat_v1_0
set listPlistData to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistArray) format:ocidNSbplist options:0 |error|:(reference)
set ocidPlistEditData to (item 1 of listPlistData)
###この場合は上書き
set listDone to ocidPlistEditData's writeToURL:(ocidPlistFilePathURL) options:0 |error|:(reference)
if (item 1 of listDone) is false then
	return "保存に失敗しました"
end if

delay 0.5
tell application id "com.apple.Stickies"
	activate
end tell
