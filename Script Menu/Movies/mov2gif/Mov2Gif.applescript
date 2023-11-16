#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# ###FFMPEGのインストールが別途必要です
#	https://ffmpeg.org/
# ###gifskiのインストールが別途必要です
#	https://github.com/ImageOptim/gifski
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AVFoundation"
use scripting additions
property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()
##############################
###設定項目
###FFMPEGのパス
###通常はこちらかな？
#	set strBinPath to ("/usr/local/bin/ffmpeg") as text
set strBinPath to ("$HOME/bin/ffmpeg.6/ffmpeg") as text

###gifskiのパス
set strGifskiBinPath to ("$HOME/bin/gifski/gifski") as text

#############################
###ダイアログ
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
############ デフォルトロケーション
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
############UTIリスト
set listUTI to {"public.movie"}

set strMes to ("ムービー・ファイルを選んでください") as text
set strPrompt to ("ムービー・ファイルを選んでください") as text
try
	###　ファイル選択時
	set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try

###
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
set strFilePathURL to (ocidFilePathURL's |path|()) as text
set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
set strFileName to (ocidBaseFilePathURL's lastPathComponent()) as text
###デスクトップにファイル名のフォルダ作って
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strFileName)
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###↑のフォルダの中にイメージシーケンス書き出し用のフォルダを作る
set ocidSaveSequenceDirPathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("sequence") isDirectory:true
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveSequenceDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set strSaveSequenceDirPathURL to (ocidSaveSequenceDirPathURL's |path|()) as text
###出力用のGIFアニメ用のパス
set strGifFileName to (strFileName & ".gif") as text
set ocidGifFilePath to ocidSaveDirPathURL's URLByAppendingPathComponent:(strGifFileName) isDirectory:false
set strGifFilePath to (ocidGifFilePath's |path|()) as text

##イメージシーケンス生成
set strCommandText to ("pushd \"" & strSaveSequenceDirPathURL & "\" && " & strBinPath & " -i \"" & strFilePathURL & "\" frame%04d.png") as text
do shell script strCommandText
##
delay 3
##
set strCommandText to ("pushd \"" & strSaveSequenceDirPathURL & "/\" && " & strGifskiBinPath & " -o  \"" & strGifFilePath & "\"  frame*.png") as text
do shell script strCommandText
