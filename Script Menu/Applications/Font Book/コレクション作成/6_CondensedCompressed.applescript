#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 書体のスタイルが　　の書体の
#コレクションを作成します
# 斜体を含みます
# Appleのフォントスタイル判定の仕様上
# CondensedにCompressedが含まれる可能性が高いです
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
property refNotFound : a reference to 9.22337203685477E+18 + 5807


####設定項目
set strTraitsNameA to ("Compressed") as text
set strTraitsNameB to ("Condensed") as text
##################################
set ocidTraitsA to (refMe's NSCompressedFontMask)
set ocidTraitsB to (refMe's NSCondensedFontMask)

####スタイルリスト
set listFontFaceA to {"Compressed", "SemiCompressed", "Semi Compressed"} as list
set listFontFaceB to {"Condensed", "SemiCondensed", "Semi Condensed"} as list
#Arrayにしておく
set ocidFontFaceArrayA to refMe's NSArray's alloc()'s initWithArray:(listFontFaceA)
set ocidFontFaceArrayB to refMe's NSArray's alloc()'s initWithArray:(listFontFaceB)
####曖昧比較用リスト
set listFontFaceAmbA to {"Comp", "Compressed", "Cp", "Komprimiert"} as list
set listFontFaceAmbB to {"Cond", "Condensed", "Cn", "Engschrift", "Kondensiert"} as list

##################################
##フォントブックを終了させる
set strBundleID to ("com.apple.FontBook") as text
set ocidResultsArray to (refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID))
set numCntArray to ocidResultsArray's |count|() as integer
repeat with itemNo from 0 to (numCntArray - 1) by 1
	set ocidRunApp to (ocidResultsArray's objectAtIndex:(itemNo))
	#通常終了を試みます
	set boolDone to ocidRunApp's terminate()
	if (boolDone) is true then
		log strBundleID & ":正常終了"
		#失敗したら
	else if (boolDone) is false then
		#強制終了を試みます
		set boolDone to ocidRunApp's forceTerminate()
		if (boolDone) is true then
			log strBundleID & ":強制終了"
		else if (boolDone) is false then
			log strBundleID & ":終了出来ませんでした"
		end if
	end if
end repeat

##################################
##保存先
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("FontCollections") isDirectory:(true)
##保存ファイル= collection
set ocidBaseFilePathURLA to ocidSaveDirPathURL's URLByAppendingPathComponent:(strTraitsNameA) isDirectory:(false)
set ocidBaseFilePathURLB to ocidSaveDirPathURL's URLByAppendingPathComponent:(strTraitsNameB) isDirectory:(false)
set ocidSaveFilePathURLA to ocidBaseFilePathURLA's URLByAppendingPathExtension:("collection")
set ocidSaveFilePathURLB to ocidBaseFilePathURLB's URLByAppendingPathExtension:("collection")
#ファイル名
set ocidFileNameA to ocidSaveFilePathURLA's lastPathComponent()
set ocidFileNameB to ocidSaveFilePathURLB's lastPathComponent()
################################
#保存するDICTの初期化
set ocidPlistDictA to refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0)
set ocidPlistDictB to refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0)
##【１】NSFontCollectionAttributes
set ocidSetCollectionDictA to refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0)
ocidSetCollectionDictA's setValue:(strTraitsNameA) forKey:("NSFontCollectionName")
ocidSetCollectionDictA's setValue:(ocidFileNameA) forKey:("NSFontCollectionFileName")
ocidPlistDictB's setObject:(ocidSetCollectionDictA) forKey:("NSFontCollectionAttributes")
#
set ocidSetCollectionDictB to refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0)
ocidSetCollectionDictB's setValue:(strTraitsNameB) forKey:("NSFontCollectionName")
ocidSetCollectionDictB's setValue:(ocidFileNameB) forKey:("NSFontCollectionFileName")
ocidPlistDictB's setObject:(ocidSetCollectionDictB) forKey:("NSFontCollectionAttributes")

##【２】NSFontCollectionFontDescriptors
set ocidSetDescriptorsArrayA to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
set ocidSetDescriptorsArrayB to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
##NSFontManager
set appFontManager to refMe's NSFontManager's sharedFontManager()
#フォントファミリー
#set ocidFontFamilyArray to appFontManager's availableFontFamilies()
#Traits別のフォントリスト
set ocidFontNameArrayA to appFontManager's availableFontNamesWithTraits:(ocidTraitsA)
set ocidFontNameArrayB to appFontManager's availableFontNamesWithTraits:(ocidTraitsB)
####################
#TraitsのMaskによる追加
repeat with itemFont in ocidFontNameArrayA
	#NSFont
	set ocidItemFont to (refMe's NSFont's fontWithName:(itemFont) |size|:(0.0))
	#NSFontDescriptor
	set ocidItemFontDiscriptor to ocidItemFont's fontDescriptor()
	(ocidSetDescriptorsArrayA's addObject:(ocidItemFontDiscriptor))
end repeat
##
repeat with itemFont in ocidFontNameArrayB
	#NSFont
	set ocidItemFont to (refMe's NSFont's fontWithName:(itemFont) |size|:(0.0))
	#NSFontDescriptor
	set ocidItemFontDiscriptor to ocidItemFont's fontDescriptor()
	(ocidSetDescriptorsArrayB's addObject:(ocidItemFontDiscriptor))
end repeat

####################
# 全てのフォント
set ocidFontArray to appFontManager's availableFonts()
##フォントの数だけ
repeat with itemFont in ocidFontArray
	set boolSetFontDiscriptorA to false as boolean
	set boolSetFontDiscriptorB to false as boolean
	#########NSFont
	set ocidItemFont to (refMe's NSFont's fontWithName:(itemFont) |size|:(0.0))
	#	set ocidDisplayName to ocidItemFont's |displayName|() 
	set ocidFontName to ocidItemFont's |fontName|()
	#########NSFontDescriptor
	set ocidItemFontDiscriptor to ocidItemFont's fontDescriptor()
	#スタイルを取得して
	set ocidItemFontFace to (ocidItemFontDiscriptor's objectForKey:(refMe's NSFontFaceAttribute))
	#####A
	set boolContainA to (ocidFontFaceArrayA's containsObject:(ocidItemFontFace))
	if boolContainA is true then
		set boolSetFontDiscriptorA to true as boolean
	else
		#曖昧検索で含まれているかも確認
		repeat with itemFontFaceAmbA in listFontFaceAmbA
			#検索語句が含まれているか？
			set ocidRange to (ocidItemFontFace's rangeOfString:(itemFontFaceAmbA) options:(refMe's NSCaseInsensitiveSearch))
			if (ocidRange's location()) ≠ (refNotFound) then
				#登録して良い判断
				set boolSetFontDiscriptorA to true as boolean
			end if
		end repeat
	end if
	#####B
	set boolContainB to (ocidFontFaceArrayB's containsObject:(ocidItemFontFace))
	if boolContainB is true then
		set boolSetFontDiscriptorA to true as boolean
	else
		#曖昧検索で含まれているかも確認
		repeat with itemFontFaceAmbB in listFontFaceAmbB
			#検索語句が含まれているか？
			set ocidRange to (ocidItemFontFace's rangeOfString:(itemFontFaceAmbB) options:(refMe's NSCaseInsensitiveSearch))
			if (ocidRange's location()) ≠ (refNotFound) then
				#登録して良い判断
				set boolSetFontDiscriptorB to true as boolean
			end if
		end repeat
	end if
	##登録して良い判断＝boolSetFontDiscriptorなら登録
	if boolSetFontDiscriptorA is true then
		(ocidSetDescriptorsArrayA's addObject:(ocidItemFontDiscriptor))
	else if boolSetFontDiscriptorB is true then
		(ocidSetDescriptorsArrayB's addObject:(ocidItemFontDiscriptor))
	end if
end repeat


ocidPlistDictA's setObject:(ocidSetDescriptorsArrayA) forKey:("NSFontCollectionFontDescriptors")
ocidPlistDictB's setObject:(ocidSetDescriptorsArrayB) forKey:("NSFontCollectionFontDescriptors")

################################
#NSKeyedArchiver初期化 A
set ocidArchiverDataA to refMe's NSKeyedArchiver's alloc()'s initRequiringSecureCoding:(false)
#エンコード
ocidArchiverDataA's encodeObject:(ocidPlistDictA) forKey:("NSFontCollectionDictionary")
ocidArchiverDataA's finishEncoding()
set ocidEncDataA to ocidArchiverDataA's encodedData()
#保存するDATA
set ocidSaveDataA to refMe's NSMutableData's alloc()'s initWithCapacity:(0)
ocidSaveDataA's appendData:(ocidEncDataA)
################################
#NSKeyedArchiver初期化 B
set ocidArchiverDataB to refMe's NSKeyedArchiver's alloc()'s initRequiringSecureCoding:(false)
#エンコード
ocidArchiverDataB's encodeObject:(ocidPlistDictB) forKey:("NSFontCollectionDictionary")
ocidArchiverDataB's finishEncoding()
set ocidEncDataB to ocidArchiverDataB's encodedData()
#保存するDATA
set ocidSaveDataB to refMe's NSMutableData's alloc()'s initWithCapacity:(0)
ocidSaveDataB's appendData:(ocidEncDataB)

################################
#保存
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidSaveDataA's writeToURL:(ocidSaveFilePathURLA) options:(ocidOption) |error|:(reference)
if (item 2 of listDone) = (missing value) then
	log "writeToURL　正常処理A"
else if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s code() as text
	log (item 2 of listDone)'s localizedDescription() as text
	return "writeToURL　エラーしましたA"
end if
################################
#保存
set listDone to ocidSaveDataB's writeToURL:(ocidSaveFilePathURLB) options:(ocidOption) |error|:(reference)
if (item 2 of listDone) = (missing value) then
	log "writeToURL　正常処理B"
else if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s code() as text
	log (item 2 of listDone)'s localizedDescription() as text
	return "writeToURL　エラーしましたB"
end if

delay 2
################################
#フォントブック起動
tell application id strBundleID to activate

return


