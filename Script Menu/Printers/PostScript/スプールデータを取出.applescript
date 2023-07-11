#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
/usr/sbin/lpmove 
/usr/sbin/lpinfo 
/usr/sbin/lpc 
/usr/sbin/lpadmin 
/usr/bin/lpstat 
/usr/bin/lprm 
/usr/bin/lpr 
/usr/bin/lpq 
/usr/bin/lpoptions 
/usr/bin/lp 
*)
# 要管理者権限
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

#####UIDショートユーザー名
set ocidUserName to refMe's NSUserName()
set strShortUserName to ocidUserName as text
###コマンド
set strPrintQStr to do shell script "/usr/bin/lpq  -a -U " & strShortUserName & ""
####コマンドの戻り値からリストを作成
set ocidPrintQStr to refMe's NSString's stringWithString:strPrintQStr
set ocidTextNSArray to ocidPrintQStr's componentsSeparatedByString:"\r"
set ocidPrintQArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidPrintQArray's addObjectsFromArray:ocidTextNSArray
ocidPrintQArray's removeObjectAtIndex:0
set listPrintQArray to ocidPrintQArray as list


try
	set listResponse to (choose from list listPrintQArray with title "選んでください" with prompt "取り出すJOBを" default items (item 1 of listPrintQArray) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed)
on error
	log "エラーしました"
	return "エラーしました"
end try
if listResponse is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text
set ocidResponse to refMe's NSMutableString's alloc()'s initWithCapacity:0
ocidResponse's setString:strResponse
##他に方法ありそうな気もするけど…いったんスペースでArrayにして
set ocidResponseArray to ocidResponse's componentsSeparatedByString:" "
###空の項目はFalse
set ocidPredicate to (refMe's NSPredicate's predicateWithFormat:"SELF != ''")
##空の項目を削除したArray
set ocidResponseArray to ocidResponseArray's filteredArrayUsingPredicate:ocidPredicate

####ジョブ番号取得
set strJobNo to (ocidResponseArray's objectAtIndex:2) as text
set strFileName to (ocidResponseArray's objectAtIndex:3) as text

try
	set theComandText to ("/usr/bin/sudo /bin/chmod 777 /private/var/spool/cups") as text
	do shell script theComandText with administrator privileges
on error
	return "スプールにアクセスできませんした"
end try
###ファイル名整形
set strZeroAppend to "d00000" & strJobNo as text
set strFileNo to "d" & (text -5 through -1 of strZeroAppend) & "-001" as text
set strJobPath to ("/private/var/spool/cups/" & strFileNo & "") as text
(*
set strFilePath to POSIX path of strJobPath
set ocidFilePathStr to (refMe's NSString's stringWithString:strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false)
set listResults to ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLTypeIdentifierKey) |error|:(reference)
set strUTI to item 1 of listResults as text
*)
set theComandText to ("/usr/bin/sudo /bin/chmod 640 \"" & strJobPath & "\"") as text
do shell script theComandText with administrator privileges

set theComandText to "/usr/bin/sudo /usr/bin/file -b --mime-type \"" & strJobPath & "\""
set strUTI to do shell script theComandText with administrator privileges

log strUTI
if strUTI contains "postscript" then
	set strSaveFilePath to "~/Desktop/" & strFileNo & ".ps"
else if strUTI contains "pdf" then
	set strSaveFilePath to "~/Desktop/" & strFileNo & ".pdf"
end if

set theComandText to ("/usr/bin/sudo /bin/chmod 777 \"" & strJobPath & "\"") as text
do shell script theComandText with administrator privileges

set theComandText to ("/usr/bin/ditto  \"" & strJobPath & "\"  " & strSaveFilePath & "") as text
do shell script theComandText

set theComandText to ("/usr/bin/sudo /bin/chmod 750 \"/private/var/spool/cups\"") as text
do shell script theComandText with administrator privileges


