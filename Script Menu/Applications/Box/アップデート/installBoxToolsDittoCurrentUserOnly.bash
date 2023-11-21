#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe

########################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"
if [ "$USER_WHOAMI" != "root" ]; then
	/bin/echo "このスクリプトを実行するには管理者権限が必要です。"
	/bin/echo "sudo で実行してください"
	exit 1
else
	###実行しているユーザー名
	SUDO_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
	/bin/echo "実行ユーザー：" "$SUDO_USER"
fi

########################################
###全ユーザーで使う起動時に削除する項目
/bin/mkdir -p "/private/tmp/TemporaryItems/Trash"
LOCAL_TMP_DIR=$(/usr/bin/mktemp -d "/private/tmp/TemporaryItems/XXXXXXXX")
/bin/chmod -Rf 777 "/private/tmp/TemporaryItems"
/bin/echo "LOCAL_TMP_DIR:CURL:" "$LOCAL_TMP_DIR"
### CPUタイプでの分岐
###BOX TOOLSはユニバーサルなので現時点では同じPKGをインストールする
ARCHITEC=$(/usr/bin/arch)
/bin/echo "Running on $ARCHITEC"
if [ "$ARCHITEC" == "arm64" ]; then
	if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/BoxToolsInstaller.dmg" 'https://e3.boxcdn.net/box-installers/boxedit/mac/currentrelease/BoxToolsInstaller.dmg' --connect-timeout 20; then
		echo "ファイルのダウンロードに失敗しました"
		exit 1
	fi
else
	if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/BoxToolsInstaller.dmg" 'https://e3.boxcdn.net/box-installers/boxedit/mac/currentrelease/BoxToolsInstaller.dmg' --connect-timeout 20; then
		echo "ファイルのダウンロードに失敗しました"
		exit 1
	fi
fi
##全ユーザー実行可能にしておく
/bin/chmod 755 "$LOCAL_TMP_DIR/BoxToolsInstaller.dmg"

########################################
###アプリケーションの終了
###コンソールユーザーにのみ処理する
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print  $3}')
/bin/echo "CONSOLE_USER:$CONSOLE_USER"
if [ -z "$CONSOLE_USER" ]; then
	/bin/echo "コンソールユーザーが無い=電源入れてログインウィンドウ状態"
else
	/usr/bin/sudo -u "$USER_WHOAMI" /usr/bin/killall "Box Tools Custom Apps"
	/usr/bin/sudo -u "$USER_WHOAMI" /usr/bin/killall -9 "Box Local Com Server"
	/usr/bin/sudo -u "$USER_WHOAMI" /usr/bin/killall -9 BoxEditFinderExtension
	/usr/bin/sudo -u "$USER_WHOAMI" /usr/bin/killall -9 "Box Edit"
	/usr/bin/sudo -u "$USER_WHOAMI" /usr/bin/killall -9 "Box Device Trust"
fi
/bin/sleep 2
##念の為　KILLもする
/usr/bin/sudo /usr/bin/killall -9 "Box Tools Custom Apps" 2>/dev/null
/usr/bin/sudo /usr/bin/killall -9 "Box Local Com Server" 2>/dev/null
/usr/bin/sudo /usr/bin/killall -9 BoxEditFinderExtension 2>/dev/null
/usr/bin/sudo /usr/bin/killall -9 "Box Edit" 2>/dev/null
/usr/bin/sudo /usr/bin/killall -9 "Box Device Trust" 2>/dev/null
/bin/echo "CONSOLE_USER:Done Killall"

########################################
###ローカルのユーザーアカウントを取得
TEXT_RESULT=$(/usr/bin/dscl localhost -list /Local/Default/Users PrimaryGroupID | /usr/bin/awk '$2 == 20 { print $1 }')

###リストにする
read -d '\n' -r -a LIST_USER <<<"$TEXT_RESULT"

###リスト内の項目数
NUM_CNT=${#LIST_USER[@]}
/bin/echo "ユーザー数：" "$NUM_CNT"
########################################
##リストの内容を順番に処理
for ITEM_LIST in "${LIST_USER[@]}"; do
	/bin/echo "LIST_USER:MKDIR:" "${ITEM_LIST}"
	##ライブラリの不可視属性を解除
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/chflags nohidden /Users/"${ITEM_LIST}"/Library
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/SetFile -a v /Users/"${ITEM_LIST}"/Library
	##ユーザーアプリケーションフォルダを作る
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Applications"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 700 "/Users/${ITEM_LIST}/Applications"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/chown "${ITEM_LIST}" "/Users/${ITEM_LIST}/Applications"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "/Users/${ITEM_LIST}/Applications/.localized"
	##ユーザーユーティリティフォルダを作る
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Applications/Utilities"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 755 "/Users/${ITEM_LIST}/Applications/Utilities"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/chown "${ITEM_LIST}" "/Users/${ITEM_LIST}/Applications/Utilities"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "/Users/${ITEM_LIST}/Applications/Utilities/.localized"
	##　Managed Itemsフォルダを作る
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Library/Managed Items"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 755 "/Users/${ITEM_LIST}/Library/Managed Items"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/chown "${ITEM_LIST}" "/Users/${ITEM_LIST}/Library/Managed Items"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "/Users/${ITEM_LIST}//Library/Managed Items/.localized"
	##　Workflowsフォルダを作る
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Library/Workflows"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 755 "/Users/${ITEM_LIST}/Library/Workflows"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/chown "${ITEM_LIST}" "/Users/${ITEM_LIST}/Library/Workflows"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "/Users/${ITEM_LIST}//Library/Workflows/.localized"
	##Scripts
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Library/Scripts"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 755 "/Users/${ITEM_LIST}/Library/Scripts"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/chown "${ITEM_LIST}" "/Users/${ITEM_LIST}/Library/Scripts"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "/Users/${ITEM_LIST}//Library/Scripts/.localized"
	##Services
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Library/Services"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 755 "/Users/${ITEM_LIST}/Library/Services"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/chown "${ITEM_LIST}" "/Users/${ITEM_LIST}/Library/Services"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "/Users/${ITEM_LIST}//Library/Services/.localized"
	##Documentation
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Library/Documentation"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 755 "/Users/${ITEM_LIST}/Library/Documentation"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/chown "${ITEM_LIST}" "/Users/${ITEM_LIST}/Library/Documentation"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "/Users/${ITEM_LIST}//Library/Documentation/.localized"
	##Developer
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Library/Developer"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 755 "/Users/${ITEM_LIST}/Library/Developer"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/chown "${ITEM_LIST}" "/Users/${ITEM_LIST}/Library/Developer"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/touch "/Users/${ITEM_LIST}//Library/Developer/.localized"

	##アクセス権チェック
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 700 "/Users/${ITEM_LIST}/Library"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 700 "/Users/${ITEM_LIST}/Movies"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 700 "/Users/${ITEM_LIST}/Music"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 700 "/Users/${ITEM_LIST}/Pictures"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 700 "/Users/${ITEM_LIST}/Downloads"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 700 "/Users/${ITEM_LIST}/Documents"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 700 "/Users/${ITEM_LIST}/Desktop"
	##全ローカルユーザーに対して実施したい処理があれば追加する
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 777 "/Users/${ITEM_LIST}/Library/Caches"
done

for ITEM_LIST in "${LIST_USER[@]}"; do
	/bin/echo "$SUDO_USER:INSTALL:" "${ITEM_LIST}"
	########################################
	/bin/echo "処理開始:" "${ITEM_LIST}"
	##BOXフォルダを作成
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/mkdir -p "/Users/${ITEM_LIST}/Library/Application Support/Box/Box Edit"
	/usr/bin/sudo -u "${ITEM_LIST}" /bin/chmod 755 "/Users/${ITEM_LIST}/Library/Application Support/Box/Box Edit"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/sbin/chown "${ITEM_LIST}" "/Users/${ITEM_LIST}/Library/Application Support/Box/Box Edit"

	###ディスクをマウント
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/hdiutil attach "$LOCAL_TMP_DIR/BoxToolsInstaller.dmg" -noverify -nobrowse -noautoopen
	###ファイルをコピーして
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/ditto "/Volumes/Box Tools Installer/Install Box Tools.app/Contents/Resources/Box Device Trust.app" "/Users/${ITEM_LIST}/Library/Application Support/Box/Box Edit/Box Device Trust.app"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/ditto "/Volumes/Box Tools Installer/Install Box Tools.app/Contents/Resources/Box Edit.app" "/Users/${ITEM_LIST}/Library/Application Support/Box/Box Edit/Box Edit.app"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/ditto "/Volumes/Box Tools Installer/Install Box Tools.app/Contents/Resources/Box Local Com Server.app" "/Users/${ITEM_LIST}/Library/Application Support/Box/Box Edit/Box Local Com Server.app"
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/ditto "/Volumes/Box Tools Installer/Install Box Tools.app/Contents/Resources/Box Tools Custom Apps.app" "/Users/${ITEM_LIST}/Library/Application Support/Box/Box Edit/Box Tools Custom Apps.app"
	##トラブル防止で１秒まつ
	sleep 1
	###ディスクをアンマウント
	/usr/bin/sudo -u "${ITEM_LIST}" /usr/bin/hdiutil detach "/Volumes/Box Tools Installer" -force
	/bin/echo "処理終了:" "${ITEM_LIST}"
done

/bin/echo "処理終了しました"

exit 0
