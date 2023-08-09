#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application
property refNotFound : a reference to 9.22337203685477E+18 + 5807

#############################################
###設定項目
#############################################
###名前
set strName to ("Windows非互換文字") as text
###ラベルカラー番号
set numLabelNo to (5) as integer
(* OCのラベルカラー番号　Finderラベル番号の逆順
0	なし
1	グレイ
2	グリーン
3	パープル
4	ブルー
5	イエロー
6	レッド
7	オレンジ
*)

##############################
###チェック対象文字列
##############################
###警告文字リスト
set listProhibit to {"\\", "¥", "<", ">", "*", "?", "\"", "|", "/", ":"} as list

set ocidTagName to refMe's NSString's stringWithString:(strName)
set ocidLabelNo to refMe's NSNumber's numberWithInteger:(numLabelNo)
#######################################
##NSdataに読み込み　Keyを解凍する
#######################################
set appFileManager to refMe's NSFileManager's defaultManager()
###処理するファイル名
set strFileName to "com.apple.LSSharedFileList.ProjectsItems.sfl2" as text
###URLに
set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set ocidContainerPathURL to (ocidAppSuppDirPathURL's URLByAppendingPathComponent:("com.apple.sharedfilelist") isDirectory:true)
set ocidSharedFileListURL to (ocidContainerPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false)
###NSDATAに読み込みます
set ocidPlistData to (refMe's NSData's dataWithContentsOfURL:(ocidSharedFileListURL))
###	解凍してDictに　Flozenなので値を変更するために　可変に変えます
set ocidArchveDict to (refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData))
###	可変Dictにセット
set ocidArchveDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
(ocidArchveDictM's setDictionary:ocidArchveDict)

#######################################
###　items の処理
#######################################
###		items のArrayを取り出して　Flozenなので値を変更するために　可変に変えます
set ocidItemsArray to (ocidArchveDictM's objectForKey:("items"))
###		項目入替用のArray　
set ocidItemsArrayM to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
(ocidItemsArrayM's setArray:ocidItemsArray)
set numCntArrayItem to count of ocidItemsArray
#######################################
###		値がすでにあるか？確認
set boolChkTagName to (missing value)
##################
###itemsの数だけ繰り返し
repeat with itemsArrayDict in ocidItemsArrayM
	####
	set strItemName to (itemsArrayDict's objectForKey:("Name")) as text
	if strItemName is strName then
		###値があった場合
		set boolChkTagName to true as boolean
	else
		###なかった場合
		set boolChkTagName to false as boolean
	end if
end repeat
#######################################
###　本処理項目の追加
#######################################
###	項目追加用のDict
set ocidAddProkectDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidCustomPropertiesDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###すでにあるか？判定でなけば追加する
if boolChkTagName is false then
	################################CustomItemProperties
	set ocidTrue to refMe's NSNumber's numberWithBool:(true)
	ocidCustomPropertiesDict's setValue:(ocidTrue) forKey:("kLSSharedTagFileListItemPinned")
	##表示させたい場合はここをocidFalseに
	set ocidTrue to refMe's NSNumber's numberWithBool:(true)
	ocidCustomPropertiesDict's setValue:(ocidTrue) forKey:("com.apple.LSSharedFileList.ItemIsHidden")
	##
	ocidCustomPropertiesDict's setValue:(ocidLabelNo) forKey:("kLSSharedTagFileListItemLabel")
	##CustomItemPropertiesでDictを追加
	ocidAddProkectDict's setObject:(ocidCustomPropertiesDict) forKey:("CustomItemProperties")
	################################ 追加用のDict root
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
end if
### RootにItemsを追加
(ocidArchveDictM's setObject:(ocidItemsArrayM) forKey:("items"))

#######################################
###　値が新しくなった解凍済みDictをアーカイブする
#######################################
##NSKeyedArchiverに戻す
set listSaveData to (refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(true) |error|:(reference))
set ocidSaveData to item 1 of listSaveData

#######################################
###　データを上書き保存する
#######################################
##保存
set boolDone to (ocidSaveData's writeToURL:(ocidSharedFileListURL) atomically:true)
try
	do shell script "/usr/bin/killall sharedfilelistd"
end try

##############################
###ダイアログ
##############################
tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set strMes to ("フォルダを選んでください") as text
	set strPrompt to ("Window非互換文字のチェックを行います\r非互換名称には" & strName & "タグを付与します") as text
	set aliasTargetDirPath to (choose folder strMes with prompt strPrompt default location aliasDefaultLocation without multiple selections allowed, invisibles and showing package contents) as alias
on error
	log "エラーしました"
	return
end try
#####
set strTargetDirPath to (POSIX path of aliasTargetDirPath) as text
set ocidTargetDirPathStr to refMe's NSString's stringWithString:(strTargetDirPath)
set ocidTargetDirPath to ocidTargetDirPathStr's stringByStandardizingPath()
set ocidTargetDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidTargetDirPath) isDirectory:true)
###################################
###EMUモードでファイル収集
###################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidPropertyKeys to {(refMe's NSURLNameKey), (refMe's NSURLPathKey), (refMe's NSURLLabelNumberKey), (refMe's NSURLTagNamesKey)}
###非表示ファイルは除外
set ocidOption to (refMe's NSDirectoryEnumerationSkipsHiddenFiles)
###最下層まで収集
set ocidEmuDict to (appFileManager's enumeratorAtURL:(ocidTargetDirPathURL) includingPropertiesForKeys:(ocidPropertyKeys) options:(ocidOption) errorHandler:(reference))
###収集したURLをArrayにする
set ocidEmuFileURLArray to ocidEmuDict's allObjects()
###################################
###警告文字リストArrayに
set ocidListProhibitArray to refMe's NSArray's alloc()'s initWithArray:(listProhibit)
###################################
###収集したURLの数だけ繰り返し
###################################
repeat with itemEmuPathURL in ocidEmuFileURLArray
	
	###ファイル名　フォルダ名を取出して
	set listResult to (itemEmuPathURL's getResourceValue:(reference) forKey:(refMe's NSURLNameKey) |error|:(reference))
	set ocidFileName to (item 2 of listResult)
	#######################################
	###警告文字のリストと照合する
	###非互換文字があれば数だけカウントアップする
	set numChkCnProhibit to 0 as integer
	repeat with itemProhibitArray in ocidListProhibitArray
		##ラストパス＝ファイル名　フォルダ名　から
		set ocidFindRange to (ocidFileName's rangeOfString:(itemProhibitArray))
		log ocidFindRange
		##タグを取得して
		set listResult to (itemEmuPathURL's getResourceValue:(reference) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
		set ocidTagArray to (item 2 of listResult)
		##NSNotFound = 非互換文字はない
		if (ocidFindRange's location()) = refNotFound then
			##カウンターはそのまま
			set numChkCnProhibit to numChkCnProhibit as integer
			##非互換文字がある
		else if (ocidFindRange's |length|()) > 0 then
			##カウンターを１加算
			set numChkCnProhibit to numChkCnProhibit + 1 as integer
		end if
	end repeat
	
	#######################################
	### タグ操作
	###numChkCnProhibit = 0 =非互換文字が無い
	if numChkCnProhibit = 0 then
		
		if ocidTagArray ≠ (missing value) then
			(ocidTagArray's removeObject:(ocidTagName))
			set listDone to (itemEmuPathURL's setResourceValue:(ocidTagArray) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
		end if
		##	非互換文字がある場合は
	else if numChkCnProhibit > 0 then
		log itemEmuPathURL's |path|() as text
		###タグが設定されていなければ
		if ocidTagArray = (missing value) then
			###タグを設定
			set listDone to (itemEmuPathURL's setResourceValue:({ocidTagName}) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
			###すでに何かのタグが設定されている場合
		else if ocidTagArray ≠ (missing value) then
			##すでにあるか？確認
			set boolContain to (ocidTagArray's containsObject:(ocidTagName))
			if boolContain is true then
				##すでにタグがある場合は何もしない
			else if boolContain is false then
				###タグを追加
				(ocidTagArray's addObject:(ocidTagName))
				set listDone to (itemEmuPathURL's setResourceValue:(ocidTagArray) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
			end if
		end if
		
		##ラベル　インデックス番号を追加
		set listDone to (itemEmuPathURL's setResourceValue:(ocidLabelNo) forKey:(refMe's NSURLLabelNumberKey) |error|:(reference))
	end if
end repeat


