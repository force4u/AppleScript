#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
ダイアログ部ベーススクリプト
https://www.macscripter.net/t/edit-db123s-dialog-for-use-with-asobjc/73636/2
*)
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
#use framework "Carbon"
use scripting additions
property refMe : a reference to current application

doDialoge()

#####################
### 
property appDialogWindow : missing value
property strOneTextField : missing value
property strTwoTextField : missing value
property appCancelButton : missing value
property appOkButton : missing value
property strOne : missing value
property strTwo : missing value
property appOkClicked : false
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807


to doDialoge()
	
	##############################
	#####ダイアログ
	##############################
	tell current application
		set strName to name as text
	end tell
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder"
			activate
		end tell
	else
		tell current application
			activate
		end tell
	end if
	
	set dialogResult to my doShowDialog()
	if dialogResult is missing value then
		return "【エラー】キャンセルしました"
	end if
	set strReturnedTextX to strOne of dialogResult
	set strReturnedTextY to strTwo of dialogResult
	
	##############################
	#####戻り値整形
	##############################
	set ocidResponseText to (refMe's NSString's stringWithString:(strReturnedTextX))
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
	###数字以外の値を取る
	#set ocidDecSet to refMe's NSCharacterSet's decimalDigitCharacterSet
	#set ocidCharSet to ocidDecSet's invertedSet()
	#set ocidCharArray to ocidResponseHalfwidth's componentsSeparatedByCharactersInSet:ocidCharSet
	#set ocidInteger to ocidCharArray's componentsJoinedByString:""
	###テキストにしてから
	set strTextM to ocidTextM as text
	###数値に
	set strReturnedTextX to strTextM as number
	
	###
	set ocidResponseText to (refMe's NSString's stringWithString:(strReturnedTextY))
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
	###数字以外の値を取る
	#set ocidDecSet to refMe's NSCharacterSet's decimalDigitCharacterSet
	#set ocidCharSet to ocidDecSet's invertedSet()
	#set ocidCharArray to ocidResponseHalfwidth's componentsSeparatedByCharactersInSet:ocidCharSet
	#set ocidInteger to ocidCharArray's componentsJoinedByString:""
	###テキストにしてから
	set strTextM to ocidTextM as text
	###数値に
	set strReturnedTextY to strTextM as number
	
	##############################
	#####計算部
	##############################
	
	
	###そのまま
	set numRaw to (strReturnedTextX / strReturnedTextY) as number
	set numRaw to (strReturnedTextY / strReturnedTextX) as number
	set strMes to ("計算結果です:" & numRaw & "　\r") as text
	
	###整数切り捨て
	set intDown to ((round of ((numRaw) * 1000) rounding down) / 1000) * 100 as number
	log intDown
	set strMes to (strMes & "パーセント:" & intDown & "% \r") as text
	
	###切り捨て　小数点２
	set num2Dec to ((round of ((numRaw) * 100) rounding down) / 100) as number
	log num2Dec
	set strMes to (strMes & "小数点２位:" & num2Dec & "\r") as text
	###切り捨て　小数点3
	set num3Dec to ((round of ((numRaw) * 1000) rounding down) / 1000) as number
	log num3Dec
	set strMes to (strMes & "小数点3位:" & num3Dec & "\r") as text
	###切り捨て　小数点4
	set num4Dec to ((round of ((numRaw) * 10000) rounding down) / 10000) as number
	log num4Dec
	set strMes to (strMes & "小数点4位:" & num4Dec & "\r") as text
	####
	set strMes to (strMes & "小数点以下計算は切り捨て\r") as text
	##############################
	#####ダイアログ
	##############################
	tell current application
		set strName to name as text
	end tell
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder"
			activate
		end tell
	else
		tell current application
			activate
		end tell
	end if
	set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
	
	try
		set recordResult to (display dialog strMes with title strMes default answer numRaw buttons {"クリップボードにコピー", "もう一度", "終了"} default button "もう一度" cancel button "終了" giving up after 20 with icon aliasIconPath without hidden answer) as record
	on error
		log "エラーしました"
		return
	end try
	log recordResult
	if button returned of recordResult is "もう一度" then
		doDialoge()
	else if (gave up of recordResult) is true then
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
end doDialoge



####################################
###### ダイアログ
####################################

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
		return {strOne:my strOne as text, strTwo:my strTwo as text}
	end if
	return missing value
end doShowDialog

on doPerformDialog:(args)
	set strOneLabel to refMe's NSTextField's labelWithString:("X size:")
	strOneLabel's setFrame:(refMe's NSMakeRect(20, 85, 70, 20))
	
	set my strOneTextField to refMe's NSTextField's textFieldWithString:""
	strOneTextField's setFrame:(refMe's NSMakeRect(87, 85, 245, 20))
	strOneTextField's setEditable:true
	strOneTextField's setBordered:true
	strOneTextField's setPlaceholderString:("X数値のみ")
	strOneTextField's setDelegate:(me)
	
	set strTwoLabel to refMe's NSTextField's labelWithString:("Y size:")
	strTwoLabel's setFrame:(refMe's NSMakeRect(20, 55, 70, 20))
	
	set my strTwoTextField to refMe's NSTextField's textFieldWithString:("")
	strTwoTextField's setFrame:(refMe's NSMakeRect(87, 55, 245, 20))
	strTwoTextField's setEditable:true
	strTwoTextField's setBordered:true
	strTwoTextField's setPlaceholderString:("Y数値のみ")
	
	set my appCancelButton to refMe's NSButton's buttonWithTitle:"Cancel" target:me action:"doButtonAction:"
	appCancelButton's setFrameSize:{94, 32}
	appCancelButton's setFrameOrigin:{150, 10}
	appCancelButton's setKeyEquivalent:(character id 27)
	
	set my appOkButton to refMe's NSButton's buttonWithTitle:"OK" target:me action:"doButtonAction:"
	appOkButton's setFrameSize:{94, 32}
	appOkButton's setFrameOrigin:{245, 10}
	appOkButton's setKeyEquivalent:return
	appOkButton's setEnabled:false
	
	set ocidWindowSize to refMe's NSMakeRect(0, 0, 355, 125)
	set ocidWinStyle to (refMe's NSWindowStyleMaskTitled as integer) + (refMe's NSWindowStyleMaskClosable as integer)
	set my appDialogWindow to refMe's NSWindow's alloc()'s initWithContentRect:(ocidWindowSize) styleMask:(ocidWinStyle) backing:(refMe's NSBackingStoreBuffered) defer:true
	
	appDialogWindow's contentView()'s addSubview:(strOneLabel)
	appDialogWindow's contentView()'s addSubview:(strOneTextField)
	appDialogWindow's contentView()'s addSubview:(strTwoLabel)
	appDialogWindow's contentView()'s addSubview:(strTwoTextField)
	appDialogWindow's contentView()'s addSubview:(appCancelButton)
	appDialogWindow's contentView()'s addSubview:(appOkButton)
	
	appDialogWindow's setTitle:"比率換算"
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
		set my appOkClicked to true
	end if
	my appDialogWindow's |close|()
end doButtonAction:

on controlTextDidChange:(objNotification)
	set sender to objNotification's object()
	if sender is my strOneTextField then
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
