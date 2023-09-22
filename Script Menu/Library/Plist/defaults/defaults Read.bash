#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#################################################
##ドメイン一覧
/usr/bin/defaults domains
##アプリケーション名指定（Applicationフォルダにないとダメ？）
/usr/bin/defaults read -app "Font Book" >"$HOME/Desktop/com.apple.some.json"
/usr/bin/plutil -convert xml1 "$HOME/Desktop/com.apple.some.json" -o "$HOME/Desktop/com.apple.some.plist"
##バンドルID指定
/usr/bin/defaults read com.apple.archiveutility >"$HOME/Desktop/com.apple.some.json"
/usr/bin/plutil -convert xml1 "$HOME/Desktop/com.apple.some.json" -o "$HOME/Desktop/com.apple.some.plist"
##パス指定
/usr/bin/defaults read "$HOME/Library/Application Support/com.apple.NewDeviceOutreach/Warranty.plist" >"$HOME/Desktop/com.apple.some.json"
/usr/bin/plutil -convert xml1 "$HOME/Desktop/com.apple.some.json" -o "$HOME/Desktop/com.apple.some.plist"
##GlobalPreferences
/usr/bin/defaults read -g >"$HOME/Desktop/com.apple.some.json"
/usr/bin/defaults read -globalDomain >"$HOME/Desktop/com.apple.some.json"
/usr/bin/defaults read NSGlobalDomain >"$HOME/Desktop/com.apple.some.json"
/usr/bin/plutil -convert xml1 "$HOME/Desktop/com.apple.some.json" -o "$HOME/Desktop/com.apple.some.plist"
##要素(Key)を指定して値（value）を取得
/usr/bin/defaults read NSGlobalDomain AppleLanguages
/usr/bin/defaults read NSGlobalDomain KB_SpellingLanguage
/usr/bin/defaults read -g AppleTemperatureUnit
/usr/bin/defaults read -g userMenuExtraStyle
/usr/bin/defaults read -globalDomain AppleSpacesSwitchOnActivate
/usr/bin/defaults read -globalDomain com.apple.springing.delay
##TYPE 値の種類を取得する
/usr/bin/defaults read-type NSGlobalDomain AppleLanguages
/usr/bin/defaults read-type NSGlobalDomain KB_SpellingLanguage
/usr/bin/defaults read-type -g AppleTemperatureUnit
/usr/bin/defaults read-type -g userMenuExtraStyle
/usr/bin/defaults read-type -g AppleSpacesSwitchOnActivate
/usr/bin/defaults read-type "$HOME/Library/Preferences/.GlobalPreferences.plist" com.apple.springing.delay
/usr/bin/defaults read-type "$HOME/Library/Preferences/.GlobalPreferences" AKLastEmailListRequestDateKey
#####Containers Preferences内は拡張子なしでも参照できる
/usr/bin/defaults read "$HOME/Library/Containers/com.apple.archiveutility/Data/Library/Preferences/com.apple.archiveutility.plist" "NSWindow Frame Progress Panel"
/usr/bin/defaults read "$HOME/Library/Containers/com.apple.archiveutility/Data/Library/Preferences/com.apple.archiveutility" "NSWindow Frame Progress Panel"
/usr/bin/defaults read "$HOME/Library/Preferences/com.apple.archiveutility.plist" archive-format
/usr/bin/defaults read "$HOME/Library/Preferences/com.apple.archiveutility" archive-format
####バンドルID指定する場合はContainersを先に参照するので以下のコマンドはエラーになる
/usr/bin/defaults read com.apple.archiveutility archive-format
################
## host 名指定
STR_HOSTNAME=$("/bin/hostname")
/usr/bin/defaults -host "$STR_HOSTNAME" read -globalDomain >"$HOME/Desktop/com.apple.some.json"
/usr/bin/plutil -convert xml1 "$HOME/Desktop/com.apple.some.json" -o "$HOME/Desktop/com.apple.some.plist"
################
## ByHost 対象のデバイス専用の設定　ByHost内にデバイスUUIDを付与されて保存されている
/usr/bin/defaults -currentHost read com.apple.dock >"$HOME/Desktop/com.apple.some.json"
/usr/bin/plutil -convert xml1 "$HOME/Desktop/com.apple.some.json" -o "$HOME/Desktop/com.apple.some.plist"
#デバイスUUIDは
STR_DEVICE_UUID=$(/usr/sbin/ioreg -c IOPlatformExpertDevice | grep IOPlatformUUID | awk -F'"' '{print $4}')
/bin/echo "デバイスUUID: " "$STR_DEVICE_UUID"
#だから 要はこのファイルを読んでいる
/bin/echo "com.apple.dock.$STR_DEVICE_UUID.plist"
#Read時にパス指定するならUUIDは不要
/usr/bin/defaults read "$HOME/Library/Preferences/ByHost/com.apple.dock" >"$HOME/Desktop/com.apple.some.json"
/usr/bin/plutil -convert xml1 "$HOME/Desktop/com.apple.some.json" -o "$HOME/Desktop/com.apple.some.plist"

exit 0
