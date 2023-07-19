#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
error number -128
com.cocolog-nifty.quicktimer.icefloe
*)
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()
set appNSWorkspace to refMe's NSWorkspace's sharedWorkspace()

set ocidFalse to (refMe's NSNumber's numberWithBool:false)'s boolValue()
set ocidTrue to (refMe's NSNumber's numberWithBool:true)'s boolValue()


####################################
####デバイス名取得
####################################
##コマンド整形
set strCommandText to ("/bin/df -k") as text
##コマンド実行
set strDfResponse to (do shell script strCommandText) as text
##Stringsに
set ocdiDfResponse to refMe's NSString's stringWithString:(strDfResponse)
##改行指定
set ocidCharacterSet to refMe's NSCharacterSet's newlineCharacterSet()
##改行でリスト
set ocidStringArray to ocdiDfResponse's componentsSeparatedByCharactersInSet:(ocidCharacterSet)
##リストの数だけ繰返し
repeat with itemStringArray in ocidStringArray
	set strItemStringArray to itemStringArray as text
	##スペース指定
	set ocidCharacterSet to refMe's NSCharacterSet's whitespaceCharacterSet()
	set ocidDevArray to (itemStringArray's componentsSeparatedByCharactersInSet:(ocidCharacterSet))
	##デバイス名を取得
	set ocidDevicePath to (ocidDevArray's objectAtIndex:0)
	###CD/DVDデバイス用の整形表現
	set strRegPattern to "/dev/disk[0-9]+"
	###正規表現で判定項目を作って（マッチなら）
	set codiPridic to refMe's NSPredicate's predicateWithFormat_("(SELF MATCHES %@)", strRegPattern)
	###CD判定
	set boolCD to (codiPridic's evaluateWithObject:(ocidDevicePath))
	if boolCD is ocidTrue then
		log boolCD
		set strDevicePath to ocidDevicePath as text
		
		try
			set strCommandText to ("/usr/sbin/diskutil unmount " & strDevicePath & "") as text
			log strCommandText
			do shell script strCommandText
		on error
			set strCommandText to ("/usr/bin/sudo /sbin/umount " & strDevicePath & "") as text
			log strCommandText
			do shell script strCommandText with administrator privileges
		end try
		
	end if
end repeat

