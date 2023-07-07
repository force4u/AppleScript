#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


#############################
#####ファイル選択ダイアログ
#############################
###ダイアログを前面に出す
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
###ダイアログのデフォルト
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidUserDesktopPath to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set aliasDefaultLocation to ocidUserDesktopPath as alias
set listChooseFileUTI to {"com.adobe.encapsulated-postscript", "com.adobe.postscript"}
set strPromptText to "ファイルを選んでください" as text
set listAliasFilePath to (choose file with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with invisibles and multiple selections allowed without showing package contents) as list
####複数ファイル対応
repeat with itemAliasFilePath in listAliasFilePath
	###エイリアス
	set aliasFilePath to itemAliasFilePath as alias
	###パステキスト
	set strFilePath to (POSIX path of aliasFilePath) as text
	####入力ファイルパス確定
	set strInputFilePath to strFilePath as text
	###パス
	set ocidFilePath to (refMe's NSString's stringWithString:strFilePath)
	###NSURL
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath)
	###ファイル名
	set ocidFileName to ocidFilePathURL's lastPathComponent()
	###拡張子を取ったベースファイル名
	set strBaseFileName to ocidFileName's stringByDeletingPathExtension() as text
	####入力ファイルの１階層上のフォルダURL
	set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
	####ディレクトリのURLコンポーネント
	set strContainerDirPath to ocidContainerDirPathURL's |path|() as text
	
	####出力ファイル名
	set strNewFileName to (strBaseFileName & ".pdf") as text
	####ディレクトリのURLコンポーネント
	set ocidNewFilePathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:strNewFileName)
	####ファイルの有無チェック
	set boolFileExist to (ocidNewFilePathURL's checkResourceIsReachableAndReturnError:(missing value)) as boolean
	###すでに同名ファイルがある場合は日付時間入りのファイル名
	if boolFileExist is true then
		####日付情報の取得
		set ocidDate to refMe's NSDate's |date|()
		###日付のフォーマットを定義
		set ocidNSDateFormatter to refMe's NSDateFormatter's alloc()'s init()
		(ocidNSDateFormatter's setDateFormat:"yyyyMMddhhmm")
		set ocidDateAndTime to (ocidNSDateFormatter's stringFromDate:ocidDate)
		set strDateAndTime to ocidDateAndTime as text
		####ファイル名に日付を入れる
		set strNewFilePath to (strContainerDirPath & "/" & strBaseFileName & "." & strDateAndTime & ".pdf") as text
	else
		####出力ファイルパス
		set strNewFilePath to (strContainerDirPath & "/" & strNewFileName & "") as text
	end if
	################################################
	####コマンドパス	
	set strBinPath to "/usr/bin/pstopdf"
	#####コマンド整形
	set strCommandText to ("\"" & strBinPath & "\"  \"" & strInputFilePath & "\" -o \"" & strNewFilePath & "\"") as text
	do shell script strCommandText
	(* ターミナル使いたい場合はこちら
	####ターミナルで開く
	tell application "Terminal"
		launch
		activate
		set objWindowID to (do script "\n\n")
		delay 1
		do script strCommandText in objWindowID
	end tell
	*)
end repeat


