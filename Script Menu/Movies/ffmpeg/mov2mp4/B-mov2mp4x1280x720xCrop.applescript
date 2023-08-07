#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application

################################
####設定項目
################################
set strPathToFFMPEG to "/bin/echo $HOME/bin/ffmpeg/ffmpeg" as text
set strPathToFFMPEG to (do shell script strPathToFFMPEG)

set strPathToFFMPEG to "/usr/local/bin/ffmpeg" as text


################################
#####ダイアログを前面に
################################
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set listAliasFile to (choose file "ファイルを選んでください" with prompt "ファイルを選んでください" default location (path to desktop folder from user domain) of type {"com.apple.quicktime-movie", "public.movie"} with invisibles, showing package contents and multiple selections allowed) as list

repeat with itemAliasFile in listAliasFile
	set aliasFile to itemAliasFile as alias
	set strFilePath to (POSIX path of aliasFile) as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	##コンテナ
	set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
	##拡張子をとったファイル名
	set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
	set strBaeFileFileName to (ocidBaseFilePathURL's lastPathComponent()) as text
	##上書き防止に日付連番
	set strDateNo to (doGetDateNo({"yyyyMMdd", 1})) as text
	##保存ファイル名
	set strSaveFileName to (strBaeFileFileName & "." & strDateNo & ".mp4") as text
	##保存URL
	set ocidSaveFilePathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:(strSaveFileName))
	set strSaveFilePath to ocidSaveFilePathURL's |path| as text
	(* 
################ ビデオ
### bitrate
-vb 720k
-vb 3600k
-vb 7200k 
-vb 1080k 
### FPS
 -r 23.9
 -r 24
 -r 30
 -r 50
 -r 60
 -r 120
###
 -codec:v  libx264 
 -codec:v  libx265 
 -codec:v  h264_videotoolbox 
###
-profile:v baseline
-profile:v main
-profile:v high
-profile:v high10
-profile:v high422
-profile:v high444
###
 -tune film
 -tune animation
 -tune grain
 -tune stillimage
 -tune fastdecode
 -tune zerolatency
###
 -preset ultrafast
 -preset superfast
 -preset veryfast
 -preset faster
 -preset fast
 -preset medium
 -preset slow
 -preset slower
 -preset veryslow
###
 -crf 0
 -crf 22
 -crf 28
 -crf 63
### Pillarbox 
-vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:-1:-1:color=black"
### crop
-vf "scale=1280:720:force_original_aspect_ratio=increase, crop=1280:720"
### 幅合わせ　 高自動　
-vf "scale=1280:-2"
###高さ合わせ　幅自動
-vf "scale=-2:720"
################ オーディオ
###
-codec:a  copy
-codec:a  aac
-codec:a  aac_at
-codec:a  libfdk_aac
-codec:a  libmp3lame
###　ビットレート　bitrates
-b:a 32k
-b:a 96k
-b:a 128k
-b:a 256k
-b:a 320k
-b:a 512k
###サンプルレート Samplerate
-ar 16K 
-ar 22050
-ar 32K 
-ar 44100
-ar 48K 
-ar 96K 
-ar 192K 
###
-codec:a  libmp3lame  -ar 48K -ab 320k
-codec:a  aac  -ar 32K -ab 128k
	*)
	
	
	set strCommandText to ("\"" & strPathToFFMPEG & "\" -i '" & strFilePath & "'   -codec:v  libx264 -profile:v baseline  -vf \"scale=1280:720:force_original_aspect_ratio=increase, crop=1280:720\"  -tune film  -crf 28 -codec:a  aac  -ar 48K -ab 128k '" & strSaveFilePath & "'") as text
	
	
	tell application "Terminal"
		launch
		activate
		set objWindowID to (do script "\n\n")
		delay 1
		do script strCommandText in objWindowID
		
	end tell
	
	
end repeat





################################
# 日付 doGetDateNo(argDateFormat,argCalendarNO)
# argCalendarNO 1 NSCalendarIdentifierGregorian 西暦
# argCalendarNO 2 NSCalendarIdentifierJapanese 和暦
################################
to doGetDateNo({argDateFormat, argCalendarNO})
	##渡された値をテキストで確定させて
	set strDateFormat to argDateFormat as text
	set intCalendarNO to argCalendarNO as integer
	###日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義（日本語）
	set ocidFormatterJP to current application's NSDateFormatter's alloc()'s init()
	###和暦　西暦　カレンダー分岐
	if intCalendarNO = 1 then
		set ocidCalendarID to (current application's NSCalendarIdentifierGregorian)
	else if intCalendarNO = 2 then
		set ocidCalendarID to (current application's NSCalendarIdentifierJapanese)
	else
		set ocidCalendarID to (current application's NSCalendarIdentifierISO8601)
	end if
	set ocidCalendarJP to current application's NSCalendar's alloc()'s initWithCalendarIdentifier:(ocidCalendarID)
	set ocidTimezoneJP to current application's NSTimeZone's alloc()'s initWithName:("Asia/Tokyo")
	set ocidLocaleJP to current application's NSLocale's alloc()'s initWithLocaleIdentifier:("ja_JP_POSIX")
	###設定
	ocidFormatterJP's setTimeZone:(ocidTimezoneJP)
	ocidFormatterJP's setLocale:(ocidLocaleJP)
	ocidFormatterJP's setCalendar:(ocidCalendarJP)
	#	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterNoStyle)
	#	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterShortStyle)
	#	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterMediumStyle)
	#	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterLongStyle)
	ocidFormatterJP's setDateStyle:(current application's NSDateFormatterFullStyle)
	###渡された値でフォーマット定義
	ocidFormatterJP's setDateFormat:(strDateFormat)
	###フォーマット適応
	set ocidDateAndTime to ocidFormatterJP's stringFromDate:(ocidDate)
	###テキストで戻す
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
