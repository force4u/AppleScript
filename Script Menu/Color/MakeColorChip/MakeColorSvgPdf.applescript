#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
クロームの印刷機能を使いますので
Google Chromeのインストールが必須です
*)
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


##############################
#####ダイアログ
##############################
##前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###カラーピッカー
try
	set the listRGB16bitColor to (choose color) as list
on error
	return "キャンセルしました"
end try

##########Color Picker Value 16Bit
set numRcolor16Bit to item 1 of listRGB16bitColor as number
set numGcolor16Bit to item 2 of listRGB16bitColor as number
set numBcolor16Bit to item 3 of listRGB16bitColor as number
##########Standard RGB Value 8Bit
set numRcolor8Bit to numRcolor16Bit / 256 div 1 as number
set numGcolor8Bit to numGcolor16Bit / 256 div 1 as number
set numBcolor8Bit to numBcolor16Bit / 256 div 1 as number
set strRcolor8Bit to numRcolor8Bit as text
set strGcolor8Bit to numGcolor8Bit as text
set strBcolor8Bit to numBcolor8Bit as text
##########NSColorValue Float
set numRcolorFloat to numRcolor8Bit / 255 as number
set numGcolorFloat to numGcolor8Bit / 255 as number
set numBcolorFloat to numBcolor8Bit / 255 as number
###
set strRGB8Bit to ((strRcolor8Bit) & "," & (strGcolor8Bit) & "," & (strBcolor8Bit)) as text
###
set strCommandText to ("/usr/bin/perl -e 'printf(\"%02X%02X%02X\"," & strRGB8Bit & ")'") as text
set strRGBHEX to (do shell script strCommandText) as text
set strRGBHEXenc to ("%23" & strRGBHEX) as text
set strRGBHEX to ("#" & strRGBHEX) as text
##
set strSVG to ("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\"><svg height=\"960.0px\" stroke-miterlimit=\"10\" style=\"background-color: #ffffff;fill-rule:nonzero;clip-rule:evenodd;stroke-linecap:round;stroke-linejoin:round;\" version=\"1.1\" viewBox=\"0 0 720 960\" width=\"720.0px\" xml:space=\"preserve\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"><defs/><path d=\"M0 0L720 0L720 960L0 960L0 0Z\" fill=\"#ffffff\" fill-rule=\"nonzero\" opacity=\"1\" stroke=\"none\"/><clipPath id=\"ArtboardFrame\"><rect height=\"960\" width=\"720\" x=\"0\" y=\"0\"/></clipPath><g clip-path=\"url(#ArtboardFrame)\" id=\"" & strRGBHEX & "\"><path d=\"M-1.13687e-13 0L720 0L720 720L-1.13687e-13 720L-1.13687e-13 0Z\" fill=\"" & strRGBHEX & "\" fill-rule=\"nonzero\" opacity=\"1\" stroke=\"none\"/><text fill=\"" & strRGBHEX & "\" font-family=\"Helvetica-Bold\" font-size=\"144\" opacity=\"1\" stroke=\"none\" text-anchor=\"start\" transform=\"matrix(1 0 0 1 36 720)\" x=\"0\" y=\"0\"><tspan textLength=\"620\" x=\"0\" y=\"140\">" & strRGBHEX & "</tspan></text><text fill=\"" & strRGBHEX & "\" font-family=\"Helvetica-Bold\" font-size=\"36\" opacity=\"1\" stroke=\"none\" text-anchor=\"start\" transform=\"matrix(1 0 0 1 36 881.244)\" x=\"0\" y=\"0\"><tspan textLength=\"520\" x=\"0\" y=\"35\">rgb(" & strRcolor8Bit & ", " & strGcolor8Bit & ", " & strBcolor8Bit & ")</tspan></text></g></svg>") as text

###ダウンロードフォルダ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDownloadsDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDownloadsDirPathURL to ocidURLsArray's firstObject()
###ファイル名はHEX値
set strFileName to (strRGBHEX & ".svg") as text
set ocidSaveFilePathURL to ocidDownloadsDirPathURL's URLByAppendingPathComponent:(strFileName)
set strSaveFilePath to ocidSaveFilePathURL's |path| as text
##データにして
set ocidSaveSVG to refMe's NSString's stringWithString:(strSVG)
##保存
set listDone to (ocidSaveSVG's writeToURL:(ocidSaveFilePathURL) atomically:(refMe's NSNumber's numberWithBool:true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
##################
##HTML出力
##リンクさせる場合（レスポンシブ）
set strHTML to ("<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title>" & strRGBHEX & "</title><style>body{background-color: #FFFFF;}</style></head><body><img src=\"./" & strRGBHEXenc & ".svg\" style=\"height: 96vh; margin-top: 2vh; margin-bottom: 2vh;margin-left: 2vh\"></body></html>") as text
##埋め込む場合
##	set strHTML to ("<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title>" & strRGBHEX & "</title><style>body{background-color: #FFFFF;}</style></head><body>" & strSVG & "</body></html>") as text

##データにして
set ocidSaveHTML to refMe's NSString's stringWithString:(strHTML)
##保存
set strFileName to (strRGBHEX & ".html") as text
set ocidHTMLFilePathURL to ocidDownloadsDirPathURL's URLByAppendingPathComponent:(strFileName)
set listDone to (ocidSaveHTML's writeToURL:(ocidHTMLFilePathURL) atomically:(refMe's NSNumber's numberWithBool:true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
##################
##PDF出力
##クロームのインストール先URLを取得
set strBundleID to "com.google.Chrome" as text
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
if ocidAppBundle ≠ (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else if ocidAppBundle = (missing value) then
	set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
end if
if ocidAppPathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
		on error
			return "アプリケーションが見つかりませんでした"
		end try
	end tell
	set strAppPath to POSIX path of aliasAppApth as text
	set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
	set strAppPath to strAppPathStr's stringByStandardizingPath()
	set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true
end if
###PDFの保存先パス
set strFileName to (strRGBHEX & ".pdf") as text
set ocidPDFFilePathURL to ocidDownloadsDirPathURL's URLByAppendingPathComponent:(strFileName)
set strPdfFilePathURL to ocidPDFFilePathURL's |path| as text
set ocidBinPathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/MacOS/Google Chrome")
set strBinPath to ocidBinPathURL's |path|() as text
###コマンド整形
set strCommandText to ("\"" & strBinPath & "\" --headless --disable-gpu --print-to-pdf=\"" & strPdfFilePathURL & "\"  --print-to-pdf-no-header \"" & strSaveFilePath & "\"") as text
###コマンド実行
set strRGBHEX to (do shell script strCommandText) as text
###保存先を開く
set appSharedWorkSpave to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkSpave's selectFile:(ocidSaveFilePathURL's |path|) inFileViewerRootedAtPath:(ocidDownloadsDirPathURL's |path|)

