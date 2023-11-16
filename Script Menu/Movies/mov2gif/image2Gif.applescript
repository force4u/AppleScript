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
############
set strMes to "イメージシーケンスの入っているフォルダを選んでください" as text
set strPrompt to "イメージシーケンスの入っているフォルダを選んでください" as text
try
	set aliasResponse to (choose folder strMes with prompt strPrompt default location aliasDefaultLocation with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
###
set strDirPath to (POSIX path of aliasResponse) as text
set ocidDirPathStr to refMe's NSString's stringWithString:(strDirPath)
set ocidDirPath to ocidDirPathStr's stringByStandardizingPath()
set ocidDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDirPath) isDirectory:false)
set strFileName to (ocidDirPathURL's lastPathComponent()) as text
set ocidContainerDirPathURL to ocidDirPathURL's URLByDeletingLastPathComponent()
set strGifFileName to (strFileName & ".gif")
set ocidSaveGifFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:(strGifFileName)
##
set strDirPath to (ocidDirPathURL's |path|()) as text
set strGifFilePath to (ocidSaveGifFilePathURL's |path|()) as text
delay 3
##
set strCommandText to ("pushd \"" & strDirPath & "/\" && " & strGifskiBinPath & " -o  \"" & strGifFilePath & "\"  *") as text
do shell script strCommandText

return

##FPS指定
set strCommandText to ("pushd \"" & strDirPath & "/\" && " & strGifskiBinPath & " -o  \"" & strGifFilePath & "\" --fps 50 *") as text
##サイズ指定
set strCommandText to ("pushd \"" & strDirPath & "/\" && " & strGifskiBinPath & " -o  \"" & strGifFilePath & "\" --fps 50  --width 360 --height 360 *") as text
##クオリティ指定　1−100
set strCommandText to ("pushd \"" & strDirPath & "/\" && " & strGifskiBinPath & " -o  \"" & strGifFilePath & "\" --fps 50  --width 360 --height 360 --quality 75 *") as text
##他オプション
(*

  -o, --output <a.gif>          Destination file to write to; "-" means stdout
  -r, --fps <num>               Frame rate of animation. If using PNG files as input, this means the speed, as all frames are kept. If video is used, it will be resampled to this constant rate by dropping and/or duplicating frames [default: 20]
      --fast-forward <x>        Multiply speed of video by a factor
                                (no effect when using images as input) [default: 1]
      --fast                    50% faster encoding, but 10% worse quality and larger file size
      --extra                   50% slower encoding, but 1% better quality
  -Q, --quality <1-100>         Lower quality may give smaller file [default: 90]
      --motion-quality <1-100>  Lower values reduce motion
      --lossy-quality <1-100>   Lower values introduce noise and streaks
  -W, --width <px>              Maximum width.
                                By default anims are limited to about 800x600
  -H, --height <px>             Maximum height (stretches if the width is also set)
      --no-sort                 Use files exactly in the order given, rather than sorted
  -q, --quiet                   Do not display anything on standard output/console
      --repeat <num>            Number of times the animation is repeated (-1 none, 0 forever or <value> repetitions
      --fixed-color <RGBHEX>    Always include this color in the palette
      --matte <RGBHEX>          Background color for semitransparent pixels
  -h, --help                    Print help
  -V, --version                 Print version


*)


