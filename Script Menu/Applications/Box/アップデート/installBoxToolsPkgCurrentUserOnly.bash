#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe

########################################
##ユーザー
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"
SUDO_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
/bin/echo "実行ユーザー：" "$SUDO_USER"

USER_TEMP_DIR=$(/usr/bin/mktemp -d)
/bin/echo "ダウンロードディレクトリ：" "$USER_TEMP_DIR"

###BOX TOOLSはユニバーサルなので現時点では同じPKGをインストールする
ARCHITEC=$(/usr/bin/arch)
/bin/echo "CPUの種類チェック： $ARCHITEC"
if [ "$ARCHITEC" == "arm64" ]; then
	if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/BoxToolsInstaller.pkg" 'https://box-installers.s3.amazonaws.com/boxedit/mac/currentrelease/BoxToolsInstaller.pkg' --connect-timeout 20; then
		echo "ファイルのダウンロードに失敗しました"
		exit 1
	fi
else
	if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/BoxToolsInstaller.pkg" 'https://box-installers.s3.amazonaws.com/boxedit/mac/currentrelease/BoxToolsInstaller.pkg' --connect-timeout 20; then
		echo "ファイルのダウンロードに失敗しました"
		exit 1
	fi
fi

/usr/bin/killall -9 "Box Tools Custom Apps"
/usr/bin/killall -9 "Box Local Com Server"
/usr/bin/killall -9 "BoxEditFinderExtension"
/usr/bin/killall -9 "Box Edit"
/usr/bin/killall -9 "Box Device Trust"


/usr/sbin/installer -dumplog -verbose -pkg "$USER_TEMP_DIR/BoxToolsInstaller.pkg" -target CurrentUserHomeDirectory -allowUntrusted -lang ja

##これはインストーラーがやってくれる
#	/usr/bin/pluginkit -e use -i com.box.desktop.ui
#	/usr/bin/pluginkit -e use -i com.box.desktop.helper
#	/usr/bin/pluginkit -e use -i com.box.box-edit
#	/usr/bin/pluginkit -e use -i com.box.Box-Local-Com-Server.BoxToolsSafariExtension
#	/usr/bin/pluginkit -e use -i com.Box.Box-Edit.BoxEditFinderExtension
#	/usr/bin/pluginkit -e use -i com.box.desktop.findersyncext
#	/usr/bin/pluginkit -e use -i com.apple.FinderSync

/bin/echo "処理終了しました"

exit 0
