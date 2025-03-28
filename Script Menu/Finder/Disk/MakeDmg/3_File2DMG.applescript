#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　書き出す…からアプリケーションで書き出せば　ドロップレットとしても使えます
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

on run
	#############################
	###【起動処理】Wクリックした場合　スクリプトから実行した場合
	set appFileManager to refMe's NSFileManager's defaultManager()
	###ダイアログ
	tell current application
		set strName to name as text
	end tell
	###スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	### デフォルトロケーション
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
	set ocidFontsDirPathURL to (ocidLibraryDirPathURL's URLByAppendingPathComponent:("Fonts") isDirectory:true)
	set aliasDefaultLocation to (ocidFontsDirPathURL's absoluteURL()) as alias
	###ダイアログ
	set strMes to "選択したファイルをDMGイメージファイルに変換します。"
	set strPrompt to "選択したファイルをDMGイメージファイルに変換します。"
	set listUTI to {"public.item"}
	set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles, multiple selections allowed and showing package contents) as list
	open listAliasFilePath
	
end run



on open listAliasFilePath
	#############################
	###【事前処理】　最終的にゴミ箱に入れるテンポラリフォルダの制定
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
	repeat with itemAliasFilePath in listAliasFilePath
		#############################
		###【１】　入力パス
		set aliasFilePath to itemAliasFilePath as alias
		set strFilePath to (POSIX path of aliasFilePath) as text
		set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true)
		
		#############################
		###【２】ファイル　の場合　とフォルダの場合の
		###ファイルがドロップされた場合対応
		set listBoolIsDir to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		###分岐
		if (item 2 of listBoolIsDir) = (refMe's NSNumber's numberWithBool:false) then
			log "ファイルの場合"
			set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
			set ocidBaseFileName to ocidBaseFilePathURL's lastPathComponent()
			set strDMGname to ((ocidBaseFileName as text) & ".dmg") as text
			set strDmgVolumeName to ocidBaseFileName as text
			set strFolderName to ocidBaseFileName as text
			set strDistName to (ocidFilePathURL's lastPathComponent()) as text
		else
			###フォルダの場合
			###フォルダの名前
			set recordFileInfo to info for aliasFilePath
			set strFolderName to (name of recordFileInfo) as text
			set strDMGname to (strFolderName & ".dmg") as text
			set strDmgVolumeName to strFolderName as text
			set strDistName to strFolderName as text
		end if
		
		#############################
		###【３】テンポラリー内のDMGの本体になるフォルダ
		###DMGになるフォルダ保存パス
		set ocidMakeTmpDirPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strFolderName) isDirectory:true)
		###コマンド用のパス
		set strMakeDmgDirPath to ocidMakeTmpDirPathURL's |path| as text
		###フォルダを作る
		set listDone to (appFileManager's createDirectoryAtURL:(ocidMakeTmpDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		
		#############################
		###【４】最終的にDMGを移動するパス
		###元ディレクトリのコンテナ
		set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
		set aliasContainerDirPath to (ocidContainerDirPathURL's absoluteURL()) as alias
		###DMGのURL
		set ocidMoveDmgPathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:(strDMGname) isDirectory:false)
		
		#############################
		###【5】３で生成したフォルダに１の内容をコピーするためのURL
		###元フォルダをコピーする先のURL
		set ocidCopyItemDirPathURL to (ocidMakeTmpDirPathURL's URLByAppendingPathComponent:(strDistName) isDirectory:true)
		###元ディレクトリをコピーする
		set listDone to (appFileManager's copyItemAtURL:(ocidFilePathURL) toURL:(ocidCopyItemDirPathURL) |error|:(reference))
		
		#############################
		###【６】コマンド生成するDMGのパス
		set ocidDmgPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strDMGname) isDirectory:false)
		set strDmgPath to (ocidDmgPathURL's |path|()) as text
		
		###
		delay 1
		#############################
		###【７】コマンド実行
		(*	
■■■フォーマットオプションについて
"UDRW:read/write"
"UDRO:read-only"
###圧縮あり
"UDCO:ADC-comp"
"UDZO:zlib-comp"
"ULFO:lzfse-comp"
"ULMO:lzma-comp"
"UDBZ:bzip2-comp"
###用途別
"UDTO:master"
"UDSP:SPARSE"
"UDSB:SPARSEBUNDLE"
"UFBI:MD5checksum"
"UNIV:HFS+/ISO/UDF"
"SPARSEBUNDLE:SPARSEBUNDLE"
"SPARSE:SPARSE Disk image"
"UDIF:read/write"

set strCommandText to ("hdiutil create -volname �"" & strDmgVolumeName & "�" -srcfolder �"" & strMakeDmgDirPath & "�" -ov -format XXXXXXXXXX  �"" & strDmgPath & "�"") as text

■■■ファイルシステムを指定する場合
"HFS+:通常拡張"
"HFS+J:ジャーナリング"
"HFSX:大小文字判別"
"JHFS+X:ジャーナリング大小文字判別"
"APFS:現行macOS10.13以上"
"Case-sensitive APFS:APFS大小文字判別"
"MS-DOS:Windows互換汎用FAT"
"MS-DOS FAT12:Windows互換汎用FAT12"
"MS-DOS FAT16:Windows互換汎用FAT16"
"FAT32:Windows互換汎用"
"ExFAT:Windows互換推奨"
"UDF:ディスクマスター用"

set strCommandText to ("hdiutil create -volname �"" & strDmgVolumeName & "�" -srcfolder �"" & strMakeDmgDirPath & "�" -ov -format UDRO -fs XXXXXXXXXXXX  -layout 'MBRSPUD' �"" & strDmgPath & "�"") as text

		*)
		
		###読み取り専用
		set strCommandText to ("hdiutil create -volname �"" & strDmgVolumeName & "�" -srcfolder �"" & strMakeDmgDirPath & "�" -ov -format UDRO �"" & strDmgPath & "�"") as text
		
		
		log strCommandText
		do shell script strCommandText
		
		###【８】４のURLに生成されたDMGファイルを　６のURLに移動する
		set listDone to (appFileManager's moveItemAtURL:(ocidDmgPathURL) toURL:(ocidMoveDmgPathURL) |error|:(reference))
		
		
	end repeat
	####DMG作成処理が終わったら
	###保存先を開く
	(*
	tell application "Finder"
		open aliasContainerDirPath
	end tell
	*)
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set boolDone to appSharedWorkspace's selectFile:(ocidMoveDmgPathURL's |path|()) inFileViewerRootedAtPath:(ocidContainerDirPathURL's |path|())
	
	####中間ファイルをゴミ箱に
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSTrashDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidTrashURL to ocidURLsArray's firstObject()
	set ocidMoveTrashDirURL to (ocidTrashURL's URLByAppendingPathComponent:(strFolderName) isDirectory:true)
	set listDone to appFileManager's trashItemAtURL:(ocidSaveDirPathURL) resultingItemURL:(ocidMoveTrashDirURL) |error|:(reference)
	
	
	
end open



