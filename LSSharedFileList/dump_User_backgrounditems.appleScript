#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#ユーザードメインの
# backgrounditems.btmのブックマークデータを表示します
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

####入力ファイルパス
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicatioocidupportDirPathURL to ocidURLsArray's firstObject()
set ocidFilePathURL to ocidApplicatioocidupportDirPathURL's URLByAppendingPathComponent:("com.apple.backgroundtaskmanagementagent/backgrounditems.btm") isDirectory:(false)
(*
set strFilePath to ("~/Library/Application Support/com.apple.backgroundtaskmanagementagent/backgrounditems.btm") as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
*)
# NSDataに読み込んで
set listResponse to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidFilePathURL) options:(refMe's NSDataReadingMappedIfSafe) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "正常処理"
	set ocidReadData to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	log (item 2 of listResponse)'s code() as text
	log (item 2 of listResponse)'s localizedDescription() as text
	return "エラーしました"
end if

# unarchivedObjectOfClassで解凍する
#DATAを解凍する
set ocidClassListArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:(0))
(ocidClassListArray's addObject:(refMe's NSDictionary's class))
(ocidClassListArray's addObject:(refMe's NSMutableDictionary's class))
(ocidClassListArray's addObject:(refMe's NSArray's class))
(ocidClassListArray's addObject:(refMe's NSMutableArray's class))
(ocidClassListArray's addObject:(refMe's NSObject's classForKeyedUnarchiver))
(ocidClassListArray's addObject:(refMe's NSObject's class))
(ocidClassListArray's addObject:(refMe's NSKeyedArchiver's class))
(ocidClassListArray's addObject:(refMe's NSKeyedUnarchiver's class))
#クラスセット
set ocidSetClass to refMe's NSSet's alloc()'s initWithArray:(ocidClassListArray)
#解凍
set listResponse to refMe's NSKeyedUnarchiver's unarchivedObjectOfClasses:(ocidSetClass) fromData:(ocidReadData) |error|:(reference)
set ocidPlistDict to (item 1 of listResponse)
if ocidPlistDict = (missing value) then
	log "解凍に失敗しましたので解凍しないでブックマーク一覧を取得します"
	set ocidFormat to refMe's NSPropertyListBinaryFormat_v1_0
	set ocidOption to refMe's NSPropertyListMutableContainersAndLeaves
	set listResponse to refMe's NSPropertyListSerialization's propertyListWithData:(ocidReadData) options:(ocidOption) format:(ocidFormat) |error|:(reference)
	if (item 2 of listResponse) = (missing value) then
		log "正常処理"
		set ocidReadDict to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		log (item 2 of listResponse)'s code() as text
		log (item 2 of listResponse)'s localizedDescription() as text
		return "エラーしました"
	end if
	#必要なデータを格納するArray
	set ocidBookMarkArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
	#ROOTから取得
	set ocidObjectArray to ocidReadDict's objectForKey:("$objects")
	#リストの数を数えて
	set numCntArray to ocidObjectArray's |count|() as integer
	#ocidObjectArrayの数だけ繰り返し
	repeat with itemNo from 0 to (numCntArray - 1) by 1
		
		#Arrayから取り出して
		set ocidItemData to (ocidObjectArray's objectAtIndex:(itemNo))
		#クラスを調べて
		set strClassName to ocidItemData's className() as text
		#DATAなら処理する
		if strClassName contains "NSCFData" then
			#NSURL情報を格納するARRAY
			set ocidItemURLArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:(0))
			#格納用のARRAY
			set ocidKeyArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:(0))
			#パスと名前を取得して
			(ocidKeyArray's addObject:(refMe's NSURLPathKey))
			(ocidKeyArray's addObject:(refMe's NSURLNameKey))
			set ocidResourceValues to (refMe's NSURL's resourceValuesForKeys:(ocidKeyArray) fromBookmarkData:(ocidItemData))
			#ファイル名を格納します
			set ocidFileName to (ocidResourceValues's objectForKey:(refMe's NSURLNameKey))
			(ocidItemURLArray's addObject:(ocidFileName))
			#DATA＝ブックマークをNSURLにして
			set listResponse to (refMe's NSURL's URLByResolvingBookmarkData:(ocidItemData) options:(refMe's NSURLBookmarkResolutionWithoutUI) relativeToURL:(missing value) bookmarkDataIsStale:(false) |error|:(reference))
			if (item 2 of listResponse) = (missing value) then
				log "正常処理"
				set ocidBookMarkFilePathURL to (item 1 of listResponse)
				#値を格納する
				(ocidItemURLArray's addObject:(ocidBookMarkFilePathURL))
			else if (item 2 of listResponse) ≠ (missing value) then
				log (item 2 of listResponse)'s code() as text
				log (item 2 of listResponse)'s localizedDescription() as text
				return "エラーしました"
			end if
			#値の格納
			(ocidBookMarkArray's addObject:(ocidItemURLArray))
		end if
		
	end repeat
else
	return "解凍出来ちゃいましたいつか解凍方法がわかったらやろう"
end if



##出力用タブ区切りテキストにする
set ocidOutPutstring to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
#項番用３桁ゼロサプレス
set numNo to 1 as integer
set ocidFormatter to refMe's NSNumberFormatter's alloc()'s init()
ocidFormatter's setMinimumIntegerDigits:(3)
ocidFormatter's setMaximumIntegerDigits:(3)

repeat with itemArray in ocidBookMarkArray
	log itemArray as list
	set strDec3 to (ocidFormatter's stringFromNumber:(numNo)) as text
	set strFileName to (item 1 of itemArray) as text
	set strFilePath to (item 2 of itemArray)'s |path|() as text
	set strFilePathURL to (item 2 of itemArray)'s absoluteString() as text
	#
	(ocidOutPutstring's appendString:(strDec3))
	(ocidOutPutstring's appendString:("\t"))
	(ocidOutPutstring's appendString:(strFileName))
	(ocidOutPutstring's appendString:("\t"))
	(ocidOutPutstring's appendString:(strFilePath))
	(ocidOutPutstring's appendString:("\t"))
	(ocidOutPutstring's appendString:(strFilePathURL))
	(ocidOutPutstring's appendString:("\n"))
	#カウントアップ
	set numNo to (numNo + 1) as integer
end repeat

##保存　書類フォルダ
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidDocumentDirPathURL's URLByAppendingPathComponent:("Apple/LoginItem") isDirectory:(true)
#保存先ディレクトリ
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
if (item 1 of listDone) is true then
	log "保存先ディレクトリ作成　正常処理"
else if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s code() as text
	log (item 2 of listDone)'s localizedDescription() as text
	return "エラーしました"
end if
#ファイル名は日付
set strDateNO to doGetDateNo("yyyy-MM-dd") as text
set strFileName to ("dump_ backgrounditems.btm." & strDateNO & ".tsv")
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:(false)
#保存
set listDone to ocidOutPutstring's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
if (item 1 of listDone) is true then
	log "保存先ディレクトリ作成　正常処理"
else if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s code() as text
	log (item 2 of listDone)'s localizedDescription() as text
	return "エラーしました"
end if


##
#保存先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's openURL:(ocidSaveDirPathURL)
if (item 1 of listDone) is true then
	log "正常処理"
else if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s code() as text
	log (item 2 of listDone)'s localizedDescription() as text
	return "エラーしました"
end if


##ダイアログを出す
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
set strMes to ("backgrounditems.btmの\n登録項目のダンプ\nタブ区切りテキストですので\n Excelやnumbersにペーストしてください") as text
set aliasIconPath to (POSIX file "/System/Library/PrivateFrameworks/AMPSharing.framework/Versions/A/PlugIns/SharingPrefsExtension.appex/Contents/Resources/AppIcon.icns") as alias
try
	set recordResult to (display dialog strMes with title "戻り値です" default answer (ocidOutPutstring as text) buttons {"クリップボードにコピー", "終了", "再実行"} default button "クリップボードにコピー" cancel button "終了" giving up after 20 with icon aliasIconPath without hidden answer) as record
on error
	return "エラーしました"
end try
if (gave up of recordResult) is true then
	return "時間切れです"
end if
##############################
#####自分自身を再実行
##############################
if button returned of recordResult is "再実行" then
	tell application "Finder"
		set aliasPathToMe to (path to me) as alias
	end tell
	run script aliasPathToMe with parameters "再実行"
end if
##############################
#####値のコピー
##############################
if button returned of recordResult is "クリップボードにコピー" then
	try
		set strText to text returned of recordResult as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strText as text
		end tell
	end try
end if



return 0





##############################
### 今の日付日間　テキスト
##############################
to doGetDateNo(argDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	set ocidTimeZone to refMe's NSTimeZone's alloc()'s initWithName:"Asia/Tokyo"
	ocidNSDateFormatter's setTimeZone:(ocidTimeZone)
	ocidNSDateFormatter's setDateFormat:(argDateFormat)
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
