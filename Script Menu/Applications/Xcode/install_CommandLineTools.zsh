#!/bin/zsh
#com.cocolog-nifty.quicktimer.icefloe

########################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行中ユーザー：$USER_WHOAMI"
if [ "$USER_WHOAMI" != "root" ]; then
	/bin/echo "このスクリプトを実行するには管理者権限が必要です。"
	/bin/echo "sudo で実行してください"
	### path to me
	##	SCRIPT_PATH="${BASH_SOURCE[0]}"
	SCRIPT_PATH="${(%):-%N}"
	/bin/echo "/bin/chmod 755 \"$SCRIPT_PATH\" | /usr/bin/sudo \"$SCRIPT_PATH\""
	/bin/echo "↑を実行してください"
	exit 1
else
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
/bin/echo "コンソールユーザー(scutil)：$CONSOLE_USER"
	###実行しているユーザー名
	CURRENT_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
	/bin/echo "実行ユーザー(HOME): $CURRENT_USER"
fi
LOGIN_NAME=$(/usr/bin/logname)
/bin/echo "ログイン名(logname): $LOGIN_NAME"
###UID
USER_NAME=$(/usr/bin/id -un)
/bin/echo "ユーザー名(id): $USER_NAME"
###SUDOUSER
/bin/echo "SUDO_USER: $SUDO_USER"
########################################
##リセット
/usr/bin/sudo /usr/bin/xcode-select --reset
NUM_RESULT=$?
if [ $NUM_RESULT -eq 0 ]; then
    /bin/echo "xcode-select リセット　しました"
else
    /bin/echo "xcode-select リセット　失敗しました"
fi
##パス
/bin/echo "インストールパス"
/usr/bin/xcode-select  -p
##インストール
/bin/echo "xcode-select インストール"
/usr/bin/sudo /usr/bin/xcode-select --install
###コマンド実行
NUM_RESULT=$?
# 直前のコマンドの終了ステータスをチェック
if [[ $NUM_RESULT -eq 0 ]]; then
    echo "コマンドは成功しました"
else
	echo "コマンドは失敗しました"
	echo "システム設定＞一般＞ソフトウェアアップデートを起動します"
	open "x-apple.systempreferences:com.apple.Software-Update-Settings.extension?SoftwareUpdate"
	exit 1
fi

exit 0 
