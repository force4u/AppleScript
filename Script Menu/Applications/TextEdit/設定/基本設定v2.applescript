#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application


set ocidFalse to (refMe's NSNumber's numberWithBool:false)
set ocidTrue to (refMe's NSNumber's numberWithBool:true)


tell application id "com.apple.TextEdit" to quit

delay 3

##########################################
###【１】ドキュメントのパス
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
##
set ocidPlistFilePathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Containers/com.apple.TextEdit/Data/Library/Preferences/com.apple.TextEdit.plist")
##########################################
### 【２】PLISTを可変レコードとして読み込み
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL)
##########################################
### 【３】処理
(ocidPlistDict's setValue:(ocidTrue) forKey:("UseInlineCSS"))
(ocidPlistDict's setValue:(ocidTrue) forKey:("AddExtensionToNewPlainTextFiles"))
(ocidPlistDict's setValue:(ocidTrue) forKey:("NSNavPanelExpandedStateForSaveMode"))
(ocidPlistDict's setValue:(ocidTrue) forKey:("TextReplacement"))

(ocidPlistDict's setValue:(ocidFalse) forKey:("UseEmbeddedCSS"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("IgnoreHTML"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("IgnoreRichTex"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("SDataDetectors"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("PreserveWhitespace"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("NSNavLastUserSetHideExtensionButtonState"))

(ocidPlistDict's setValue:(ocidFalse) forKey:("SmartSubstitutionsEnabledInRichTextOnly"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("SmartQuotes"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("SmartCopyPaste"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("SmartDashes"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("SSmartLinks"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("NSAutomaticPeriodSubstitutionEnabled"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("NSAutomaticTextCompletionEnabled"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("CheckSpellingAsYouTypeEnabledInRichTextOnly"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("NSNavLastUserSetHideExtensionButtonState"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("NSDocumentSuppressTempVersionStoreWarning"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("NSAutomaticDashSubstitutionEnabled"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("NSAutomaticCapitalizationEnabled"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("SCheckGrammarWithSpelling"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("CorrectSpellingAutomatically"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("CheckSpellingWhileTyping"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("NSAutomaticSpellingCorrectionEnabled"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("NSAutomaticTextCompletionCollapsed"))
(ocidPlistDict's setValue:(ocidFalse) forKey:("NSAutomaticQuoteSubstitutionEnabled"))

(ocidPlistDict's setValue:("Osaka-Mono") forKey:("NSFixedPitchFont"))
(ocidPlistDict's setValue:("16") forKey:("NSFixedPitchFontSize"))
(ocidPlistDict's setValue:("Osaka-Mono") forKey:("NSFont"))
(ocidPlistDict's setValue:("16") forKey:("NSFontSize"))

(ocidPlistDict's setValue:(4) forKey:("PlainTextEncoding"))
(*
NSASCIIStringEncoding	1
NSNEXTSTEPStringEncoding	2
NSJapaneseEUCStringEncoding	3
NSUTF8StringEncoding	4
NSISOLatin1StringEncoding	5
NSSymbolStringEncoding	6
NSNonLossyASCIIStringEncoding	7
NSShiftJISStringEncoding	8
NSISOLatin2StringEncoding	9
NSUnicodeStringEncoding	10
NSWindowsCP1251StringEncoding	11
NSWindowsCP1252StringEncoding	12
NSWindowsCP1253StringEncoding	13
NSWindowsCP1254StringEncoding	14
NSWindowsCP1250StringEncoding	15
NSISO2022JPStringEncoding	21
NSMacOSRomanStringEncoding	30
NSUTF16StringEncoding	10
NSUTF16BigEndianStringEncoding	2415919360
NSUTF16LittleEndianStringEncoding	2483028224
NSUTF32StringEncoding	2348810496
NSUTF32BigEndianStringEncoding	2550137088
NSUTF32LittleEndianStringEncoding	2617245952
NSProprietaryStringEncoding	65536
*)


##########################################
####【４】保存 ここは上書き
set boolDone to ocidPlistDict's writeToURL:(ocidPlistFilePathURL) atomically:true
log boolDone
if boolDone = true then
	return "正常終了"
	#####CFPreferencesを再起動
	set strCommandText to "/usr/bin/killall cfprefsd" as text
	do shell script strCommandText
else
	return "保存に失敗しました"
end if




return





