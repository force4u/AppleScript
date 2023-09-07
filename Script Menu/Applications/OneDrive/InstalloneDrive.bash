#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe

########################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"
if [ "$USER_WHOAMI" != "root" ]; then
	/bin/echo "このスクリプトを実行するには管理者権限が必要です。"
	/bin/echo "sudo で実行してください"
	### path to me
	SCRIPT_PATH="${BASH_SOURCE[0]}"
	/bin/echo "/usr/bin/sudo \"$SCRIPT_PATH\""
	/bin/echo "↑を実行してください"
	exit 1
else
	###実行しているユーザー名
	CURRENT_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
	/bin/echo "実行ユーザー：" "$CURRENT_USER"
fi
###コンソールユーザー CONSOLE_USERはFinderでログインしていないと出ない
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
if [ -z "$CONSOLE_USER" ]; then
	/bin/echo "コンソールユーザーが無い=電源入れてログインウィンドウ状態"
else
	/bin/echo "コンソールユーザー：" "$CONSOLE_USER"
fi
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
###ローカルのユーザーアカウントを取得
TEXT_RESULT=$(/usr/bin/dscl localhost -list /Local/Default/Users PrimaryGroupID | /usr/bin/awk '$2 == 20 { print $1 }')
###リストにする
read -d '\\n' -r -a LIST_USER <<<"$TEXT_RESULT"
###リスト内の項目数
NUM_CNT=${#LIST_USER[@]}
/bin/echo "ユーザー数：" "$NUM_CNT"
########################################
STR_DEVICE_UUID=$(/usr/sbin/ioreg -c IOPlatformExpertDevice | grep IOPlatformUUID | awk -F'"' '{print $4}')
/bin/echo "デバイスUUID: " "$STR_DEVICE_UUID"
###各ユーザーの最終ログアウト日
for ITEM_LIST in "${LIST_USER[@]}"; do
	STR_CHECK_File_PATH="/Users/${ITEM_LIST}/Library/Preferences/ByHost/com.apple.loginwindow.$STR_DEVICE_UUID.plist"
	STR_LAST_LOGOUT=$(/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$STR_CHECK_File_PATH")
	/bin/echo "ユーザー$ITEM_LIST の最終ログアウト日: " "$STR_LAST_LOGOUT"
done
########################################
##デバイス
#起動ディスクの名前を取得する
for ITEM_LIST in "${LIST_USER[@]}"; do
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Documents/Apple/IOPlatformUUID/"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "/Users/${ITEM_LIST}/Documents/Apple/IOPlatformUUID/diskutil.plist"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/diskutil info -plist / >"/Users/${ITEM_LIST}/Documents/Apple/IOPlatformUUID/diskutil.plist"
	STARTUPDISK_NAME=$(/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/defaults read "/Users/${ITEM_LIST}/Documents/Apple/IOPlatformUUID/diskutil.plist" VolumeName)
done
/bin/echo "ボリューム名：" "$STARTUPDISK_NAME"
########################################
###ダウンロード起動時に削除する項目
for ITEM_LIST in "${LIST_USER[@]}"; do
	USER_TEMP_DIR=$(/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/mktemp -d)
	/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"
done
########################################
##基本メンテナンス
########################################
for ITEM_LIST in "${LIST_USER[@]}"; do
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 700 "/Users/${ITEM_LIST}/Library"
	##ライブラリの不可視属性を解除
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/chflags nohidden "/Users/${ITEM_LIST}/Library"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/SetFile -a v "/Users/${ITEM_LIST}/Library"
	##　Managed Itemsフォルダを作る
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Library/Managed Items"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 755 "/Users/${ITEM_LIST}/Library/Managed Items"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/chown "${ITEM_LIST}" "/Users/${ITEM_LIST}/Library/Managed Items"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "/Users/${ITEM_LIST}/Library/Managed Items/.localized"
	##
	/bin/chmod 777 "/Users/${ITEM_LIST}/Library/Caches"
	/bin/chmod 777 /Users/"${ITEM_LIST}"/Library/Caches/*
	##
	/bin/chmod -Rf 755 "/Users/${ITEM_LIST}/Library/Fonts"
	/usr/sbin/chown -Rf "${ITEM_LIST}" "/Users/${ITEM_LIST}/Library/Fonts"
	##
	/bin/echo "ライブラリチェックDONE：" "${ITEM_LIST}"
done
########################################
##　HOME
########################################
for ITEM_LIST in "${LIST_USER[@]}"; do
	##	Developer
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Developer"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo /usr/sbin/chown "${ITEM_LIST}" "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	##	bin
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/bin"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo /usr/sbin/chown "${ITEM_LIST}" "$STR_CHECK_DIR_PATH"
	##アクセス権チェック
	/bin/chmod 700 "/Users/${ITEM_LIST}/Movies"
	/bin/chmod 700 /"Users/${ITEM_LIST}/Music"
	/bin/chmod 700 "/Users/${ITEM_LIST}/Pictures"
	/bin/chmod 700 "/Users/${ITEM_LIST}/Downloads"
	/bin/chmod 700 "/Users/${ITEM_LIST}/Documents"
	/bin/chmod 700 "/Users/${ITEM_LIST}/Desktop"
	##全ローカルユーザーに対して実施したい処理があれば追加する
	/bin/echo "ユーザーディレクトリチェックDONE" "${ITEM_LIST}"
done
########################################
##	Public
########################################
for ITEM_LIST in "${LIST_USER[@]}"; do
	/bin/chmod 755 "/Users/${ITEM_LIST}/Public"
	##
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Drop Box"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 733 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"
	##########
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Documents"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
	##
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Downloads"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
	##
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Favorites"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf admin "$STR_CHECK_DIR_PATH"
	##########
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Groups"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 770 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf staff "$STR_CHECK_DIR_PATH"
	##
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Shared"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 750 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf staff "$STR_CHECK_DIR_PATH"
	##########
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Guest"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 777 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"
	##
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Public/Shared Items"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 775 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	/usr/bin/chgrp -Rf nobody "$STR_CHECK_DIR_PATH"
	/bin/echo "パブリックチェックDONE" "${ITEM_LIST}"
done
########################################
##	Applications
########################################
##	Applications
for ITEM_LIST in "${LIST_USER[@]}"; do
	STR_CHECK_DIR_PATH="/Users/${ITEM_LIST}/Applications"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH"
	/bin/chmod 700 "$STR_CHECK_DIR_PATH"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/.localized"
	##サブフォルダを作る
	LIST_SUB_DIR_NAME=("Demos" "Desktop" "Developer" "Documents" "Downloads" "Favorites" "Groups" "Library" "Movies" "Music" "Pictures" "Public" "Shared" "Sites" "System" "Users" "Utilities")
	##リストの数だけ処理
	for ITEM_DIR_NAME in "${LIST_SUB_DIR_NAME[@]}"; do
		/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "$STR_CHECK_DIR_PATH/$ITEM_DIR_NAME"
		/bin/chmod 700 "$STR_CHECK_DIR_PATH/${ITEM_DIR_NAME}"
		/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "$STR_CHECK_DIR_PATH/$ITEM_DIR_NAME/.localized"
	done
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





#################################
#インストール基本
#################################

STR_URL="https://go.microsoft.com/fwlink/?linkid=823060"

LOCAL_TMP_DIR=$(/usr/bin/sudo -u "$CURRENT_USER" /usr/bin/mktemp -d)
/bin/echo "TMPDIR：" "$LOCAL_TMP_DIR"

###ファイル名を取得
PKG_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
/bin/echo "PKG_FILE_NAME" "$PKG_FILE_NAME"

###ファイル名指定してダウンロード
/usr/bin/sudo -u "$CURRENT_USER" /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$PKG_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20

### インストール（上書き）を実行する
/usr/sbin/installer -pkg "$LOCAL_TMP_DIR/$PKG_FILE_NAME" -target / -dumplog -allowUntrusted -lang ja

exit 0
