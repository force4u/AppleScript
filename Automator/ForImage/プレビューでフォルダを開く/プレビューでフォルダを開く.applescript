#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application
property strBundleID : "com.apple.Preview"




on run {listFolderPath}
	tell application "Finder"
		set strKind to (kind of (item 1 of listFolderPath)) as text
	end tell
	if strKind is not "フォルダ" then
		return "フォルダ以外は処理しない"
	end if
	
	####終了させてから処理させる
	tell application id strBundleID
		set numCntWindow to (count of every window) as integer
	end tell
	if numCntWindow = 0 then
		tell application id strBundleID
			quit
		end tell
	else
		tell application id strBundleID
			close (every window)
			quit
		end tell
	end if
	####プレビューの半ゾンビ化対策	
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate
	end repeat
	###enumeratorAtURL用のBoolean用
	set ocidFalse to (refMe's NSNumber's numberWithBool:false)
	set ocidTrue to (refMe's NSNumber's numberWithBool:true)
	###ファイルマネジャー初期化
	set appFileManager to refMe's NSFileManager's defaultManager()
	
	################################
	####フォルダの数だけ繰り返し
	################################
	###ファイルURLのみを格納するリスト
	set ocidFilePathURLAllArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
	###まずは全部のURLをArrayに入れる
	repeat with itemFolderPath in listFolderPath
		######パス フォルダのエイリアス
		set aliasDirPath to itemFolderPath as alias
		###UNIXパスにして
		set strDirPath to POSIX path of aliasDirPath as text
		###Stringsに
		set ocidDirPath to (refMe's NSString's stringWithString:strDirPath)
		###パス確定させて
		set ocidDirPath to ocidDirPath's stringByStandardizingPath
		###NSURLに
		set ocidDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidDirPath isDirectory:true)
		##################################
		##プロパティ
		set ocidPropertieKey to {refMe's NSURLPathKey, refMe's NSURLIsRegularFileKey, refMe's NSURLContentTypeKey}
		##オプション(隠しファイルは含まない)
		set ocidOption to refMe's NSDirectoryEnumerationSkipsHiddenFiles
		####ディレクトリのコンテツを収集（最下層まで）
		set ocidEmuDict to (appFileManager's enumeratorAtURL:ocidDirPathURL includingPropertiesForKeys:ocidPropertieKey options:ocidOption errorHandler:(reference))
		###戻り値をリストに格納
		set ocidEmuFileURLArray to ocidEmuDict's allObjects()
		(ocidFilePathURLAllArray's addObjectsFromArray:ocidEmuFileURLArray)
	end repeat
	################################
	####必要なファイルだけのArrayにする
	################################
	set ocidFilePathURLArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
	####URLの数だけ繰り返し
	repeat with itemFilePathURL in ocidFilePathURLAllArray
		###################不要なファイルをゴミ箱に入れちゃう
		####拡張子取って
		set ocidExtension to itemFilePathURL's pathExtension()
		###URLファイル削除
		if (ocidExtension as text) is "url" then
			set listResult to (appFileManager's trashItemAtURL:(itemFilePathURL) resultingItemURL:(missing value) |error|:(reference))
			###WindowのサムネイルDB削除
		else if (ocidExtension as text) is "db" then
			set listResult to (appFileManager's trashItemAtURL:(itemFilePathURL) resultingItemURL:(missing value) |error|:(reference))
			###webloc削除
		else if (ocidExtension as text) is "webloc" then
			set listResult to (appFileManager's trashItemAtURL:(itemFilePathURL) resultingItemURL:(missing value) |error|:(reference))
		else
			####URLをforKeyで取り出し
			set listResult to (itemFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsRegularFileKey) |error|:(reference))
			###リストからNSURLIsRegularFileKeyのBOOLを取り出し
			set boolIsRegularFileKey to item 2 of listResult
			####ファイルのみを(ディレクトリやリンボリックリンクは含まない）
			if boolIsRegularFileKey is ocidTrue then
				####リストにする
				(ocidFilePathURLArray's addObject:(itemFilePathURL))
			end if
		end if
	end repeat
	log ocidFilePathURLArray as list
	################################
	####ファイルタイプのチェックをする
	################################
	set listUTI to doGetUTI() as list
	###ファイルURLのみを格納するリスト
	set ocidFilePathURLArrayM to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
	repeat with itemFilePathURL in ocidFilePathURLArray
		####UTIの取得
		set listResourceValue to (itemFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLContentTypeKey) |error|:(reference))
		set ocidContentType to (item 2 of listResourceValue)
		set strUTI to (ocidContentType's identifier) as text
		if listUTI contains strUTI then
			(ocidFilePathURLArrayM's addObject:(itemFilePathURL))
		end if
	end repeat
	
	log ocidFilePathURLArrayM as list
	##############################
	####並び替え並び替え compare
	##############################
	(*
	compare:
	caseInsensitiveCompare:
	
	localizedCompare:
	localizedStandardCompare:
	localizedCaseInsensitiveCompare:
	*)
	
	set ocidSortDescriptor to (refMe's NSSortDescriptor's sortDescriptorWithKey:"absoluteString" ascending:(true) selector:"localizedStandardCompare:")
	
	##	set ocidSortDescriptor to (refMe's NSSortDescriptor's sortDescriptorWithKey:"absoluteString" ascending:(true) selector:"compare:")
	(ocidFilePathURLArrayM's sortUsingDescriptors:{ocidSortDescriptor})
	
	##############################
	####エリアスリストにして
	##############################
	###空のリスト＝プレヴューに渡すため
	set listAliasPath to {} as list
	###並び変わったファイルパスを順番に
	repeat with itemFilePathURL in ocidFilePathURLArrayM
		###エイリアスにして
		set aliasFilePath to (itemFilePathURL's absoluteURL()) as alias
		####リストに格納していく
		copy aliasFilePath to end of listAliasPath
	end repeat
	if listAliasPath is {} then
		return "Openできる書類はありませんでした"
	end if
	##############################
	####起動
	##############################
	try
		tell application id "com.apple.Preview" to launch
	on error
		tell application id "com.apple.Preview" to activate
	end try
	##############################
	####プレビューで開く
	##############################
	tell application id "com.apple.Preview"
		activate
		set numWindow to count of window
		if numWindow = 0 then
			try
				open listAliasPath
			on error
				log "ここでエラー"
			end try
		else
			####新しいウィンドで開く方法がわからん
			####新しいインスタンス生成すれば良いのかな
			open listAliasPath
		end if
	end tell
	
end run





to doGetUTI()
	###アプリケーションのURLを取得
	###NSバンドルをUTIから取得
	set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
	if ocidAppBundle = (missing value) then
		###NSバンドル取得できなかった場合
		set appNSWorkspace to refMe's NSWorkspace's sharedWorkspace()
		set ocidAppPathURL to appNSWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
	else
		set ocidAppPathURL to ocidAppBundle's bundleURL()
	end if
	###Plistのパス
	set ocidPlistPathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/Info.plist") isDirectory:false
	set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
	set ocidDocTypeArray to ocidPlistDict's objectForKey:"CFBundleDocumentTypes"
	if ocidDocTypeArray = (missing value) then
		set strOutPutText to "missing value" as text
	else
		####リストにする
		set listUTl to {} as list
		###対応ドキュメントタイプをリストにしていく
		repeat with itemDocTypeArray in ocidDocTypeArray
			set listContentTypes to (itemDocTypeArray's objectForKey:"LSItemContentTypes")
			if listContentTypes = (missing value) then
				###拡張子の指定のみの場合
				set ocidExtension to (itemDocTypeArray's objectForKey:"CFBundleTypeExtensions")
				set strClassName to ocidExtension's className() as text
				repeat with itemExtension in ocidExtension
					set strExtension to itemExtension as text
					set ocidContentTypes to (refMe's UTType's typeWithFilenameExtension:(strExtension))
					set strContentTypes to ocidContentTypes's identifier() as text
					set strContentTypes to ("" & strContentTypes & "") as text
					set end of listUTl to (strContentTypes)
				end repeat
			else
				repeat with itemContentTypes in listContentTypes
					set strContentTypes to ("" & itemContentTypes & "") as text
					set end of listUTl to (strContentTypes)
				end repeat
			end if
		end repeat
	end if
	return listUTl
end doGetUTI
