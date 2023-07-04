#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

###設定項目　新規インスタンスで開くか？
property boolNewInstance : true as boolean
###開くアプリケーション
property strBundleID : "com.apple.Preview"

on run
	###デスクトップ
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidHomeDirURL to appFileManager's homeDirectoryForCurrentUser()
	set ocidDesktopDirURL to ocidHomeDirURL's URLByAppendingPathComponent:("Desktop") isDirectory:(true)
	set aliasDefaultLocation to (ocidDesktopDirURL's absoluteURL()) as alias
	set strPromptText to "画像が入ったフォルダをえらんでください"
	set strMesText to "画像が入ったフォルダをえらんでください"
	try
		set listFolderPath to (choose folder strMesText with prompt strPromptText default location aliasDefaultLocation with multiple selections allowed, invisibles and showing package contents) as list
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	open listFolderPath
end run


on open listFolderPath
	####################################
	###フォルダURLのみを格納するリスト
	####################################
	set ocidDirURLArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
	repeat with itemFolderPath in listFolderPath
		set strDirPath to POSIX path of itemFolderPath as text
		set ocidDirPathStr to (refMe's NSString's stringWithString:(strDirPath))
		set ocidDirPath to ocidDirPathStr's stringByStandardizingPath
		###NSURLに
		set ocidDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidDirPath)
		set listResourceValue to (ocidDirPathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		###ディレクトリ＝フォルダか？確認
		set boolIsDir to (item 2 of listResourceValue)
		if boolIsDir = (refMe's NSNumber's numberWithBool:true) then
			(ocidDirURLArray's addObject:(ocidDirPathURL))
		end if
	end repeat
	####################################
	###並び替えておく
	####################################
	set ocidDescriptor to (refMe's NSSortDescriptor's sortDescriptorWithKey:"absoluteString" ascending:(true) selector:"localizedStandardCompare:")
	(ocidDirURLArray's sortUsingDescriptors:{ocidDescriptor})
	(*
	####################################
	###プレビューを終了させる
	####################################
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate()
	end repeat
	repeat with itemAppArray in ocidAppArray
		itemAppArray's forceTerminate()
	end repeat
	*)
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
	repeat with itemDirURLArray in ocidDirURLArray
		###NSURLに
		set ocidDirPathURL to itemDirURLArray
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
	set ocidAppPathURL to doGetAppURL(strBundleID)
	set listUTI to doGetUTI(ocidAppPathURL) as list
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
	####並び替え並び替え
	##############################
	##		set ocidSortDescriptor to (refMe's NSSortDescriptor's sortDescriptorWithKey:"absoluteString" ascending:(true) selector:"localizedStandardCompare:")
	set ocidSortDescriptor to (refMe's NSSortDescriptor's sortDescriptorWithKey:"absoluteString" ascending:(true) selector:"compare:")
	(ocidFilePathURLArrayM's sortUsingDescriptors:{ocidSortDescriptor})
	
	
	##############################
	####プレビューで開く
	##############################
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	###新規インスタンスで開く設定
	set ocidConfig to refMe's NSWorkspaceOpenConfiguration's configuration()
	ocidConfig's setActivates:(true)
	ocidConfig's setAddsToRecentItems:(false)
	ocidConfig's setCreatesNewApplicationInstance:(boolNewInstance)
	###ファイルAを開く
	appSharedWorkspace's openURLs:(ocidFilePathURLArrayM) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidConfig) completionHandler:(missing value)
end open

##############################
####アプリケーションのURLを取得する
##############################
to doGetAppURL(arg_strBundleID)
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	##バンドルからアプリケーションのURLを取得
	set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
	if ocidAppBundle ≠ (missing value) then
		set ocidAppPathURL to ocidAppBundle's bundleURL()
	else if ocidAppBundle = (missing value) then
		set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
	end if
	##予備（アプリケーションのURL）
	if ocidAppPathURL = (missing value) then
		tell application "Finder"
			try
				set aliasAppApth to (application file id strBundleID) as alias
				set strAppPath to POSIX path of aliasAppApth as text
				set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
				set strAppPath to strAppPathStr's stringByStandardizingPath()
				set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
			on error
				return "アプリケーションが見つかりませんでした"
			end try
		end tell
	end if
	return ocidAppPathURL
end doGetAppURL
##############################
##アプリケーションが
##OPEN可能なUTIリストを取得する
##############################
to doGetUTI(arg_ocidAppPathURL)
	set ocidAppPathURL to arg_ocidAppPathURL
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
