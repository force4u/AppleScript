#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
全部終了するのに５分ほどかかります
com.cocolog-nifty.quicktimer.icefloe
*)
#  
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

set listPackages to {"pip", "setuptools", "Pillow", "wheel", "reportlab", "svglib"} as list

try
	do shell script "/usr/bin/xcode-select --install"
end try

log "コマンドラインツールのインストール確認"
try
	set theCmdText to ("mkdir -pm 700  $HOME/bin") as text
	do shell script theCmdText
end try

###
log "モジュールインストールディレクトリの確認"


try
	set theCmdText to ("/bin/mkdir -pm  777 $HOME/Library/Caches/pip") as text
	do shell script theCmdText
end try
try
	set theCmdText to ("/bin/mkdir -pm  777 $HOME/Library/Caches/com.apple.python") as text
	do shell script theCmdText
end try

try
	set theCmdText to ("/bin/mkdir -pm  777    $HOME/Library/Python/3.9/lib/python/site-packages") as text
	do shell script theCmdText
end try


log "モジュールインストールの確認中"
#######################################################

repeat with itemPackages in listPackages
	set strPackages to itemPackages as text
	set strCommandText to ("/usr/bin/python3  -m pip install --user " & strPackages & "") as text
	tell application "Terminal"
		launch
		activate
		set objWindowID to (do script "\n\n")
		delay 1
		do script strCommandText in objWindowID
		delay 2
		do script "\n\n" in objWindowID
		#		do script "exit" in objWindowID
		#		set theWid to get the id of window 1
		#		delay 1
		#		close front window saving no
	end tell
	log "モジュールインストールの確認中　" & strPackages & " ok"
end repeat

#########################
log "インストールチェック処理が終了"

repeat with itemPackages in listPackages
	set strPackages to itemPackages as text
	set strCommandText to ("/usr/bin/python3  -m pip install --upgrade  --user " & strPackages & "") as text
	tell application "Terminal"
		launch
		activate
		set objWindowID to (do script "\n\n")
		delay 1
		do script strCommandText in objWindowID
		delay 2
		do script "\n\n" in objWindowID
		#		do script "exit" in objWindowID
		#		set theWid to get the id of window 1
		#		delay 1
		#		close front window saving no
	end tell
	log "モジュールインストールの確認中　" & strPackages & " ok"
end repeat
log "アップデート処理が終了"

#########################

set strCommandText to "/usr/bin/python3  -m pip list --user"
tell application "Terminal"
	launch
	activate
	set objWindowID to (do script "\n\n")
	delay 1
	do script strCommandText in objWindowID
	delay 2
	do script "\n\n" in objWindowID
	#		do script "exit" in objWindowID
	#		set theWid to get the id of window 1
	#		delay 1
	#		close front window saving no
end tell


display notification "処理終了" with title "処理が終了" subtitle "処理が終了しました" sound name "Sonumi"
