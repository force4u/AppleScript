#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
BaseScript 
https://www.macscripter.net/t/edit-db123s-dialog-for-use-with-asobjc/
*)
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use framework "Foundation"
use framework "AppKit"
#use framework "Carbon"
use scripting additions
property refMe : current application


###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###ダイアログ
set listRect to doDialoge()
if listRect is false then
	return "キャンセルしました"
end if
###戻り値
set strH to (item 2 of listRect) as text
set strW to (item 1 of listRect) as text
set strP to (item 3 of listRect) as text
###戻り値整形
set numH to doText2Integer(strH) as number
set numW to doText2Integer(strW) as number
set numP to doText2Integer(strP) as number

log numH
##############################
#####計算部
##############################
set numVar to 25.4 as number
###
set numRawH to (numH / numVar) as number
set numRawW to (numW / numVar) as number
log numRawH
###
set numPxH to (round of (numRawH * numP) rounding down) as integer
set numPxW to (round of (numRawW * numP) rounding down) as integer
##############################
#####戻り値表示
##############################
set strMes to ("横mm:" & strW & "\n縦mm:" & strH & "\n解像度ppi:" & strP & "の計算結果\n横px:" & numPxW & "\n縦px:" & numPxH & "\n") as text
set strAns to ("width: " & numPxW & "px; height: " & numPxH & "px;") as text
###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
try
	set recordResult to (display dialog (strMes & strAns) with title "計算結果です" default answer strAns buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer) as record
on error
	log "エラーしました"
	return "エラーしました"
end try
if (gave up of recordResult) is true then
	return "時間切れです"
end if
##############################
#####値のコピー
##############################
if button returned of recordResult is "クリップボードにコピー" then
	try
		set strText to text returned of recordResult as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strText as text
		end tell
	end try
end if
##############################
#####戻り値整形
##############################
to doText2Integer(argText)
	set ocidResponseText to (refMe's NSString's stringWithString:(argText))
	###タブと改行を除去しておく
	set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
	ocidTextM's appendString:(ocidResponseText)
	##改行除去
	set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\n") withString:("")
	set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\r") withString:("")
	##タブ除去
	set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("\t") withString:("")
	####戻り値を半角にする
	set ocidNSStringTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
	set ocidTextM to (ocidTextM's stringByApplyingTransform:ocidNSStringTransform |reverse|:false)
	##カンマ置換
	set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:(",") withString:(".")
	###テキストにしてから
	set strTextM to ocidTextM as text
	###数値にして戻す
	return strTextM as number
end doText2Integer


############################
###３段ダイアログ
############################
property appDialogWindow : missing value
property appCancelButton : missing value
property appOkButton : missing value
property appOkClicked : false

property strOneTextField : missing value
property strTwoTextField : missing value
property strThreeTextField : missing value

property strOne : missing value
property strTwo : missing value
property strThree : missing value


to doDialoge()
	set dialogResult to my doShowDialog()
	if dialogResult is missing value then
		return false
	end if
	set {strOne, strTwo, strThree} to {strOne, strTwo, strThree} of dialogResult
	return {strOne, strTwo, strThree} as list
end doDialoge

on doShowDialog()
	if refMe's AEInteractWithUser(-1, missing value, missing value) ≠ 0 then
		return missing value
	end if
	if refMe's NSThread's isMainThread() then
		my doPerformDialog:(missing value)
	else
		its performSelectorOnMainThread:("doPerformDialog:") withObject:(missing value) waitUntilDone:true
	end if
	if my appOkClicked then
		return {strOne:my strOne as text, strTwo:my strTwo as text, strThree:my strThree as text}
	end if
	return missing value
end doShowDialog

on doPerformDialog:(args)
	set strOneLabel to refMe's NSTextField's labelWithString:("幅w mm:")
	strOneLabel's setFrame:(refMe's NSMakeRect(20, 120, 70, 20))
	
	set my strOneTextField to refMe's NSTextField's textFieldWithString:""
	strOneTextField's setFrame:(refMe's NSMakeRect(87, 120, 245, 20))
	strOneTextField's setEditable:true
	strOneTextField's setBordered:true
	strOneTextField's setPlaceholderString:("幅サイズmm数値入力")
	
	
	set strTwoLabel to refMe's NSTextField's labelWithString:("縦h mm:")
	strTwoLabel's setFrame:(refMe's NSMakeRect(20, 90, 70, 20))
	
	set my strTwoTextField to refMe's NSTextField's textFieldWithString:("")
	strTwoTextField's setFrame:(refMe's NSMakeRect(87, 90, 245, 20))
	strTwoTextField's setEditable:true
	strTwoTextField's setBordered:true
	strTwoTextField's setPlaceholderString:("縦サイズmm入力")
	
	set strThreeLabel to refMe's NSTextField's labelWithString:("解像度ppi:")
	strThreeLabel's setFrame:(refMe's NSMakeRect(20, 55, 70, 20))
	
	set my strThreeTextField to refMe's NSTextField's textFieldWithString:("")
	strThreeTextField's setFrame:(refMe's NSMakeRect(87, 55, 245, 20))
	strThreeTextField's setEditable:true
	strThreeTextField's setBordered:true
	strThreeTextField's setPlaceholderString:("解像度ppi数値入力")
	strThreeTextField's setDelegate:(me)
	
	set my appCancelButton to refMe's NSButton's buttonWithTitle:"Cancel" target:me action:"doButtonAction:"
	appCancelButton's setFrameSize:{94, 32}
	appCancelButton's setFrameOrigin:{150, 10}
	appCancelButton's setKeyEquivalent:(character id 27)
	
	set my appOkButton to refMe's NSButton's buttonWithTitle:"OK" target:me action:"doButtonAction:"
	appOkButton's setFrameSize:{94, 32}
	appOkButton's setFrameOrigin:{245, 10}
	appOkButton's setKeyEquivalent:return
	appOkButton's setEnabled:false
	
	set ocidWindowSize to refMe's NSMakeRect(0, 0, 380, 160)
	set ocidWinStyle to (refMe's NSWindowStyleMaskTitled as integer) + (refMe's NSWindowStyleMaskClosable as integer)
	set my appDialogWindow to refMe's NSWindow's alloc()'s initWithContentRect:(ocidWindowSize) styleMask:(ocidWinStyle) backing:(refMe's NSBackingStoreBuffered) defer:true
	
	appDialogWindow's contentView()'s addSubview:(strOneLabel)
	appDialogWindow's contentView()'s addSubview:(strOneTextField)
	
	appDialogWindow's contentView()'s addSubview:(strTwoLabel)
	appDialogWindow's contentView()'s addSubview:(strTwoTextField)
	
	appDialogWindow's contentView()'s addSubview:(strThreeLabel)
	appDialogWindow's contentView()'s addSubview:(strThreeTextField)
	
	appDialogWindow's contentView()'s addSubview:(appCancelButton)
	appDialogWindow's contentView()'s addSubview:(appOkButton)
	
	appDialogWindow's setTitle:"数値換算"
	appDialogWindow's setLevel:(refMe's NSModalPanelWindowLevel)
	appDialogWindow's setDelegate:(me)
	appDialogWindow's orderFront:(me)
	appDialogWindow's |center|()
	
	refMe's NSApp's activateIgnoringOtherApps:true
	refMe's NSApp's runModalForWindow:(appDialogWindow)
end doPerformDialog:

on doButtonAction:(sender)
	if sender is my appOkButton then
		set my strOne to strOneTextField's stringValue()
		set my strTwo to strTwoTextField's stringValue()
		set my strThree to strThreeTextField's stringValue()
		set my appOkClicked to true
	end if
	my appDialogWindow's |close|()
end doButtonAction:

on controlTextDidChange:(objNotification)
	set sender to objNotification's object()
	if sender is my strThreeTextField then
		if sender's stringValue() as text ≠ "" then
			my (appOkButton's setEnabled:true)
		else
			my (appOkButton's setEnabled:false)
		end if
	end if
end controlTextDidChange:

on windowWillClose:(objNotification)
	refMe's NSApp's stopModal()
end windowWillClose:


