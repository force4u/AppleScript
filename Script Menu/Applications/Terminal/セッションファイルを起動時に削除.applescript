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


###ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
###ひとつ階層上
set ocidContainerDirPathURL to ocidTempDirURL's URLByDeletingLastPathComponent()
set ocidCleanupDirPathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("Cleanup At Startup")
##起動時に削除するフォルダを作成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidCleanupDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#####zsh_sessionsのパス
set ocidHomeDirURL to appFileManager's homeDirectoryForCurrentUser()
set ocidSessionsDirPathURL to ocidHomeDirURL's URLByAppendingPathComponent:(".zsh_sessions")
set strSessionsDirPath to (ocidSessionsDirPathURL's |path|()) as text
####コマンド整形
set strCommandText to ("/usr/bin/touch  \"" & strSessionsDirPath & "\"")
set ocidCommandText to refMe's NSString's stringWithString:(strCommandText)
set ocidTermTask to refMe's NSTask's alloc()'s init()
ocidTermTask's setLaunchPath:"/bin/zsh"
ocidTermTask's setArguments:({"-c", ocidCommandText})
set listDoneReturn to ocidTermTask's launchAndReturnError:(reference)
###現在のzsh_sessionsをゴミ箱に
set listResult to (appFileManager's trashItemAtURL:(ocidSessionsDirPathURL) resultingItemURL:(missing value) |error|:(reference))
###起動時に削除する項目にシンボリックリンクを作成する
set listResult to appFileManager's createSymbolicLinkAtURL:(ocidSessionsDirPathURL) withDestinationURL:(ocidCleanupDirPathURL) |error|:(reference)

return
