#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
デスクトップ上にあるファイルやフォルダの
アイコンを表示するか？切り替えます
*)
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7


##############################################
## まずは今の設定を読み込む
##############################################
try
	set boolCreateDesktop to (do shell script "defaults read  com.apple.finder CreateDesktop") as integer
on error
	###値が無い場合はFalseの0を入れておく
	set boolCreateDesktop to 0 as integer
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

if boolCreateDesktop = 1 then
	display dialog "デスクトップのアイコンを隠します" with icon aliasIconPath
	
else if boolCreateDesktop = 0 then
	display dialog "デスクトップのアイコンを表示します" with icon aliasIconPath
	
end if
##############################################
## 今と逆の設定をする
##############################################
--> true １なら 
if boolCreateDesktop = 1 then
	--->0=FALSEに変える
	try
		do shell script "defaults write  com.apple.finder CreateDesktop -bool false"
	on error
		log "falseに変更できませんでした"
	end try
else if boolCreateDesktop = 0 then
	--->0なら--> 1=trueに変更する
	try
		do shell script "defaults write  com.apple.finder CreateDesktop -bool true"
	on error
		log "trueに変更できませんでした"
	end try
end if


---ファインダーを再起動して表示を確定
do shell script "killall Finder"


