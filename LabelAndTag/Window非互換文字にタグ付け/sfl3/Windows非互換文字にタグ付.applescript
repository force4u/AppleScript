#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# フォルダ内のコンテンツを収集して内包されている項目全部処理する
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807
property listDeprecatedChar : {"\\", "/", "?", "<", ">", ":", "*", "|", "\"", "¥", ".."} as list

##############################
### Wクリックで起動時
on run
	###ドロップレットWクリック時にはファイル選択ダイアログを出す
	set strName to (name of current application) as text
	if strName is "osascript" then
		tell application "Finder" to activate
	else if strName is (name of me as text) then
		set strName to (name of me) as text
		tell application strName to activate
	else
		tell current application to activate
	end if
	###デフォルトロケーションはデスクトップ
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
	set aliasDesktopDirPath to (ocidDesktopDirPathURL's absoluteURL()) as alias
	set strMes to "選んでください"
	set listDropOpenPath to (choose folder strMes default location aliasDesktopDirPath with prompt strMes with multiple selections allowed and showing package contents without invisibles) as list
	open listDropOpenPath
end run

##################################
###本処理
##################################
on open listDropOpenPath
	##################################
	#サイドバー項目をチェック
	set strTagName to ("Windows非互換文字") as text
	set numLabelNo to 7 as integer
	##
	set appFileManager to refMe's NSFileManager's defaultManager()
	set strFileName to "com.apple.LSSharedFileList.ProjectsItems.sfl3" as text
	set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
	set ocidContainerPathURL to (ocidAppSuppDirPathURL's URLByAppendingPathComponent:("com.apple.sharedfilelist") isDirectory:true)
	set ocidSharedFileListURL to (ocidContainerPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false)
	###NSDATAに読み込みます
	set ocidPlistData to (refMe's NSData's dataWithContentsOfURL:(ocidSharedFileListURL))
	### NSKeyedUnarchiver's
	set listResponse to refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:((refMe's NSObject)'s class) fromData:(ocidPlistData) |error|:(reference)
	set ocidArchveDict to (item 1 of listResponse)
	### 可変Dictにセット
	set ocidArchveDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidArchveDictM's setDictionary:ocidArchveDict)
	set ocidItemsArray to (ocidArchveDictM's objectForKey:("items"))
	set numCntArray to (count of ocidItemsArray) as integer
	set boolChkTagName to false as boolean
	repeat with itemIntNo from 0 to (numCntArray - 1) by 1
		set itemsArrayDict to (ocidItemsArray's objectAtIndex:(itemIntNo))
		set strItemName to (itemsArrayDict's objectForKey:("Name")) as text
		if strItemName is strTagName then
			set boolChkTagName to true as boolean
			log "すでに設定済みです"
		end if
	end repeat
	if boolChkTagName is false then
		### 項目追加用のDict
		set ocidAddProkectDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
		set ocidCustomPropertiesDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
		####CustomItemProperties
		set ocidTrue to refMe's NSNumber's numberWithBool:(true)
		ocidCustomPropertiesDict's setValue:(ocidTrue) forKey:("kLSSharedTagFileListItemPinned")
		##表示させたい場合はここをocidFalseに
		set ocidTrue to refMe's NSNumber's numberWithBool:(true)
		ocidCustomPropertiesDict's setValue:(ocidTrue) forKey:("com.apple.LSSharedFileList.ItemIsHidden")
		##ラベルカラー
		set ocidLabelNo to refMe's NSNumber's numberWithInteger:(numLabelNo)
		ocidCustomPropertiesDict's setValue:(ocidLabelNo) forKey:("kLSSharedTagFileListItemLabel")
		##CustomItemPropertiesでDictを追加
		ocidAddProkectDict's setObject:(ocidCustomPropertiesDict) forKey:("CustomItemProperties")
		####Bookmark
		set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
		ocidURLComponents's setScheme:("x-apple-findertag")
		ocidURLComponents's setPath:(strName)
		set ocidTagURL to ocidURLComponents's |URL|()
		set listBookMarkData to (ocidTagURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
		set ocidBookMarkData to item 1 of listBookMarkData
		ocidAddProkectDict's setObject:(ocidBookMarkData) forKey:("Bookmark")
		##
		set ocidTagName to refMe's NSString's stringWithString:(strName)
		ocidAddProkectDict's setObject:(ocidTagName) forKey:("Name")
		##
		set ocidUUID to refMe's NSUUID's alloc()'s init()
		set ocidUUIDString to ocidUUID's UUIDString()
		ocidAddProkectDict's setValue:(ocidUUIDString) forKey:("uuid")
		##
		set ocidVisibility to refMe's NSNumber's numberWithInteger:(0)
		ocidAddProkectDict's setValue:(ocidVisibility) forKey:("visibility")
		##itemsのArrayに追加
		ocidItemsArrayM's addObject:(ocidAddProkectDict)
		### RootにItemsを追加
		(ocidArchveDictM's setObject:(ocidItemsArrayM) forKey:("items"))
		###NSKeyedArchiver's
		set listSaveData to refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(false) |error|:(reference)
		set ocidSaveData to item 1 of listSaveData
		#保存
		set listDone to ocidSaveData's writeToURL:(ocidSharedFileListURL) options:0 |error|:(reference)
		if (item 1 of listDone) is false then
			log "保存に失敗しました"
		else
			log "設定済しました"
		end if
	end if
	
	set ocidFilePathURLArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
	
	repeat with itemDropPath in listDropOpenPath
		###ドップパス
		set appFileManager to refMe's NSFileManager's defaultManager()
		set strDropPath to (POSIX path of itemDropPath) as text
		set ocidDropPathStr to (refMe's NSString's stringWithString:(strDropPath))
		set ocidDropPath to ocidDropPathStr's stringByStandardizingPath()
		set ocidDropPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDropPath))
		###ドロップされたのが?
		set listResults to (ocidDropPathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		if (item 2 of listResults) = (refMe's NSNumber's numberWithBool:true) then
			log "このURLはフォルダです"
			##取得するプロパティ
			set ocidProperties to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
			(ocidProperties's addObject:(refMe's NSURLPathKey))
			(ocidProperties's addObject:(refMe's NSURLIsRegularFileKey))
			(ocidProperties's addObject:(refMe's NSURLContentTypeKey))
			##オプション(隠しファイルは含まない)
			set ocidOption to refMe's NSDirectoryEnumerationSkipsHiddenFiles
			##コンテンツの収集
			set ocidEmuDict to (appFileManager's enumeratorAtURL:(ocidDropPathURL) includingPropertiesForKeys:(ocidProperties) options:(ocidOption) errorHandler:(reference))
			set ocidFilePathURLArray to ocidEmuDict's allObjects()
			#フォルダ自身も追加しておく
			(ocidFilePathURLArray's addObject:(itemDropPath))
		else
			log "このURLはファイルです"
			(ocidFilePathURLArray's addObject:(itemDropPath))
		end if
	end repeat
	
	###不要なんだが念のためパスをURL順に並び替え
	set ocidSortDescriptor to (refMe's NSSortDescriptor's sortDescriptorWithKey:"absoluteString" ascending:(true) selector:"localizedStandardCompare:")
	(ocidFilePathURLArray's sortUsingDescriptors:{ocidSortDescriptor})
	
	set ocidDeprecatedArray to refMe's NSArray's arrayWithArray:(listDeprecatedChar)
	set ocidTagArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:(0))
	set ocidTagName to (refMe's NSString's stringWithString:(strTagName))
	(ocidTagArray's addObject:(ocidTagName))
	
	repeat with itemFilePathURL in ocidFilePathURLArray
		set ocidLastPath to itemFilePathURL's lastPathComponent()
		##文字列の最初と最後のスペース
		set ocidCharLength to ocidLastPath's |length|()
		set ocidLastCharRange to refMe's NSMakeRange((ocidCharLength - 1), 1)
		set ocidFirstChar to (ocidLastPath's substringToIndex:(1)) as text
		set ocidLastChar to (ocidLastPath's substringWithRange:(ocidLastCharRange)) as text
		if ocidFirstChar is " " then
			set listDone to (itemFilePathURL's setResourceValue:(ocidTagArray) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
		end if
		if ocidLastChar is " " then
			set listDone to (itemFilePathURL's setResourceValue:(ocidTagArray) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
		end if
		##非推奨文字チェック
		repeat with itemDeprecatedChar in ocidDeprecatedArray
			set ocidRange to (ocidLastPath's rangeOfString:(itemDeprecatedChar))
			set ocidLocation to ocidRange's location()
			if ocidLocation = refNSNotFound then
				log "含まれていません"
			else
				log "対象文字が含まれています"
				set listDone to (itemFilePathURL's setResourceValue:(ocidTagArray) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
			end if
		end repeat
	end repeat
	return
	
	
	
	
	
	
end open
