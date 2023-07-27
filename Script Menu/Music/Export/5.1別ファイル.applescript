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
####UTIリスト 
set listUTI to {"public.mpeg-2-transport-stream", "public.audio", "public.video"}

####ダイアログを出す
set aliasFilePath to (choose file with prompt "ファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias


###入力ファイルのパス
set strFilePath to POSIX path of aliasFilePath

#######################
##出力ファイルパス
#######################

set strExtension to "wav"

set strExportFileNameFL to ("" & strFilePath & ".FL." & strExtension & "") as text
set strExportFileNameFR to ("" & strFilePath & ".FR." & strExtension & "") as text
set strExportFileNameFC to ("" & strFilePath & ".FC." & strExtension & "") as text
set strExportFileNameLFE to ("" & strFilePath & ".LFE." & strExtension & "") as text
set strExportFileNameBL to ("" & strFilePath & ".BL." & strExtension & "") as text
set strExportFileNameFBR to ("" & strFilePath & ".BR." & strExtension & "") as text



set strCommandText to "\"" & strBinPath & "\"  -i \"" & strFilePath & "\" -vn -filter_complex \"channelsplit=channel_layout=5.1[FL][FR][FC][LFE][BL][BR]\" -map \"[FL]\" \"" & strExportFileNameFL & "\" -map \"[FR]\" \"" & strExportFileNameFR & "\"  -map \"[FC]\" \"" & strExportFileNameFC & "\"  -map \"[LFE]\" \"" & strExportFileNameLFE & "\"  -map \"[BL]\" \"" & strExportFileNameBL & "\"  -map \"[BR]\" \"" & strExportFileNameFBR & "\""


##実行
##### コマンド実行
tell application "Terminal"
	launch
	activate
	set objWindowID to (do script "\n\n")
	delay 1
	do script strCommandText in objWindowID
end tell

