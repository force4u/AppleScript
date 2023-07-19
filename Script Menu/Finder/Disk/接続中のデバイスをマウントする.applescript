#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

#######################################
####### 外付けHDDのリストを取得
#######################################
set strCommandText to "/usr/sbin/diskutil list  -plist external" as text
set strPlist to do shell script strCommandText
#######################################
####### 戻り値をテキスト-->data-->PLISTに順に変換
#######################################
###テキストに
set ocidPlistStr to refMe's NSString's stringWithString:strPlist
###データに
set ocidPlistData to ocidPlistStr's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
###PLISTはXML形式で
set ocidXmlplist to refMe's NSPropertyListXMLFormat_v1_0
###PLISTデータに変換
set lisrResponse to refMe's NSPropertyListSerialization's propertyListWithData:ocidPlistData options:0 format:ocidXmlplist |error|:(reference)
###PLISTデータの格納用のレコード
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###PLISTデータをディクショナリに格納
set ocidPlistDict to (item 1 of lisrResponse)
#######################################
####### PLISTからドライブ名とデバイスIDを取得する
#######################################
#####戻り値用のリストを初期化
set listVolumeName to {} as list

#####ディスク情報
set arrayAllDisksAndPartitions to ocidPlistDict's valueForKey:"AllDisksAndPartitions"
#####ディスク情報の数だけ繰り返し
repeat with itemAllDisksAndPartitions in arrayAllDisksAndPartitions
	####ディスクのパーティション情報を取得
	set arrayPartition to (itemAllDisksAndPartitions's valueForKey:"Partitions")
	###パーティションの数を数えてて
	set numCntPartition to (count of arrayPartition) as integer
	###データ取得用のカウンター初期化
	set numCnkCntPartition to 0 as integer
	####パティションの数だけ繰り返し
	repeat numCntPartition times
		####順番にパーティション情報
		set ocidPartitionItem to (arrayPartition's objectAtIndex:numCnkCntPartition)
		###デバイスIDを取得
		set strDeviceID to (ocidPartitionItem's valueForKey:"DeviceIdentifier") as text
		####ボリューム名を取得
		set strVolumeName to (ocidPartitionItem's valueForKey:"VolumeName") as text
		####EFI以外の名称なら
		if strVolumeName is not "EFI" then
			####ボリュームとデバイスIDを整形して
			set strVolInfo to ("" & strVolumeName & "\t" & strDeviceID & "") as text
			#####戻り値用のリストに入れる
			copy strVolInfo to end of listVolumeName
		end if
		####カウントアップ
		set numCnkCntPartition to numCnkCntPartition + 1 as integer
	end repeat
	
end repeat
####出来上がったリスト
log listVolumeName
#################################################
####### USBメモリはアンマウント＝取り外しなので認識できない
#################################################
if (count of listVolumeName) = 0 then
	log "USBメモリー等は抜き差しが必要です"
	set listVolumeName to {"接続されているMac用ボリュームは見つかりません"} as list
	##	return "接続されているMac用ボリュームは見つかりません"
end if
#######################################
####### リストから選択ダイアログを出す
#######################################
try
	set listResponse to (choose from list listVolumeName with title "選んでください" with prompt "接続中のデバイス" default items (item 1 of listVolumeName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
else if (item 1 of listResponse) is "接続されているMac用ボリュームは見つかりません" then
	display alert "USBメモリー等は抜き差しが必要です"
	return "キャンセルしました"
end if
##ダイアログの戻り値確定
set strResponse to (item 1 of listResponse) as text
#######################################
####### ダイアログの戻り値からデバイスIDを取り出す
#######################################
set strDelim to AppleScript's text item delimiters
set AppleScript's text item delimiters to "\t"
set listResponseText to every text item of strResponse
set AppleScript's text item delimiters to strDelim
###デバイスID
set strDeviceID to item 2 of listResponseText

#######################################
####### コマンド整形してディスクをマウントする
#######################################
set strCommandText to "/usr/sbin/diskutil mount /dev/" & strDeviceID & ""
try
	do shell script strCommandText
on error
	log "エラーしました"
end try
