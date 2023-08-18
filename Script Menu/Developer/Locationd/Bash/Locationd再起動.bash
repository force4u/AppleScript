#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
# 要管理者権限
########################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行ユーザー：$USER_WHOAMI"
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
	/bin/echo "実行したユーザー：" "$SUDO_USER"
fi


########################################
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###アクセス権メンテナンス
STR_DIR_PATH="/private/var/db/locationd/Library/Preferences"
/bin/echo "メンテナンスディレクトリ：$STR_DIR_PATH"
STR_RESPONSE=$(/usr/bin/chgrp -R _locationd "$STR_DIR_PATH")
/bin/echo "/usr/bin/chgrp -R _locationd $STR_DIR_PATH"
/bin/echo "↑ 実行したコマンドライン ↓ 結果"
/bin/echo "$STR_RESPONSE"

########################################
/bin/echo "locationdを再起動します"
/bin/echo "----+----1----+----2----+-----3----+----4----+----5----+----6----+----7"
###
STR_RESPONSE=$(/usr/bin/killall -HUP locationd)
/bin/echo "/usr/bin/killall -HUP locationd"
/bin/echo "↑ 実行したコマンド "
/bin/echo "$STR_RESPONSE"
exit 0
