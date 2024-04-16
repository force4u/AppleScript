#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
Finderに不可視ファイルを表示するか？を切り替えます
今：不可視ファイル表示→通常表示に切り替え
今：通常表示なら→不可視ファイル表示に切り替えます
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

##############################################
## ファイルパス関連
##############################################
####preferences folderまでのパス
set strPlistFileName to "com.apple.finder.plist" as text

set aliasPreferencesDir to (path to preferences folder from user domain) as alias
tell application "Finder"
	set alisPrefFilePath to (file strPlistFileName of folder aliasPreferencesDir) as alias
end tell
####ファイル名と繋げてUNIXパスにする
set strPlistPath to (POSIX path of alisPrefFilePath) as text
##############################################
## まずは今の設定を読み込む
##############################################
try
	set boolResponse to (do shell script "/usr/libexec/PlistBuddy -c \"Print:AppleShowAllFiles:\"  \"" & strPlistPath & "\"") as boolean
on error
	###値が無い場合はFalseの0を入れておく
	set boolResponse to true as boolean
end try

##############################################
## 今の設定内容と逆のことを実行する
##############################################
###ダイアログを前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FinderIcon.icns" as alias

if boolResponse is true then
	display dialog "不可視ファイルを隠します" with icon aliasIconPath
else if boolResponse is false then
	display dialog "不可視ファイルを表示します" with icon aliasIconPath
end if
##############################################
## 今と逆の設定をする
##############################################
--> true １なら 
if boolResponse is true then
	--->0=FALSEに変える
	try
		do shell script "/usr/libexec/PlistBuddy -c \"Set:AppleShowAllFiles false\"  \"" & strPlistPath & "\""
	on error
		return "falseに変更できませんでした"
	end try
else if boolResponse is false then
	--->0なら--> 1=trueに変更する
	try
		do shell script "/usr/libexec/PlistBuddy -c \"Set:AppleShowAllFiles true\"  \"" & strPlistPath & "\""
	on error
		return "trueに変更できませんでした"
	end try
end if
##変更内容を保存
do shell script "/usr/libexec/PlistBuddy -c \"Save\"  \"" & strPlistPath & "\""


##############################################
## 設定チェック
##############################################
try
	set boolResponse to (do shell script "/usr/libexec/PlistBuddy -c \"Print:AppleShowAllFiles\"  \"" & strPlistPath & "\"") as boolean
	log "値を:" & boolResponse & "に変更しました"
on error
	log "処理がエラーで終了しました"
end try

---ファインダーを再起動して表示を確定
do shell script "killall Finder"


