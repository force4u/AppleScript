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


#####ネットワークサービスの一覧
set strNetWorkServices to (do shell script "/usr/sbin/networksetup -listallnetworkservices") as text
set ocidNetWorkServices to refMe's NSString's stringWithString:strNetWorkServices
set ocidNSArrayNetWorkServices to ocidNetWorkServices's componentsSeparatedByString:"\r"
ocidNSArrayNetWorkServices's removeObjectAtIndex:0

try
	set objResponse to (choose from list (ocidNSArrayNetWorkServices as list) with title "選んでください" with prompt "WIFIポートを選んでください" default items (item 1 of (ocidNSArrayNetWorkServices as list)) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed)
on error
	log "エラーしました"
	return
end try
if objResponse is false then
	return
end if
set strNetWorkName to (objResponse) as text

#####ハードウェアポートの一覧
set strHardWarePorts to (do shell script "/usr/sbin/networksetup -listallhardwareports") as text
set ocidHardWarePorts to refMe's NSString's stringWithString:strHardWarePorts
set ocidNSArrayNetWorkPorts to ocidHardWarePorts's componentsSeparatedByString:"\r\r"

#####ポート分繰り返し
repeat with objNetWorkPorts in ocidNSArrayNetWorkPorts
	set strNetWorkPorts to objNetWorkPorts as text
	if strNetWorkPorts contains strNetWorkName then
		#####文字列を整形
		set ocidNetWorkPorts to (refMe's NSString's stringWithString:strNetWorkPorts)
		set ocidSelectNetWorkPorts to (ocidNetWorkPorts's componentsSeparatedByString:"\r")
		set ocidDeviceLinet to (ocidSelectNetWorkPorts's objectAtIndex:1)
		#####デバイス名を取得
		set ocidSearchString to (refMe's NSString's stringWithString:"Device: ")
		set ocidReplacementString to (refMe's NSString's stringWithString:"")
		set ocidDeviceName to (ocidDeviceLinet's stringByReplacingOccurrencesOfString:ocidSearchString withString:ocidReplacementString)
		
	end if
end repeat
####対象のデバイスの電源を取得
set strWifiStatus to (do shell script "/usr/sbin/networksetup -getairportpower '" & ocidDeviceName & "'") as text
set ocidWifiStatus to (refMe's NSString's stringWithString:strWifiStatus)
set ocidArrayWifiStatus to (ocidWifiStatus's componentsSeparatedByString:": ")
set ocidWifiStatus to (ocidArrayWifiStatus's objectAtIndex:1)

####OFF-ON処理
if (ocidWifiStatus as text) contains "On" then
	try
		do shell script "/usr/sbin/networksetup -setairportpower '" & strNetWorkName & "' off"
	end try
else
	try
		do shell script "/usr/sbin/networksetup -setairportpower '" & strNetWorkName & "' on"
	end try
end if


return
