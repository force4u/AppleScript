#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#ユーザードメインにインストール

########################################
##実行パス
SCRIPT_PATH="${BASH_SOURCE[0]}"
/bin/echo "実行中のスクリプト"
/bin/echo "\"$SCRIPT_PATH\""
########################################
##OS
PLIST_PATH="/System/Library/CoreServices/SystemVersion.plist"
STR_OS_VER=$(/usr/bin/defaults read "$PLIST_PATH" ProductVersion)
/bin/echo "OS VERSION ：" "$STR_OS_VER"
STR_MAJOR_VERSION="${STR_OS_VER%%.*}"
/bin/echo "STR_MAJOR_VERSION ：" "$STR_MAJOR_VERSION"
STR_MINOR_VERSION="${STR_OS_VER#*.}"
/bin/echo "STR_MINOR_VERSION ：" "$STR_MINOR_VERSION"

########################################
##ユーザー
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"
CURRENT_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
/bin/echo "実行ユーザー：" "$CURRENT_USER"

########################################
##デバイス
#起動ディスクの名前を取得する
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Documents/Apple/IOPlatformUUID"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/com.apple.diskutil.plist"
/usr/sbin/diskutil info -plist / >"$STR_CHECK_DIR_PATH/com.apple.diskutil.plist"
STARTUPDISK_NAME=$(/usr/bin/defaults read "$STR_CHECK_DIR_PATH/com.apple.diskutil.plist" VolumeName)
/bin/echo "ボリューム名：" "$STARTUPDISK_NAME"
#デバイスUUID
/usr/bin/touch "$STR_CHECK_DIR_PATH/com.apple.ioreg.plist"
/usr/sbin/ioreg -c IOPlatformExpertDevice -a > "$STR_CHECK_DIR_PATH/com.apple.ioreg.plist"
STR_DEVICE_UUID=$(/usr/sbin/ioreg -c IOPlatformExpertDevice | grep IOPlatformUUID | awk -F'"' '{print $4}')
/bin/echo "デバイスUUID: " "$STR_DEVICE_UUID"

############################################################
##基本メンテナンス
##ライブラリの不可視属性を解除
/usr/bin/chflags nohidden "/Users/$CURRENT_USER/Library"
/usr/bin/SetFile -a v "/Users/$CURRENT_USER/Library"
##　Managed Itemsフォルダを作る
/bin/mkdir -p "/Users/$CURRENT_USER/Library/Managed Items"
/bin/chmod 755 "/Users/$CURRENT_USER/Library/Managed Items"
/usr/sbin/chown "$CURRENT_USER" "/Users/$CURRENT_USER/Library/Managed Items"
/usr/bin/touch "/Users/$CURRENT_USER/Library/Managed Items/.localized"

########################################
##　HOME
########################################
##	Developer
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Developer"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
##	bin
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/bin"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
##アクセス権チェック
/bin/chmod 700 "/Users/$CURRENT_USER/Library"
/bin/chmod 700 "/Users/$CURRENT_USER/Movies"
/bin/chmod 700 /"Users/$CURRENT_USER/Music"
/bin/chmod 700 "/Users/$CURRENT_USER/Pictures"
/bin/chmod 700 "/Users/$CURRENT_USER/Downloads"
/bin/chmod 700 "/Users/$CURRENT_USER/Documents"
/bin/chmod 700 "/Users/$CURRENT_USER/Desktop"
##全ローカルユーザーに対して実施したい処理があれば追加する
/bin/echo "ユーザーディレクトリチェックDONE"
########################################
##	Public
########################################
/bin/chmod 755 "/Users/$CURRENT_USER/Public"
##
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Drop Box"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 733 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"
##########
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Documents"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
##
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Downloads"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
##
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Favorites"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
##########
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Groups"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 770 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf staff "$STR_CHECK_DIR_PATH"
##
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Shared"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 750 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf staff "$STR_CHECK_DIR_PATH"
##########
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Guest"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 777 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"
##
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Public/Shared Items"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 775 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"

########################################
##	Applications
########################################
##	Applications
STR_CHECK_DIR_PATH="/Users/$CURRENT_USER/Applications"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
##サブフォルダを作る
LIST_SUB_DIR_NAME=("Demos" "Desktop" "Developer" "Documents" "Downloads" "Favorites" "Groups" "Library" "Movies" "Music" "Pictures" "Public" "Shared" "Sites" "System" "Users" "Utilities")
##リストの数だけ処理
for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
	/bin/mkdir -p "$STR_CHECK_DIR_PATH/${ITEM_DIR_NAME}"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH/${ITEM_DIR_NAME}"
	/usr/bin/touch "$STR_CHECK_DIR_PATH/${ITEM_DIR_NAME}/.localized"
done
########################################
##シンボリックリンクを作る
if [[ ! -e "/Users/$CURRENT_USER/Applications/Applications" ]]; then
	/bin/ln -s "/Applications" "/Users/$CURRENT_USER/Applications/Applications"
fi
if [[ ! -e "/Users/$CURRENT_USER/Applications/Utilities/Finder Applications" ]]; then
	/bin/ln -s "/System/Library/CoreServices/Finder.app/Contents/Applications" "/Users/$CURRENT_USER/Applications/Utilities/Finder Applications"
fi
if [[ ! -e "/Users/$CURRENT_USER/Applications/Utilities/Finder Libraries" ]]; then
	/bin/ln -s "/System/Library/CoreServices/Finder.app/Contents/Resources/MyLibraries" "/Users/$CURRENT_USER/Applications/Utilities/Finder Libraries"
fi
if [[ ! -e "/Users/$CURRENT_USER/Applications/Utilities/System Applications" ]]; then
	/bin/ln -s "/System/Library/CoreServices/Applications" "/Users/$CURRENT_USER/Applications/Utilities/System Applications"
fi
if [[ ! -e "/Users/$CURRENT_USER/Applications/Utilities/System Utilities" ]]; then
	/bin/ln -s "/Applications/Utilities" "/Users/$CURRENT_USER/Applications/Utilities/System Utilities"
fi

##全ローカルユーザーに対して実施したい処理があれば追加する
/bin/echo "通常メンテナンスDONE"

############################################################
############################################################
###BIN
/bin/mkdir -p "/Users/$CURRENT_USER/bin/"
for ((numTimes = 1; numTimes <= 3; numTimes++)); do
	sleep 1
	/bin/mkdir -p "/Users/$CURRENT_USER/bin/"
	/usr/bin/touch "/Users/$CURRENT_USER/bin/"
	/usr/sbin/chown "$CURRENT_USER" "/Users/$CURRENT_USER/bin/"
	/bin/chmod 700 "/Users/$CURRENT_USER/bin/"
done
########################################
###ダウンロード起動時に削除する項目
USER_TEMP_DIR=$(/usr/bin/mktemp -d)
/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"

###ダウンロードURL
STR_URL="https://registry.npmjs.org/imageoptim-cli/-/imageoptim-cli-3.1.7.tgz"
###ファイル名を取得
DL_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
/bin/echo "DL_FILE_NAME:$DL_FILE_NAME"
###ダウンロード
if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/$DL_FILE_NAME" "$STR_URL" --connect-timeout 20; then
	/bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
	if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/$DL_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20; then
		/bin/echo "ファイルのダウンロードに失敗しました"
		exit 1
	fi
fi
##全ユーザー実行可能にしておく
/bin/chmod 755 "$USER_TEMP_DIR/$DL_FILE_NAME"
/bin/echo "ダウンロードOK"
/bin/mkdir -p "$USER_TEMP_DIR/ImageOptim/"
############################################################
######### インストール
/bin/echo "インストール開始:" "$CURRENT_USER"
####解凍
##	/usr/bin/bsdtar -xzf "$USER_TEMP_DIR/$DL_FILE_NAME" -C "$USER_TEMP_DIR/7zip" --strip-components=1
/usr/bin/bsdtar -xzf "$USER_TEMP_DIR/$DL_FILE_NAME" -C "$USER_TEMP_DIR/ImageOptim"
sleep 2

####移動
/usr/bin/ditto "$USER_TEMP_DIR/ImageOptim/package/dist/imageoptim" "/Users/$CURRENT_USER/bin/ImageOptim/imageoptim"
####終了
/bin/echo "インストール終了:" "$CURRENT_USER"
exit 0
