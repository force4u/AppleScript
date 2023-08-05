#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#ユーザードメインにインストール
########################################
##OS
PLIST_PATH="/System/Library/CoreServices/SystemVersion.plist"
STR_OS_VER=$(/usr/bin/defaults read "$PLIST_PATH" ProductVersion)
/bin/echo "OS VERSION ：" "$STR_OS_VER"
STR_MAJOR_VERSION="${STR_OS_VER%%.*}"
/bin/echo "STR_MAJOR_VERSION ：" "$STR_MAJOR_VERSION"
STR_MINOR_VERSION="${STR_OS_VER#*.}"
/bin/echo "STR_MINOR_VERSION ：" "$STR_MINOR_VERSION"
#	STR_MAJOR_VERSION=$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d '.' -f 1,1)
#	STR_MINOR_VERSION=$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d '.' -f 2,2)

########################################
##ユーザー
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"
CURRENT_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
/bin/echo "実行中ユーザー：" "$CURRENT_USER"

########################################
## 処理
/usr/bin/killall TextEdit
/bin/echo "Done KillAll"

/bin/mkdir -p "/Users/$USER_WHOAMI/Library/Scripts/Applications/TextEdit"
/bin/echo "Done mkdir"

/usr/bin/defaults read com.apple.TextEdit UseInlineCSS
/usr/bin/defaults read com.apple.TextEdit UseEmbeddedCSS
/usr/bin/defaults read com.apple.TextEdit IgnoreHTML
/usr/bin/defaults read com.apple.TextEdit NSFixedPitchFont
/usr/bin/defaults read com.apple.TextEdit NSFixedPitchFontSize
/usr/bin/defaults read com.apple.TextEdit NSFont
/usr/bin/defaults read com.apple.TextEdit NSFontSize
/usr/bin/defaults read com.apple.TextEdit IgnoreRichTex
/usr/bin/defaults read com.apple.TextEdit AddExtensionToNewPlainTextFiles
/usr/bin/defaults read com.apple.TextEdit ShowRuler
/bin/echo "Done 設定前"

/usr/bin/defaults write com.apple.TextEdit UseInlineCSS -boolean TRUE
/usr/bin/defaults write com.apple.TextEdit UseEmbeddedCSS -boolean FALSE
/usr/bin/defaults write com.apple.TextEdit IgnoreHTML -boolean FALSE
/usr/bin/defaults write com.apple.TextEdit NSFixedPitchFont -string "Osaka-Mono"
/usr/bin/defaults write com.apple.TextEdit NSFixedPitchFontSize -string "16"
/usr/bin/defaults write com.apple.TextEdit NSFont -string "Osaka-Mono"
/usr/bin/defaults write com.apple.TextEdit NSFontSize -string "16"
/usr/bin/defaults write com.apple.TextEdit IgnoreRichTex -boolean FALSE
/usr/bin/defaults write com.apple.TextEdit AddExtensionToNewPlainTextFiles -boolean TRUE
/usr/bin/defaults write com.apple.TextEdit ShowRuler -boolean TRUE

/usr/bin/defaults write "/Users/$USER_WHOAMI/Library/com.apple.TextEdit.plist" UseInlineCSS -boolean TRUE
/usr/bin/defaults write "/Users/$USER_WHOAMI/Library/com.apple.TextEdit.plist" UseEmbeddedCSS -boolean FALSE
/usr/bin/defaults write "/Users/$USER_WHOAMI/Library/com.apple.TextEdit.plist" IgnoreHTML -boolean FALSE
/usr/bin/defaults write "/Users/$USER_WHOAMI/Library/com.apple.TextEdit.plist" NSFixedPitchFont -string "Osaka-Mono"
/usr/bin/defaults write "/Users/$USER_WHOAMI/Library/com.apple.TextEdit.plist" NSFixedPitchFontSize -string "16"
/usr/bin/defaults write "/Users/$USER_WHOAMI/Library/com.apple.TextEdit.plist" NSFont -string "Osaka-Mono"
/usr/bin/defaults write "/Users/$USER_WHOAMI/Library/com.apple.TextEdit.plist" NSFontSize -string "16"
/usr/bin/defaults write "/Users/$USER_WHOAMI/Library/com.apple.TextEdit.plist" IgnoreRichTex -boolean FALSE
/usr/bin/defaults write "/Users/$USER_WHOAMI/Library/com.apple.TextEdit.plist" AddExtensionToNewPlainTextFiles -boolean TRUE
/usr/bin/defaults write "/Users/$USER_WHOAMI/Library/com.apple.TextEdit.plist" ShowRuler -boolean TRUE

/bin/echo "Done 設定"

/usr/bin/defaults read com.apple.TextEdit UseInlineCSS
/usr/bin/defaults read com.apple.TextEdit UseEmbeddedCSS
/usr/bin/defaults read com.apple.TextEdit IgnoreHTML
/usr/bin/defaults read com.apple.TextEdit NSFixedPitchFont
/usr/bin/defaults read com.apple.TextEdit NSFixedPitchFontSize
/usr/bin/defaults read com.apple.TextEdit NSFont
/usr/bin/defaults read com.apple.TextEdit NSFontSize
/usr/bin/defaults read com.apple.TextEdit IgnoreRichTex
/usr/bin/defaults read com.apple.TextEdit AddExtensionToNewPlainTextFiles
/usr/bin/defaults read com.apple.TextEdit ShowRuler
/bin/echo "Done 設定後"

exit 0
