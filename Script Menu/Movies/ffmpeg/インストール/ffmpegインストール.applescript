#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*インストール後のパス
$HOME/bin/ffmpeg.6.0/ffmpeg

$HOME/bin/ffmpeg.6.0/ffmpeg
$HOME/ffmpeg.6.0/ffplay
$HOME/ffmpeg.6.0/ffprobe

*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use framework "Foundation"
use AppleScript version "2.8"
use scripting additions


set theComandText to ("echo `date '+%Y%m%d_%H%M%S'`") as text
set theDate to (do shell script theComandText) as text

set strFfmpegURL to "https://evermeet.cx/ffmpeg/ffmpeg-6.0.zip" as text
set strFfprobeURL to "https://evermeet.cx/ffmpeg/ffprobe-6.0.zip" as text
set strFfplayURL to "https://evermeet.cx/ffmpeg/ffplay-6.0.zip" as text

set aliasHomeDir to path to home folder from user domain as alias
set strHomeDirPath to POSIX path of aliasHomeDir as text




set theCommandText to ("/bin/mkdir -pm 700  \"/tmp/" & theDate & "\"") as text
do shell script theCommandText


set theCommandText to ("/usr/bin/curl -L -o   \"/tmp/" & theDate & "/ffmpeg.zip\" \"" & strFfmpegURL & "\" --connect-timeout 20") as text
do shell script theCommandText


set theCommandText to ("/usr/bin/curl -L -o    \"/tmp/" & theDate & "/ffprobe.zip\" \"" & strFfprobeURL & "\" --connect-timeout 20") as text
do shell script theCommandText

set theCommandText to ("/usr/bin/curl -L -o    \"/tmp/" & theDate & "/ffplay.zip\" \"" & strFfplayURL & "\" --connect-timeout 20") as text
do shell script theCommandText

set theCommandText to ("/bin/mkdir -p  \"" & strHomeDirPath & "bin/ffmpeg.6\"") as text
do shell script theCommandText

set theCommandText to ("/bin/chmod 700  \"" & strHomeDirPath & "bin/ffmpeg.6\"") as text
do shell script theCommandText

try
	set theCommandText to ("/usr/bin/touch $HOME/bin/ffmpeg.6/ffmpeg") as text
	do shell script theCommandText
	set theCommandText to ("/bin/rm -f $HOME/bin/ffmpeg.6/ffmpeg") as text
	do shell script theCommandText
	set theCommandText to ("/usr/bin/unzip    \"/tmp/" & theDate & "/ffmpeg.zip\" -d $HOME/bin/ffmpeg.6") as text
	do shell script theCommandText
end try
try
	set theCommandText to ("/usr/bin/touch $HOME/bin/ffmpeg.6/ffprobe") as text
	do shell script theCommandText
	set theCommandText to ("/bin/rm -f $HOME/bin/ffmpeg.6/ffprobe") as text
	do shell script theCommandText
	set theCommandText to ("/usr/bin/unzip    \"/tmp/" & theDate & "/ffprobe.zip\" -d $HOME/bin/ffmpeg.6") as text
	do shell script theCommandText
end try
try
	set theCommandText to ("/usr/bin/touch $HOME/bin/ffmpeg.6/ffplay") as text
	do shell script theCommandText
	set theCommandText to ("/bin/rm -f $HOME/bin/ffmpeg.6/ffplay") as text
	do shell script theCommandText
	set theCommandText to ("/usr/bin/unzip    \"/tmp/" & theDate & "/ffplay.zip\" -d $HOME/bin/ffmpeg.6") as text
	do shell script theCommandText
end try


### $HOME/bin/ffmpeg にシンボリックリンク

try
	set theCommandText to ("/bin/rm -f  $HOME/bin/ffmpeg") as text
	do shell script theCommandText
end try


try
	set theCommandText to ("/bin/ln -s $HOME/bin/ffmpeg.6 $HOME/bin/ffmpeg") as text
	do shell script theCommandText
end try
set strBinDir to (do shell script "/bin/echo $HOME/bin/ffmpeg") as text
set aliasDirPath to (POSIX file strBinDir) as alias
tell application "Finder"
	
	open aliasDirPath
end tell

return
