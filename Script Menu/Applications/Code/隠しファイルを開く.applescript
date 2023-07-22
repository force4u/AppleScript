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

###ファイルマネージャーとワークスペースを初期化
set appFileManager to refMe's NSFileManager's defaultManager()
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()

###オープンするアプリケーションのUTI
set strBundleID to "com.microsoft.VSCode"

###ダイアログのデフォルトロケーション
set ocidHomeDirURL to appFileManager's homeDirectoryForCurrentUser()
set aliasDefaultLocation to (ocidHomeDirURL's absoluteURL()) as alias

####ダイアログ用の表示UTI
set listChooseFileUTI to {"public.item"}
####ダイアログ用のプロンプトテキスト
set strPromptText to "ファイルを選んでください" as text
###ダイアログ
set aliasFilePath to (choose file with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with invisibles and showing package contents without multiple selections allowed) as alias

###戻り値をNSURLにしておく
set strFilePath to POSIX path of aliasFilePath
set ocidFilePath to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePath's stringByExpandingTildeInPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false
###エリアスに
set aliasFilePath to (ocidFilePathURL's absoluteURL()) as alias
###開く
tell application id strBundleID
	activate
	open file aliasFilePath
end tell


(* この方法はうまくいかなかった

###取得したURLをopenURL用のArrayを作って格納
set ocidOpenURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidOpenURLArray's addObject:(ocidFilePathURL)
####アプリケーションのUTIからアプリケーションのパスを取得
set ocidAppPathURL to appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)

####ワークスペースのOPEN設定コンフィグレーション
set ocidOpenConfiguration to refMe's NSWorkspaceOpenConfiguration's configuration()
ocidOpenConfiguration's setHides:(false as boolean)
ocidOpenConfiguration's setRequiresUniversalLinks:(false as boolean)
####開く
appSharedWorkspace's openURLs:(ocidOpenURLArray) withApplicationAtURL:(ocidAppPathURL) configuration:ocidOpenConfiguration completionHandler:(missing value)
return "NSWorkspaceで起動しました"
*)
