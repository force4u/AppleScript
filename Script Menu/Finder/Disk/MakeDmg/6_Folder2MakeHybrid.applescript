#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　書き出す…からアプリケーションで書き出せば　ドロップレットとしても使えます
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application

on run
	### ダブルクリックしたら　スクリプトから実行したら
	set strMes to "選択したフォルダをDMGイメージファイルに変換します。"
	set aliasDefaultLocation to (path to fonts folder from user domain) as alias
	set listAliasDirPath to (choose folder strMes default location aliasDefaultLocation with prompt strMes with invisibles and multiple selections allowed without showing package contents) as list
	open listAliasDirPath
	
end run



on open listAliasDirPath
	#####【事前処理】最終的にゴミ箱に入れるフォルダを作る
	###テンポラリ
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidTempDirURL to appFileManager's temporaryDirectory()
	set ocidUUID to refMe's NSUUID's alloc()'s init()
	set ocidUUIDString to ocidUUID's UUIDString
	set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
	###フォルダを作る
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 777-->511 755-->493 700-->448 766-->502 
	ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
	set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	
	###エリアスの数だけ繰り返し
	repeat with itemAliasDirPath in listAliasDirPath
		###【１】入力フォルダパス
		set aliasDirPath to itemAliasDirPath as alias
		set strDirPath to (POSIX path of aliasDirPath) as text
		set ocidDirPathStr to (refMe's NSString's stringWithString:(strDirPath))
		set ocidDirPath to ocidDirPathStr's stringByStandardizingPath()
		set ocidDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDirPath) isDirectory:true)
		###ファイルがドロップされた場合対応
		set listBoolIsDir to (ocidDirPathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		if (item 2 of listBoolIsDir) = (refMe's NSNumber's numberWithBool:false) then
			log "ディレクトリ以外は処理しません"
			display alert "ディレクトリ以外は処理しません"
			return "ディレクトリ以外は処理しません"
			exit repeat
		end if
		
		###フォルダの名前
		set recordFileInfo to info for aliasDirPath
		set strFolderName to (name of recordFileInfo) as text
		set strDMGname to (strFolderName & ".iso") as text
		
		###【２】入力フォルダのコンテナディレクトリ
		set ocidContainerDirPathURL to ocidDirPathURL's URLByDeletingLastPathComponent()
		set aliasContainerDirPath to (ocidContainerDirPathURL's absoluteURL()) as alias
		
		###【３】最終的に出来上がったDMGファイルを移動させるパス
		###DMGになるフォルダ保存パス
		set ocidMoveDmgPathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:(strDMGname) isDirectory:false)
		
		###【４】テンポラリ内でDMGファイルを生成するパス
		###DMGを作成するURL
		set ocidDmgPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strDMGname) isDirectory:false)
		###コマンド用のパス
		set strDmgPath to ocidDmgPathURL's |path| as text
		
		###【５】テンポラリ内　DMGの本体となるディレクトリ　
		###DMGになるフォルダ
		set ocidMakeTmpDirPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strFolderName) isDirectory:false)
		###コマンド用のパス
		set strMakeDmgDirPath to ocidMakeTmpDirPathURL's |path| as text
		###フォルダを作る
		set listDone to (appFileManager's createDirectoryAtURL:(ocidMakeTmpDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		###【6】↑５で作ったフォルダ内に１のフォルダをコピーするためのパス
		###元フォルダをコピーする先のURL
		set ocidCopyItemDirPathURL to (ocidMakeTmpDirPathURL's URLByAppendingPathComponent:(strFolderName) isDirectory:true)
		###【７】１のURLを６のURLにコピーする
		set listDone to (appFileManager's copyItemAtURL:(ocidDirPathURL) toURL:(ocidCopyItemDirPathURL) |error|:(reference))
		###
		delay 1
		###【８】コマンド整形して実行
		set strCommandText to ("/usr/bin/hdiutil makehybrid -iso -joliet �"" & strMakeDmgDirPath & "�" -o �"" & strDmgPath & "�"") as text
		log strCommandText
		do shell script strCommandText
		delay 1
		###【９】４のURLに生成されたDMGファイルを　３のURLに移動する
		set listDone to (appFileManager's moveItemAtURL:(ocidDmgPathURL) toURL:(ocidMoveDmgPathURL) |error|:(reference))
		
	end repeat
	####DMG作成処理が終わったら
	###保存先を開く
	tell application "Finder"
		open aliasContainerDirPath
	end tell
	
	####【１０】事前処理で作ったフォルダをゴミ箱に入れる
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSTrashDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidTrashURL to ocidURLsArray's firstObject()
	set ocidMoveTrashDirURL to (ocidTrashURL's URLByAppendingPathComponent:(strFolderName) isDirectory:true)
	set listDone to appFileManager's trashItemAtURL:(ocidSaveDirPathURL) resultingItemURL:(ocidMoveTrashDirURL) |error|:(reference)
	return "処理終了"
end open



