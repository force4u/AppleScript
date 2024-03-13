#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "CoreImage"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

on run
	
	set aliasIconPass to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/MultipleItemsIcon.icns") as alias
	set strDialogText to "ドロップしても利用できます"
	set strTitleText to "画像ファイルを選んでください"
	set listButton to {"ファイルを選びます", "キャンセル"} as list
	display dialog strDialogText buttons listButton default button 1 cancel button 2 with title strTitleText with icon aliasIconPass giving up after 1 with hidden answer
	
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
	set listChooseFileUTI to {"public.png", "public.jpeg"}
	set strPromptText to "イメージファイルを選んでください" as text
	set strPromptMes to "イメージファイルを選んでください" as text
	set listAliasFilePath to (choose file strPromptMes with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with showing package contents, invisibles and multiple selections allowed) as list
	
	-->値をOpenに渡たす
	open listAliasFilePath
end run


on open listAliasFilePath
	
	##########################
	####ファイルの数だけ繰り返し
	repeat with itemAliasFilePath in listAliasFilePath
		####まずはUNIXパスにして
		set strFilePath to (POSIX path of itemAliasFilePath) as text
		set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath))
		set ocidFileName to ocidFilePathURL's lastPathComponent()
		#####################
		#### 本処理
		####データ読み込み
		set ocidReadData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidFilePathURL))
		####################################
		##サイズ取得 Ptサイズ
		#【A】レコードとして取得する
		set recordReadImageSize to ocidReadData's |size|()
		set numPtWidth to (width of recordReadImageSize)
		set numPtHeight to (height of recordReadImageSize)
		log numPtWidth as number
		log numPtHeight as number
		# 【B】NSConcreteValueとして取得する
		set ocidReadImageSize to ocidReadData's |size|
		#NSConcreteValueの中身によってValue形式を指定する
		set recordReadImageSize to ocidReadImageSize's sizeValue()
		set numPtWidth to (width of recordReadImageSize)
		set numPtHeight to (height of recordReadImageSize)
		log numPtWidth as number
		log numPtHeight as number
		####################################
		##サイズ取得 pxサイズ
		set ocidBmpImageRepArray to ocidReadData's representations()
		set ocidReadImageRep to ocidBmpImageRepArray's firstObject()
		set strColorSpace to ocidReadImageRep's colorSpaceName() as text
		##
		set numPixelsWidth to ocidReadImageRep's pixelsWide()
		set numPixelsHeight to ocidReadImageRep's pixelsHigh()
		log numPixelsWidth as integer
		log numPixelsHeight as integer
		set numPPI to (numPixelsHeight / numPtHeight) * 72 as integer
		
		set numPixelWidth to numPixelsWidth as integer
		set numPixelHeight to numPixelsHeight as integer
		##戻り値
		set strResponseText to ("Wpt: " & numPtWidth & "\nHpt: " & numPtHeight & "\nWpx: " & numPixelWidth & "\nHpx: " & numPixelHeight & "\nResolution: " & numPPI & "ppi\nColorSpace:" & strColorSpace  & "\n<img src=\"" & (ocidFileName as text) & "\" width=\"" & numPixelWidth & "\" height=\"" & numPixelHeight & "\" alt=\"" & (ocidFileName as text) & "\">\n\nmax-width: " & numPixelWidth & "px;\nmax-height: " & numPixelHeight & "px;\n") as text
		
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
		set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
		###ダイアログ
		set recordResult to (display dialog "SVGサイズ戻り値です" with title "戻り値です" default answer strResponseText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)
		###クリップボードコピー
		if button returned of recordResult is "クリップボードにコピー" then
			set strText to text returned of recordResult as text
			####ペーストボード宣言
			set appPasteboard to refMe's NSPasteboard's generalPasteboard()
			set ocidText to (refMe's NSString's stringWithString:(strText))
			appPasteboard's clearContents()
			(appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString))
		end if
		
	end repeat
end open
