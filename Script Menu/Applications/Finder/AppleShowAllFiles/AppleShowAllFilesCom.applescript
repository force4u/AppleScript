#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　
(*
ファイルの表示を切り替えます
*)
#
#
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

try
	---AppleShowAllFilesを調べて
	set numResponce to (do shell script "defaults read  com.apple.finder AppleShowAllFiles") as number
	---１なら
	if numResponce = 1 then
		---不可視ファイルを表示しないに変更
		do shell script "defaults write  com.apple.finder AppleShowAllFiles -bool NO"
	else
		---不可視ファイルを表示するに変更
		do shell script "defaults write  com.apple.finder AppleShowAllFiles -bool YES"
	end if
on error
	---エラーが発生したらとりあえず　不可視ファイルを表示しないに変更
	do shell script "defaults write  com.apple.finder AppleShowAllFiles -bool NO"
end try
---ファインダーを再起動して表示を確定
do shell script "killall Finder"