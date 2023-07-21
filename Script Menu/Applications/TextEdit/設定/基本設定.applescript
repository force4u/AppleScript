#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


do shell script "/usr/bin/defaults write com.apple.TextEdit UseInlineCSS -boolean TRUE"
do shell script "/usr/bin/defaults write com.apple.TextEdit UseEmbeddedCSS -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit IgnoreHTML -boolean FALSE"

do shell script "/usr/bin/defaults write com.apple.TextEdit NSFixedPitchFont -string \"Osaka-Mono\""
do shell script "/usr/bin/defaults write com.apple.TextEdit NSFixedPitchFontSize -string \"16\""

do shell script "/usr/bin/defaults write com.apple.TextEdit NSFont -string \"Osaka-Mono\""
do shell script "/usr/bin/defaults write com.apple.TextEdit NSFontSize -string \"16\""


do shell script "/usr/bin/defaults write com.apple.TextEdit IgnoreRichTex -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit AddExtensionToNewPlainTextFiles -boolean TRUE"
do shell script "/usr/bin/defaults write com.apple.TextEdit ShowRuler -boolean TRUE"


do shell script "/usr/bin/defaults write com.apple.TextEdit SDataDetectors -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit PreserveWhitespace -boolean FALSE"

do shell script "/usr/bin/defaults write com.apple.TextEdit SmartSubstitutionsEnabledInRichTextOnly -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit SmartQuotes -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit SmartCopyPaste -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit SmartDashes -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit SSmartLinks -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit NSAutomaticPeriodSubstitutionEnabled -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit NSAutomaticTextCompletionEnabled -boolean FALSE"

do shell script "/usr/bin/defaults write com.apple.TextEdit CheckSpellingAsYouTypeEnabledInRichTextOnly -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit NSNavLastUserSetHideExtensionButtonState -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit NSDocumentSuppressTempVersionStoreWarning -boolean FALSE"

do shell script "/usr/bin/defaults write com.apple.TextEdit NSAutomaticDashSubstitutionEnabled -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit NSAutomaticCapitalizationEnabled -boolean FALSE"

do shell script "/usr/bin/defaults write com.apple.TextEdit SCheckGrammarWithSpelling -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit CorrectSpellingAutomatically -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit CheckSpellingWhileTyping -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit NSAutomaticSpellingCorrectionEnabled -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit NSAutomaticTextCompletionCollapsed -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit NSAutomaticQuoteSubstitutionEnabled -boolean FALSE"

do shell script "/usr/bin/defaults write com.apple.TextEdit NSNavPanelExpandedStateForSaveMode -boolean TRUE"
do shell script "/usr/bin/defaults write com.apple.TextEdit NSNavLastUserSetHideExtensionButtonState -boolean FALSE"
do shell script "/usr/bin/defaults write com.apple.TextEdit TextReplacement -boolean TRUE"


do shell script "/usr/bin/defaults write com.apple.TextEdit PlainTextEncoding -integer 4"
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

#####CFPreferencesを再起動
set strCommandText to "/usr/bin/killall cfprefsd" as text
do shell script strCommandText

