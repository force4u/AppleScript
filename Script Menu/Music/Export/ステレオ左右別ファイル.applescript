#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AVFoundation"
use scripting additions

property refMe : a reference to current application


#################################
###ffmpeg へのパス
set strPathToFFMPEG to "echo $HOME/bin/ffmpeg/ffmpeg" as text
set strBinPath to (do shell script strPathToFFMPEG)

###入力
tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
####UTIリスト PDFのみ
set listUTI to {"public.audio"}

####ダイアログを出す
set aliasFilePath to (choose file with prompt "ファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias

tell application "Finder"
	set objInfo to info for aliasFilePath
	###入力ファイルの拡張子
	set strExtension to name extension of objInfo as text
end tell
###入力ファイルのパス
set strFilePath to POSIX path of aliasFilePath

#######################
##出力ファイルパス
#######################
set strExportFileNameLeft to ("" & strFilePath & ".L." & strExtension & "") as text
set strExportFileNameRight to ("" & strFilePath & ".R." & strExtension & "") as text
set strExportFileNameMono to ("" & strFilePath & ".Mono." & strExtension & "") as text
#######################
##コマンド整形 左右
#######################
set strCommandText to "\"" & strBinPath & "\"  -i \"" & strFilePath & "\"  -filter_complex \"[0:a]channelsplit=channel_layout=stereo[left][right]\" -map \"[left]\" \"" & strExportFileNameLeft & "\" -map \"[right]\" \"" & strExportFileNameRight & "\""
##実行
do shell script strCommandText

#######################
##コマンド整形　センターモノ
#######################
set strCommandText to "\"" & strBinPath & "\"  -i \"" & strFilePath & "\"  -ac 1  \"" & strExportFileNameMono & "\""
##実行
do shell script strCommandText

