#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#ユーザード ~/binにインストールする

########################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行ユーザーは：$USER_WHOAMI"
###実行しているユーザー名
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
/bin/echo "コンソールユーザー：$CONSOLE_USER"
###ログイン名ユーザー名※Visual Studio Codeの出力パネルではrootになる設定がある
LOGIN_NAME=$(/usr/bin/logname)
/bin/echo "ログイン名：$LOGIN_NAME"
###UID
USER_NAME=$(/usr/bin/id -un)
/bin/echo "ユーザー名:$USER_NAME"
###SUDOUSER
/bin/echo "SUDO_USER: $SUDO_USER"
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
###ダウンロード起動時に削除する項目
USER_TEMP_DIR=$(/usr/bin/mktemp -d)
/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"
########################################
##デバイス
#起動ディスクの名前を取得する
/bin/mkdir -p "/Users/$CONSOLE_USER/Documents/Apple/IOPlatformUUID"
/usr/bin/touch "/Users/$CONSOLE_USER/Documents/Apple/IOPlatformUUID/diskutil.plist"
/usr/sbin/chown -R "$CONSOLE_USER" "/Users/$CONSOLE_USER/Documents/Apple/IOPlatformUUID"
/bin/chmod -R 700 "/Users/$CONSOLE_USER/Documents/Apple"
/usr/sbin/diskutil info -plist / >"/Users/$CONSOLE_USER/Documents/Apple/IOPlatformUUID/diskutil.plist"
STARTUPDISK_NAME=$(/usr/bin/defaults read "/Users/$CONSOLE_USER/Documents/Apple/IOPlatformUUID/diskutil.plist" VolumeName)
/bin/echo "ボリューム名：" "$STARTUPDISK_NAME"
############################################################
##基本メンテナンス
##ライブラリの不可視属性を解除
/usr/bin/chflags nohidden "/Users/$CONSOLE_USER/Library"
/usr/bin/SetFile -a v "/Users/$CONSOLE_USER/Library"

##　Managed Itemsフォルダを作る
/bin/mkdir -p "/Users/$CONSOLE_USER/Library/Managed Items"
/usr/bin/touch "/Users/$CONSOLE_USER/Library/Managed Items/.localized"
/usr/sbin/chown "$CONSOLE_USER" "/Users/$CONSOLE_USER/Library/Managed Items"
/bin/chmod 755 "/Users/$CONSOLE_USER/Library/Managed Items"

########################################
##ユーザーアプリケーションフォルダを作る
STR_USER_APP_DIR="/Users/$CONSOLE_USER/Applications"
/bin/mkdir -p "$STR_USER_APP_DIR"
/usr/bin/touch "$STR_USER_APP_DIR/.localized"
/usr/sbin/chown "$CONSOLE_USER" "$STR_USER_APP_DIR"
/bin/chmod 700 "$STR_USER_APP_DIR"

########################################
##ユーザーアプリケーション　サブフォルダを作る Applications
LIST_SUB_DIR_NAME=("Demos" "Desktop" "Developer" "Documents" "Downloads" "Favorites" "Groups" "Library" "Movies" "Music" "Pictures" "Public" "Shared" "Sites" "System" "Users" "Utilities")
STR_USER_APP_DIR="/Users/$CONSOLE_USER/Applications"
for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
	/bin/mkdir -p "$STR_USER_APP_DIR/${ITEM_DIR_NAME}"
	/usr/bin/touch "$STR_USER_APP_DIR/${ITEM_DIR_NAME}/.localized"
	/usr/sbin/chown "$CONSOLE_USER" "$STR_USER_APP_DIR/${ITEM_DIR_NAME}"
	/bin/chmod 755 "$STR_USER_APP_DIR/${ITEM_DIR_NAME}"
done

########################################
###アクアセス権　修正
STR_USER_DIR="/Users/$CONSOLE_USER"
LIST_SUB_DIR_NAME=("Desktop" "Developer" "Documents" "Downloads" "Groups" "Library" "Movies" "Music" "Pictures" "jpki" "bin" "Creative Cloud Files")
###LIST_SUB_DIR_NAMEリストの数だけ繰り返し
for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
	/bin/chmod 700 "$STR_USER_DIR/${ITEM_DIR_NAME}"
	/usr/sbin/chown "$CONSOLE_USER" "$STR_USER_DIR/${ITEM_DIR_NAME}"
done
/bin/chmod 755 "$STR_USER_DIR/Public"
/bin/chmod 755 "$STR_USER_DIR/Sites"
/bin/chmod 777 "$STR_USER_DIR/Library/Caches"

########################################
##サブフォルダを作る Public
LIST_SUB_DIR_NAME=("Documents" "Groups" "Shared Items" "Shared" "Favorites" "Drop Box")
STR_USER_PUB_DIR="/Users/$CONSOLE_USER/Public"
for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
	/bin/mkdir -p "$STR_USER_PUB_DIR/${ITEM_DIR_NAME}"
	/usr/bin/touch "$STR_USER_PUB_DIR/${ITEM_DIR_NAME}/.localized"
	/usr/sbin/chown "$CONSOLE_USER" "$STR_USER_PUB_DIR/${ITEM_DIR_NAME}"
	/bin/chmod 755 "$STR_USER_PUB_DIR/${ITEM_DIR_NAME}"
done
/bin/chmod 755 "$STR_USER_PUB_DIR/Documents"
/bin/chmod 770 "$STR_USER_PUB_DIR/Groups"
/bin/chmod 775 "$STR_USER_PUB_DIR/Shared Items"
/bin/chmod 777 "$STR_USER_PUB_DIR/Shared"
/bin/chmod 750 "$STR_USER_PUB_DIR/Favorites"
/bin/chmod 733 "$STR_USER_PUB_DIR/Drop Box"

########################################
##シンボリックリンクを作る
if [[ ! -e "/Users/$CONSOLE_USER/Applications/Applications" ]]; then
	/bin/ln -s "/Applications" "/Users/$CONSOLE_USER/Applications/Applications"
fi
if [[ ! -e "/Users/$CONSOLE_USER//Applications/Utilities/Finder Applications" ]]; then
	/bin/ln -s "/System/Library/CoreServices/Finder.app/Contents/Applications" "/Users/$CONSOLE_USER/Applications/Utilities/Finder Applications"
fi
if [[ ! -e "/Users/$CONSOLE_USER/Applications/Utilities/Finder Libraries" ]]; then
	/bin/ln -s "/System/Library/CoreServices/Finder.app/Contents/Resources/MyLibraries" "/Users/$CONSOLE_USER/Applications/Utilities/Finder Libraries"
fi
if [[ ! -e "/Users/$CONSOLE_USER/Applications/Utilities/System Applications" ]]; then
	/bin/ln -s "/System/Library/CoreServices/Applications" "/Users/$CONSOLE_USER/Applications/Utilities/System Applications"
fi
if [[ ! -e "/Users/$CONSOLE_USER/Applications/Utilities/System Utilities" ]]; then
	/bin/ln -s "/Applications/Utilities" "/Users/$CONSOLE_USER/Applications/Utilities/System Utilities"
fi
if [[ ! -e "/Users/$CONSOLE_USER/Library/Managed Items/My Applications" ]]; then
	/bin/ln -s "/Users/$CONSOLE_USER/Applications" "/Users/$CONSOLE_USER/Library/Managed Items/My Applications"
fi

############################################################
############################################################
###BIN
/bin/mkdir -p "/Users/$CONSOLE_USER/bin/"
for ((numTimes = 1; numTimes <= 3; numTimes++)); do
	sleep 1
	/bin/mkdir -p "/Users/$CONSOLE_USER/bin/"
	/usr/bin/touch "/Users/$CONSOLE_USER/bin/"
	/usr/sbin/chown "$CONSOLE_USER" "/Users/$CONSOLE_USER/bin/"
	/bin/chmod 700 "/Users/$CONSOLE_USER/bin/"
done

###ダウンロードURL
STR_URL="https://www.7-zip.org/a/7z2301-mac.tar.xz"
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
/bin/mkdir -p "$USER_TEMP_DIR/7zip/"
############################################################
######### インストール
/bin/echo "インストール開始:" "$CONSOLE_USER"
####解凍
/usr/bin/bsdtar -xzf "$USER_TEMP_DIR/$DL_FILE_NAME" -C "$USER_TEMP_DIR/7zip"
sleep 2

####移動
/usr/bin/ditto "$USER_TEMP_DIR/7zip" "/Users/$CONSOLE_USER/bin/7zip"
####終了
/bin/echo "インストール終了:" "$CONSOLE_USER"
exit 0
