#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#要管理者権限
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set strURL to "https://box-installers.s3.amazonaws.com/boxedit/mac/currentrelease/BoxToolsInstaller.pkg" as text

###戻り値格納用のDICT
set ocidPkgDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###URL
set ocidURLString to (refMe's NSString's stringWithString:(strURL))
###ダウンロード
set ocidURL to refMe's NSURL's URLWithString:(ocidURLString)
###ファイル名
set ocidFileName to ocidURL's lastPathComponent()
####NSDataで
set ocidPkgData to refMe's NSData's dataWithContentsOfURL:(ocidURL)
###保存先 ディレクトリ 起動時の削除される項目
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
###フォルダ作って
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###保存パス
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidFileName) isDirectory:false
###保存
set boolDone to ocidPkgData's writeToURL:(ocidSaveFilePathURL) atomically:(true)
###インストール用のパス
set strSaveFilePath to ocidSaveFilePathURL's |path|() as text
###通知のタイムラグを考慮して１秒まってから
delay 1
###コマンド整形
set strCommandText to ("/usr/sbin/installer -dumplog -verbose -pkg \"" & strSaveFilePath & "\" -target CurrentUserHomeDirectory -allowUntrusted -lang ja") as text
###実行
do shell script strCommandText
###
return "処理終了"
