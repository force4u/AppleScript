#!/usr/bin/env osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

on run (argFilePathAndDistPath)

if (argFilePathAndDistPath as text) is "" then
log doPrintHelp()
return 0
else if (count of argFilePathAndDistPath)  < 2 then
log doPrintHelp()
return 0
else if (count of argFilePathAndDistPath)  = 2 then
set {argFilePath,argDistPath} to argFilePathAndDistPath
set strFilePath to argFilePath as text
set strDistFilePath to argDistPath as text
else
log doPrintHelp()
return 0
end if

set appShardWorkspace to current application's NSWorkspace's sharedWorkspace()
set appFileManager to current application's NSFileManager's defaultManager()

##元ファイル
set ocidFilePathStr to current application's NSString's stringWithString:(strFilePath)
set ocidFilePathStr to (ocidFilePathStr's stringByReplacingOccurrencesOfString:("\\ ") withString:(" "))
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (current application's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

##エイリアス作成先
set ocidDistFilePathStr to current application's NSString's stringWithString:(strDistFilePath)
set ocidDistFilePathStr to (ocidDistFilePathStr's stringByReplacingOccurrencesOfString:("\\ ") withString:(" "))
set ocidDistFilePath to ocidDistFilePathStr's stringByStandardizingPath()
set ocidDistFilePathURL to (current application's NSURL's alloc()'s initFileURLWithPath:(ocidDistFilePath) isDirectory:false)

#BOOKMARK取得
set ocidKeyArray to current application's NSMutableArray's alloc()'s initWithCapacity:(0)
ocidKeyArray's addObject:(current application's NSURLCustomIconKey)
ocidKeyArray's addObject:(current application's NSURLFileContentIdentifierKey)
ocidKeyArray's addObject:(current application's NSURLFileResourceIdentifierKey)
ocidKeyArray's addObject:(current application's NSURLPathKey)
set listResponse to (ocidFilePathURL's bookmarkDataWithOptions:(current application's NSURLBookmarkCreationSuitableForBookmarkFile) includingResourceValuesForKeys:(ocidKeyArray) relativeToURL:(missing value) |error|:(reference))
set ocdiBookMarkData to (item 1 of listResponse)
if (item 2 of listResponse) ≠ (missing value) then
set strErrorNO to (item 2 of listResponse)'s code() as text
set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
current application's NSLog("■：" & strErrorNO & strErrorMes)
return "エラーしました" & strErrorNO & strErrorMes
end if

#ICON取得
set ocidIconImage to appShardWorkspace's iconForFile:(ocidFilePath)

#BOOKMARK作成
set listDone to (current application's NSURL's writeBookmarkData:(ocdiBookMarkData) toURL:(ocidDistFilePathURL) options:(current application's NSURLBookmarkCreationSuitableForBookmarkFile) |error|:(reference))
if (item 1 of listDone) is false then
set strErrorNO to (item 2 of listDone)'s code() as text
set strErrorMes to (item 2 of listDone)'s localizedDescription() as text
current application's NSLog("■：" & strErrorNO & strErrorMes)
return "エラーしました" & strErrorNO & strErrorMes
end if

#ICON設定
set boolDone to appShardWorkspace's setIcon:(ocidIconImage) forFile:(ocidDistFilePath) options:(current application's NSExclude10_4ElementsIconCreationOption)
if boolDone is false then
return "エラーしました" & strErrorNO & strErrorMes
end if
return 0
end run


on doPrintHelp()
set strHelpText to ("
パスAのエリアス（BOOKMARK）をパスBに作成してアイコンを付与します
使用方法:
mkalias /パス/ファイルまたはフォルダ /パス/エイリアス作成先

引数:
/パス/ファイルまたはフォルダ エイリアスを作成したいパス
/パス/エイリアス エイリアスの作成先となるファイルパス

例:
mkalias.applescript /Users/example/document.txt /Users/example/document

注意:
- クイックルックアイコン（ビデオとか）は取得できません
- アイコンを付与するのでエイリアスアイコンの↗︎は表示されません

") as text
return strHelpText
end doPrintHelp