#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
Finder＞＞設定＞＞タグに項目を追加します
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

#############################################
###設定項目
#############################################
###名前 この名前で追加されます
set strName to ("Windows非互換文字") as text
###ラベルカラー番号
set numLabelNo to (5) as integer
(* ラベルカラー番号　Finderラベル番号の逆順なので留意ください
0	なし
1	グレイ
2	グリーン
3	パープル
4	ブルー
5	イエロー
6	レッド
7	オレンジ
*)

#######################################
##NSdataに読み込み　Keyを解凍する
#######################################
###処理するファイル名
set strFileName to "com.apple.LSSharedFileList.ProjectsItems.sfl2" as text
###URLに
set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set ocidContainerPathURL to (ocidAppSuppDirPathURL's URLByAppendingPathComponent:("com.apple.sharedfilelist") isDirectory:true)
set ocidSharedFileListURL to (ocidContainerPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false)
###NSDATAに読み込みます
set ocidPlistData to (refMe's NSData's dataWithContentsOfURL:(ocidSharedFileListURL))
###【１】解凍してDictに　Flozenなので値を変更するために　可変に変えます
set ocidArchveDict to (refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData))
###【２】可変Dictにセット
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
	set ocidLabelNo to refMe's NSNumber's numberWithInteger:(numLabelNo)
	ocidCustomPropertiesDict's setValue:(ocidLabelNo) forKey:("kLSSharedTagFileListItemLabel")
	##CustomItemPropertiesでDictを追加
	ocidAddProkectDict's setObject:(ocidCustomPropertiesDict) forKey:("CustomItemProperties")
	################################ 追加用のDict root
	set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
	ocidURLComponents's setScheme:("x-apple-findertag")
	ocidURLComponents's setPath:(strName)
	set ocidTagURL to ocidURLComponents's |URL|()
	ocidAddProkectDict's setObject:(ocidTagURL) forKey:("Bookmark")
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

#######################################
###　リロード
#######################################
try
	do shell script "/usr/bin/killall sharedfilelistd"
on error
	set strAgentPath to "/System/Library/LaunchAgents/com.apple.coreservices.sharedfilelistd.plist"
	set strCommandText to ("/bin/launchctl stop -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try
	set strCommandText to ("/bin/launchctl start -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try
end try
delay 0.5
do shell script "/usr/bin/killall Finder"

return
