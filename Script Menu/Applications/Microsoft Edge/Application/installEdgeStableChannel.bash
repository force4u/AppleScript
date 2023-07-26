#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
# 要管理者権限
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
###ここだけ変えればなんでいけるか？
STR_URL="https://go.microsoft.com/fwlink/?linkid=2093504"
###
STR_APP_NAME="Microsoft Edge"

LOCAL_TMP_DIR=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/mktemp -d)
/bin/echo "TMPDIR：" "$LOCAL_TMP_DIR"

###ファイル名を取得
PKG_FILE_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
/bin/echo "PKG_FILE_NAME" "$PKG_FILE_NAME"

###ファイル名指定してダウンロード
/usr/bin/sudo -u "$SUDO_USER" /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$PKG_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20


###コンソールユーザーにのみ処理する
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
/bin/echo "CONSOLE_USER:$CONSOLE_USER"
if [ -z "$CONSOLE_USER" ]; then
	/bin/echo "コンソールユーザーが無い=電源入れてログインウィンドウ状態"
else
	#####OSAスクリプトはエラーすることも多い(初回インストール時はエラーになる)
	if ! /usr/bin/osascript -e "tell application id \"com.microsoft.edgemac\" to quit"; then
		##念の為　KILLもする
		/usr/bin/killall "$STR_APP_NAME" 2>/dev/null
		/usr/bin/killall "$STR_APP_NAME Helper" 2>/dev/null
		/usr/bin/killall "$STR_APP_NAME Helper (GPU)" 2>/dev/null
		/usr/bin/killall "$STR_APP_NAME Helper (Renderer)" 2>/dev/null
	fi
fi
/bin/sleep 2


### インストール（上書き）を実行する
/usr/sbin/installer -pkg "$LOCAL_TMP_DIR/$PKG_FILE_NAME" -target / -dumplog -allowUntrusted -lang ja

###Dockに入れない場合はコメントアウト
##	/usr/bin/sudo -u "$SUDO_USER" /usr/bin/defaults  write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/$STR_APP_NAME/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

###Dockに入れない場合はコメントアウト
##	/usr/bin/sudo -u "$SUDO_USER" /usr/bin/killall cfprefsd

###Dockに入れない場合はコメントアウト
##	/usr/bin/sudo -u "$SUDO_USER" /usr/bin/killall "Dock"

exit 0
