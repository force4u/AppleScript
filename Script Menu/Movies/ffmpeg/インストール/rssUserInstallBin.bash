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
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/Documents/Apple/IOPlatformUUID"
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
/usr/bin/chflags nohidden "/Users/$CONSOLE_USER/Library"
/usr/bin/SetFile -a v "/Users/$CONSOLE_USER/Library"
##　Managed Itemsフォルダを作る
/bin/mkdir -p "/Users/$CONSOLE_USER/Library/Managed Items"
/bin/chmod 755 "/Users/$CONSOLE_USER/Library/Managed Items"
/usr/sbin/chown "$CONSOLE_USER" "/Users/$CONSOLE_USER/Library/Managed Items"
/usr/bin/touch "/Users/$CONSOLE_USER/Library/Managed Items/.localized"

########################################
##　HOME
########################################
##	Developer
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/Developer"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
##	bin
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/bin"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
##	Sites
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/Sites"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 755 "$STR_CHECK_DIR_PATH"

##アクセス権チェック
/bin/chmod 700 "/Users/$CONSOLE_USER/Library"
/bin/chmod 700 "/Users/$CONSOLE_USER/Movies"
/bin/chmod 700 /"Users/$CONSOLE_USER/Music"
/bin/chmod 700 "/Users/$CONSOLE_USER/Pictures"
/bin/chmod 700 "/Users/$CONSOLE_USER/Downloads"
/bin/chmod 700 "/Users/$CONSOLE_USER/Documents"
/bin/chmod 700 "/Users/$CONSOLE_USER/Desktop"
##全ローカルユーザーに対して実施したい処理があれば追加する
/bin/echo "ユーザーディレクトリチェックDONE"
########################################
##	Public
########################################
/bin/chmod 755 "/Users/$CONSOLE_USER/Public"
##
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/Public/Drop Box"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 733 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"
##########
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/Public/Documents"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
##
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/Public/Downloads"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
##
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/Public/Favorites"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 700 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
##########
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/Public/Groups"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 770 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf staff "$STR_CHECK_DIR_PATH"
##
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/Public/Shared"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 750 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf staff "$STR_CHECK_DIR_PATH"
##########
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/Public/Guest"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 777 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"
##
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/Public/Shared Items"
/bin/mkdir -p "$STR_CHECK_DIR_PATH"
/bin/chmod 775 "$STR_CHECK_DIR_PATH"
/usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"

########################################
##	Applications
########################################
##	Applications
STR_CHECK_DIR_PATH="/Users/$CONSOLE_USER/Applications"
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
if [[ ! -e "/Users/$CONSOLE_USER/Applications/Applications" ]]; then
	/bin/ln -s "/Applications" "/Users/$CONSOLE_USER/Applications/Applications"
fi
if [[ ! -e "/Users/$CONSOLE_USER/Applications/Utilities/Finder Applications" ]]; then
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

#################################
## RSSから最新のバージョンを取得する
STR_RSS_URL="https://evermeet.cx/ffmpeg/rss.xml"
XML_RSS_DATA=$(/usr/bin/curl -s "$STR_RSS_URL" | xmllint --format -)
STR_LINK_LINE=$(/bin/echo "$XML_RSS_DATA" | xmllint --xpath "//item/link/text()" -)
IFS=$'\n' read -r -d '' -a LIST_LINK_LINE <<<"$STR_LINK_LINE"

for ITEM_LINK_LINE in "${LIST_LINK_LINE[@]}"; do
  if [[ $ITEM_LINK_LINE == *"ffmpeg-6"* ]]; then
  /bin/echo "$ITEM_LINK_LINE"
	STR_URL="$ITEM_LINK_LINE"
 #  read -ra ARRAY_TITLE <<<"$ITEM_TITLE"
 #  STR_VERSION=${ARRAY_TITLE[2]}
 #  /bin/echo "$STR_VERSION"
    break
  fi
done

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
/bin/mkdir -p "$USER_TEMP_DIR/ffmpeg/"
############################################################
######### インストール
/bin/echo "インストール開始:" "$CONSOLE_USER"
####解凍
/usr/bin/bsdtar -xzf "$USER_TEMP_DIR/$DL_FILE_NAME" -C "$USER_TEMP_DIR/ffmpeg"
sleep 2
####移動
/usr/bin/ditto "$USER_TEMP_DIR/ffmpeg" "/Users/$CONSOLE_USER/bin/ffmpeg"
####終了
/bin/echo "インストール終了:" "$CONSOLE_USER"
exit 0
