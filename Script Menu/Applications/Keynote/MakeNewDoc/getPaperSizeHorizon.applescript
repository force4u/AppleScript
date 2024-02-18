#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


set recordPageSizePt to {|Letter|:{612, 792}, |Legal|:{612, 1008}, |Executive|:{522, 756}, |Ledger|:{1224, 792}, |Tabloid|:{792, 1224}, |Screen|:{468, 373}, |AnsiC|:{1224, 1584}, |AnsiD|:{1584, 2448}, |AnsiE|:{2448, 3168}, |AnsiF|:{2016, 2880}, |ARCHA|:{648, 864}, |ARCHB|:{864, 1296}, |ARCHC|:{1296, 1728}, |ARCHD|:{1728, 2592}, |ARCHE|:{2592, 3456}, |ARCHE1|:{2160, 3024}, |ARCHE2|:{1872, 2736}, |ARCHE3|:{1944, 2808}, |A5|:{420, 595.22}, |A4|:{595.22, 842}, |A3|:{842, 1191}, |A2|:{1191, 1684}, |A1|:{1684, 2384}, |A0|:{2384, 3370}, |A4Extra|:{667, 914}, |A3Extra|:{913, 1262}, |OversizeA2|:{1361, 1772}, |OversizeA1|:{1772, 2551}, |OversizeA0|:{2551, 3529}, |ISOB5|:{499, 709}, |ISOB4|:{709, 1001}, |ISOB2|:{1417, 2004}, |ISOB1|:{2004, 2835}, |C5|:{459, 649}, |JISB5|:{516, 729}, |JISB4|:{729, 1032}, |JISB3|:{1032, 1460}, |JISB2|:{1460, 2064}, |JISB1|:{2064, 2920}, |JISB0|:{2920, 4127}, |Oversize92|:{6624, 6624}, |Slide7.5x10|:{540, 720}} as record
#
set ocidPageSizePtDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPageSizePtDict's setDictionary:(recordPageSizePt)
set ocidAllKeys to ocidPageSizePtDict's allKeys()
#
set ocidPageNameArray to refMe's NSMutableArray's arrayWithArray:(ocidAllKeys)
set ocidDescriptor to refMe's NSSortDescriptor's sortDescriptorWithKey:("self") ascending:(yes) selector:("localizedStandardCompare:")
set ocidDescriptorArray to refMe's NSArray's arrayWithObject:(ocidDescriptor)
set ocidPaperNameArray to ocidPageNameArray's sortedArrayUsingDescriptors:(ocidDescriptorArray)
set listPaperSizeName to ocidPaperNameArray as list
###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listPaperSizeName with title "選んでください" with prompt "用紙を選んでください" default items (item 1 of listPaperSizeName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text

#####
set listPaperSizePt to ocidPageSizePtDict's valueForKey:(strResponse)
log listPaperSizePt as list
set intWidthPt to (item 2 of listPaperSizePt) as integer
set intHeightPt to (item 1 of listPaperSizePt) as integer
#
set numVar to 25.4 as number
set numWidthMM to ((intWidthPt / 72) * numVar) as number
set numHeightMM to ((intHeightPt / 72) * numVar) as number
##

#####キーノートで新規書類を作成する
tell application "Keynote"
	activate
	set objNewDocument to (make new document with properties {name:"" & strResponse & "", height:"" & numHeightMM & "", width:"" & numWidthMM & "", slide numbers showing:true})
end tell
