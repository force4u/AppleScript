#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 書体のスタイルが　Bold　Black Heavyの書体の
#コレクションを作成します
# 斜体を排除します
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
property refNotFound : a reference to 9.22337203685477E+18 + 5807


####設定項目
set strTraitsName to ("Light") as text
#set ocidTraits to (refMe's NSLightFontMask)
####スタイルリスト
set listFontFace to {"Light", "Thin", "Hairline", "XLt", "Lt", "Th", "L", "EL", "UL", "SL", "SemiLight", "DemiLight", "ExtraLight", "Extra Light", "UltraLight", "Ultra Light", "100", "200", "300", "W0", "W1", "W2", "W3", "1", "2", "3"} as list
#Arrayにしておく
set ocidFontFaceArray to refMe's NSArray's alloc()'s initWithArray:(listFontFace)
####曖昧比較用リスト
set listFontFaceAmb to {"Light", "Thin", "SemiLight", "DemiLight", "UltraLight", " L", " EL", "XLt ", "Lt ", "Th "} as list

##################
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

##保存先
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("FontCollections") isDirectory:(true)
##保存ファイル= collection
set ocidBaseFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strTraitsName) isDirectory:(false)
set ocidSaveFilePathURL to ocidBaseFilePathURL's URLByAppendingPathExtension:("collection")
#ファイル名
set ocidFileName to ocidSaveFilePathURL's lastPathComponent()
################################
#保存するDICTの初期化
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0)
##【１】NSFontCollectionAttributes
set ocidSetCollectionDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0)
ocidSetCollectionDict's setValue:(strTraitsName) forKey:("NSFontCollectionName")
ocidSetCollectionDict's setValue:(ocidFileName) forKey:("NSFontCollectionFileName")
ocidPlistDict's setObject:(ocidSetCollectionDict) forKey:("NSFontCollectionAttributes")

##【２】NSFontCollectionFontDescriptors
set ocidSetDescriptorsArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
##NSFontManager
set appFontManager to refMe's NSFontManager's sharedFontManager()
## 全てのフォントをリストに
set ocidFontArray to appFontManager's availableFonts()
#Maskしたリストを取り出す
#set ocidFontNameArray to appFontManager's availableFontNamesWithTraits:(ocidTraits)
#フォントファミリーをリストする
#set ocidFontFamilyArray to appFontManager's availableFontFamilies()
################################
#まずはスタイルリストへのマッチ判定
#対象のスタイルの場合のみ登録
repeat with itemFont in ocidFontArray
	set boolSetFontDiscriptor to false as boolean
	#########NSFont
	set ocidItemFont to (refMe's NSFont's fontWithName:(itemFont) |size|:(0.0))
	#	set ocidDisplayName to ocidItemFont's |displayName|() 
	set ocidFontName to ocidItemFont's |fontName|()
	#########NSFontDescriptor
	set ocidItemFontDiscriptor to ocidItemFont's fontDescriptor()
	#スタイルを取得して
	set ocidItemFontFace to (ocidItemFontDiscriptor's objectForKey:(refMe's NSFontFaceAttribute))
	#リストに含まれているか？
	set boolContain to (ocidFontFaceArray's containsObject:(ocidItemFontFace))
	if boolContain is true then
		set boolSetFontDiscriptor to true as boolean
	else if boolContain is false then
		set boolSetFontDiscriptor to false as boolean
		#	log "---" as text
		#	log ocidFontName as text
		log ocidItemFontFace as text
		#曖昧検索で含まれているかも確認
		repeat with itemFontFaceAmb in listFontFaceAmb
			#検索語句が含まれているか？
			set ocidRange to (ocidItemFontFace's rangeOfString:(itemFontFaceAmb) options:(refMe's NSCaseInsensitiveSearch))
			if (ocidRange's location()) ≠ (refNotFound) then
				#排除する語句が含まれているか？
				#ここでは『斜体』を登録しない方法をとっている
				set ocidRange to (ocidItemFontFace's rangeOfString:("Oblique") options:(refMe's NSCaseInsensitiveSearch))
				if (ocidRange's location()) = (refNotFound) then
					set ocidRange to (ocidItemFontFace's rangeOfString:("Italic") options:(refMe's NSCaseInsensitiveSearch))
					if (ocidRange's location()) = (refNotFound) then
						#登録して良い判断
						#					log ocidRange
						set boolSetFontDiscriptor to true as boolean
					end if
				end if
			end if
		end repeat
	end if
	##登録して良い判断＝boolSetFontDiscriptorなら登録
	if boolSetFontDiscriptor is true then
		(ocidSetDescriptorsArray's addObject:(ocidItemFontDiscriptor))
	end if
end repeat
ocidPlistDict's setObject:(ocidSetDescriptorsArray) forKey:("NSFontCollectionFontDescriptors")

################################
#NSKeyedArchiver初期化
set ocidArchiverData to refMe's NSKeyedArchiver's alloc()'s initRequiringSecureCoding:(false)
#エンコード
ocidArchiverData's encodeObject:(ocidPlistDict) forKey:("NSFontCollectionDictionary")
ocidArchiverData's finishEncoding()
set ocidEncData to ocidArchiverData's encodedData()
#保存するDATA
set ocidSaveData to refMe's NSMutableData's alloc()'s initWithCapacity:(0)
ocidSaveData's appendData:(ocidEncData)

################################
#保存
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidSaveData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference)
if (item 2 of listDone) = (missing value) then
	log "writeToURL　正常処理"
else if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s code() as text
	log (item 2 of listDone)'s localizedDescription() as text
	return "writeToURL　エラーしました"
end if

delay 2
################################
#フォントブック起動
tell application id strBundleID to activate

return


