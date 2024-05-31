#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# フォントを追加したら再実行すればOKなやつ
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

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

##フルセットだと無い場合が多い
set recordTraits to {|Bold|:(refMe's NSBoldFontMask), |Compressed|:(refMe's NSCompressedFontMask), |Expanded|:(refMe's NSExpandedFontMask), |Condensed|:(refMe's NSCondensedFontMask), |FixedPitch|:(refMe's NSFixedPitchFontMask), |Italic|:(refMe's NSItalicFontMask), |Narrow|:(refMe's NSNarrowFontMask), |NonStandard|:(refMe's NSNonStandardCharacterSetFontMask), |Poster|:(refMe's NSPosterFontMask), |SmallCaps|:(refMe's NSSmallCapsFontMask), |Unbold|:(refMe's NSUnboldFontMask), |Unitalic|:(refMe's NSUnitalicFontMask)} as record
##一般的なセット
#	set recordTraits to {|Bold|:(refMe's NSBoldFontMask), |Compressed|:(refMe's NSCompressedFontMask), |Expanded|:(refMe's NSExpandedFontMask), |Condensed|:(refMe's NSCondensedFontMask), |FixedPitch|:(refMe's NSFixedPitchFontMask), |Italic|:(refMe's NSItalicFontMask)} as record
#DICTにして
set ocidTraitsDict to refMe's NSDictionary's alloc()'s initWithDictionary:(recordTraits)
#キー名＝ファイル名
set ocidTraitsAllKeys to ocidTraitsDict's allKeys()
#キーの数だけ繰り返し
repeat with itemTraitsAllKeys in ocidTraitsAllKeys
	#キー名＝ファイル名
	set strTraitsName to (itemTraitsAllKeys) as text
	#TraitMask
	set ocidTraitObjexct to (ocidTraitsDict's objectForKey:(itemTraitsAllKeys))
	set ocidTraits to ocidTraitObjexct
	##保存先
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
	set ocidSaveDirPathURL to (ocidLibraryDirPathURL's URLByAppendingPathComponent:("FontCollections") isDirectory:(true))
	##保存ファイル= collection
	set ocidBaseFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strTraitsName) isDirectory:(false))
	set ocidSaveFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:("collection"))
	#ファイル名
	set ocidFileName to ocidSaveFilePathURL's lastPathComponent()
	################################
	#保存するDICTの初期化
	set ocidPlistDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0))
	##【１】NSFontCollectionAttributes
	set ocidSetCollectionDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0))
	(ocidSetCollectionDict's setValue:(strTraitsName) forKey:("NSFontCollectionName"))
	(ocidSetCollectionDict's setValue:(ocidFileName) forKey:("NSFontCollectionFileName"))
	(ocidPlistDict's setObject:(ocidSetCollectionDict) forKey:("NSFontCollectionAttributes"))
	
	##【２】NSFontCollectionFontDescriptors
	set ocidSetDescriptorsArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:(0))
	##NSFontManager
	set appFontManager to refMe's NSFontManager's sharedFontManager()
	#Maskしたリストを取り出す
	set ocidFontNameArray to (appFontManager's availableFontNamesWithTraits:(ocidTraits))
	#フォントファミリーはここでは使わない
	#	set ocidFontFamilyArray to appFontManager's availableFontFamilies()
	##フォントの数だけ
	repeat with itemFont in ocidFontNameArray
		set ocidItemFont to (refMe's NSFont's fontWithName:(itemFont) |size|:(0.0))
		set ocidDisplayName to ocidItemFont's |displayName|() as text
		set ocidFontName to ocidItemFont's |fontName|() as text
		set ocidItemFontDiscriptor to ocidItemFont's fontDescriptor()
		#ここで追加
		(ocidSetDescriptorsArray's addObject:(ocidItemFontDiscriptor))
		set ocidPostScripName to ocidItemFontDiscriptor's |postscriptName|() as text
		set ocidFontName to (ocidItemFontDiscriptor's objectForKey:(refMe's NSFontNameAttribute)) as text
	end repeat
	(ocidPlistDict's setObject:(ocidSetDescriptorsArray) forKey:("NSFontCollectionFontDescriptors"))
	
	################################
	#NSKeyedArchiver初期化
	set ocidArchiverData to (refMe's NSKeyedArchiver's alloc()'s initRequiringSecureCoding:(false))
	#エンコード
	(ocidArchiverData's encodeObject:(ocidPlistDict) forKey:("NSFontCollectionDictionary"))
	ocidArchiverData's finishEncoding()
	set ocidEncData to ocidArchiverData's encodedData()
	#保存するDATA
	set ocidSaveData to (refMe's NSMutableData's alloc()'s initWithCapacity:(0))
	(ocidSaveData's appendData:(ocidEncData))
	
	
	################################
	#保存
	set ocidOption to (refMe's NSDataWritingAtomic)
	set listDone to (ocidSaveData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference))
	if (item 2 of listDone) = (missing value) then
		log "writeToURL　正常処理"
	else if (item 2 of listDone) ≠ (missing value) then
		log (item 2 of listDone)'s code() as text
		log (item 2 of listDone)'s localizedDescription() as text
		return "writeToURL　エラーしました"
	end if
	
end repeat

delay 2

tell application id strBundleID to activate


return "Done"


