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
	SUDO_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
	/bin/echo "実行ユーザー：" "$SUDO_USER"
fi

#################################
#インストール基本
#################################
###
STR_URL="https://go.microsoft.com/fwlink/?linkid=868963"


LOCAL_TMP_DIR=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/mktemp -d)
/bin/echo "TMPDIR：" "$LOCAL_TMP_DIR"

###ファイル名を取得
PKG_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
/bin/echo "PKG_FILE_NAME" "$PKG_FILE_NAME"

###ファイル名指定してダウンロード
/usr/bin/sudo -u "$SUDO_USER" /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$PKG_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20

### インストール（上書き）を実行する
/usr/sbin/installer -pkg "$LOCAL_TMP_DIR/$PKG_FILE_NAME" -target / -dumplog -allowUntrusted -lang ja


exit 0
