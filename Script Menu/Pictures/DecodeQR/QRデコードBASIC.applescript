#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "CoreImage"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

###################################
#####ダイアログ
###################################a
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###ダイアログのデフォルト
set ocidUserDesktopPath to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set aliasDefaultLocation to ocidUserDesktopPath as alias
set listChooseFileUTI to {"public.image"}
set strPromptText to "QRコードファイルを選んでください" as text
set listAliasFilePath to (choose file with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with invisibles and showing package contents without multiple selections allowed) as list
###################################
#####パス処理
###################################
###エリアス
set aliasFilePath to item 1 of listAliasFilePath as alias
###UNIXパス
set strFilePath to POSIX path of aliasFilePath as text
###String
set ocidFilePath to refMe's NSString's stringWithString:(strFilePath)
###NSURL
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false
####ファイル名を取得
set ocidFileName to ocidFilePathURL's lastPathComponent()
####拡張子を取得
set ocidFileExtension to ocidFilePathURL's pathExtension()
####ファイル名から拡張子を取っていわゆるベースファイル名を取得
set ocidPrefixName to ocidFileName's stringByDeletingPathExtension
####コンテナ
set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()


###################################
#####　QRコードイメージファイル読み込み　
###################################
####CIイメージに読み込み
set ocidCiImageInput to (refMe's CIImage's imageWithContentsOfURL:(ocidFilePathURL) options:(missing value))
########################
####CIDetectorを定義 	CIDetectorTypeQRCode
set ocidDetector to refMe's CIDetector's detectorOfType:(refMe's CIDetectorTypeQRCode) context:(missing value) options:{CIDetectorAccuracy:(refMe's CIDetectorAccuracyHigh)}
#####ocidDetectorを通して結果をArrayに格納
set ocidFeaturesArray to ocidDetector's featuresInImage:(ocidCiImageInput)
if (count of ocidFeaturesArray) = 0 then
	return "読み取り不良A"
end if
set strOutPutText to ("") as text

repeat with itemFeaturesArray in ocidFeaturesArray
	#####読み取り結果のテキスト
	log className() of itemFeaturesArray as text
	log itemFeaturesArray's |bounds|() as list
	set strReadText to itemFeaturesArray's messageString() as text
	###QRバーコードが複数ある場合
	##	set strOutPutText to (strOutPutText & strReadText & "\n") as text
	###QRバーコードが単体の場合
	set strOutPutText to (strOutPutText & strReadText & "") as text
	log itemFeaturesArray's type() as text
end repeat
set ocidQrCodeMessageString to refMe's NSString's stringWithString:(strOutPutText)

########################
###　イメージからテキストを読み取る場合
###	CIDetectorを定義		CIDetectorTypeText
(*
set ocidDetector to refMe's CIDetector's detectorOfType:(refMe's CIDetectorTypeText) context:(missing value) options:{CIDetectorAccuracy:(refMe's CIDetectorAccuracyHigh)}
#####ocidDetectorを通して結果をArrayに格納
set ocidFeaturesArray to ocidDetector's featuresInImage:(ocidCiImageInput) options:({CIDetectorReturnSubFeatures:true})
if (count of ocidFeaturesArray) = 0 then
	return "読み取り不良B"
end if
repeat with itemFeaturesArray in ocidFeaturesArray
	log itemFeaturesArray's type() as text
	#####読み取り結果のテキスト
	log className() of itemFeaturesArray as text
	set ocidBounds to itemFeaturesArray's |bounds|()
	set ocidReadArray to itemFeaturesArray's subFeatures()
	repeat with itemReadArray in ocidReadArray
		log className() of itemReadArray as text
		set ocidBounds to itemReadArray's |bounds|()
		log ocidBounds as list
		log itemReadArray's type() as text
	end repeat
	
end repeat
*)


###################################
#####　ダイアログ
###################################
set aliasIconPath to POSIX file "/System/Applications/Preview.app/Contents/Resources/AppIcon.icns" as alias
set strDefaultAnswer to ocidQrCodeMessageString as text
try
	set strMes to ("戻り値です\r" & strOutPutText) as text
	
	set recordResult to (display dialog strMes with title "bundle identifier" default answer strOutPutText buttons {"クリップボードにコピー", "キャンセル", "ファイル書出"} default button "ファイル書出" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)
on error
	log "エラーしました"
	return "エラーしました"
	error number -128
end try
if true is equal to (gave up of recordResult) then
	return "時間切れですやりなおしてください"
	error number -128
end if
if "ファイル書出" is equal to (button returned of recordResult) then
	
	#####ダイアログを前面に
	tell current application
		set strName to name as text
	end tell
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	###ファイル名
	set strPrefixName to ocidPrefixName as text
	###拡張子変える場合
	set strFileExtension to "txt"
	###ダイアログに出すファイル名
	set strDefaultName to (strPrefixName & ".output." & strFileExtension) as text
	set strPromptText to "名前を決めてください"
	###選んだファイルの同階層をデフォルト
	set aliasDefaultLocation to ocidContainerDirPathURL as alias
	####ファイル名ダイアログ
	####実在しない『はず』なのでas «class furl»で
	set aliasSaveFilePath to (choose file name default location aliasDefaultLocation default name strDefaultName with prompt strPromptText) as «class furl»
	####UNIXパス
	set strSaveFilePath to POSIX path of aliasSaveFilePath as text
	####ドキュメントのパスをNSString
	set ocidSaveFilePath to refMe's NSString's stringWithString:strSaveFilePath
	####ドキュメントのパスをNSURLに
	set ocidSaveFilePathURL to refMe's NSURL's fileURLWithPath:ocidSaveFilePath
	###拡張子取得
	set strFileExtensionName to ocidSaveFilePathURL's pathExtension() as text
	###ダイアログで拡張子を取っちゃった時対策
	if strFileExtensionName is not strFileExtension then
		set ocidSaveFilePathURL to ocidSaveFilePathURL's URLByAppendingPathExtension:strFileExtension
	end if
	###ファイル保存
	set boolFileWrite to (ocidQrCodeMessageString's writeToURL:ocidSaveFilePathURL atomically:false encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
else if button returned of recordResult is "クリップボードにコピー" then
	try
		set strText to text returned of recordResult as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strTitle as text
		end tell
	end try
	return "処理終了"
	
else
	log "エラーしました"
	return "エラーしました"
	error number -128
end if
