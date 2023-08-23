#!/bin/zsh
#Vs Codeのコンソールで実行すると文字化けする
# テスト中　何か違う気もする
########################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"
if [ "$USER_WHOAMI" != "root" ]; then
  /bin/echo "このスクリプトを実行するには管理者権限が必要です。"
  /bin/echo "sudo で実行してください"
  ### path to me
	SCRIPT_PATH="${(%):-%N}"
	##SCRIPT_CONTEINER_DIR_PATH=$(print -r -- ${(%)PWD})

  /bin/echo "/usr/bin/sudo \"$SCRIPT_PATH\""
  /bin/echo "↑を実行してください"
  exit 1
else
  ###実行しているユーザー名
  SUDO_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
  /bin/echo "実行ユーザー：" "$SUDO_USER"
fi
STR_ARMMF_URL="https://armmf.adobe.com/arm-manifests/mac/AcrobatDC/acrobat/current_version.txt"

STR_DC_PLIST="/Applications/Adobe Acrobat DC/Adobe Acrobat.app/Contents/Info.plist"
STR_RD_PLIST="/Applications/Adobe Acrobat Reader.app/Contents/Info.plist"


STR_ARMMF_VERSION=$(/usr/bin/curl -s "$STR_ARMMF_URL")
/bin/echo "最新バージョン" $STR_ARMMF_VERSION

if [[ -e "$STR_DC_PLIST" ]]; then
STR_DC_VERSION=$(/usr/bin/defaults read "$STR_DC_PLIST" CFBundleVersion)
/bin/echo "DCインストール済み：$STR_DC_VERSION"
if [ "$STR_DC_VERSION" != "$STR_ARMMF_VERSION" ]; then
BOOL_DC_INSTALL="true"
/bin/echo "DCアップデートがあります"
fi
else
/bin/echo "DC未インストール"
BOOL_DC_INSTALL="false"
fi

if [[ -e "$STR_RD_PLIST" ]]; then
STR_RD_VERSION=$(/usr/bin/defaults read "$STR_RD_PLIST" CFBundleVersion)
/bin/echo "RDインストール済み：$STR_RD_VERSION"
if [ "$STR_RD_VERSION" != "$STR_ARMMF_VERSION" ]; then
BOOL_RD_INSTALL="true"
/bin/echo "RDアップデートがあります"
fi
else
/bin/echo "RD未インストール"
if [ "$BOOL_DC_INSTALL" = "false" ]; then
exit 1
fi
fi


########################################
###
STR_VERSION=$(/bin/echo "$STR_ARMMF_VERSION" | /usr/bin/tr -d '.')
/bin/echo "識別番号: $STR_VERSION"
STR_DC_URL="https://ardownload2.adobe.com/pub/adobe/acrobat/mac/AcrobatDC/"$STR_VERSION"/AcrobatDCUpd"$STR_VERSIO"N.dmg"
STR_RD_URL="https://ardownload2.adobe.com/pub/adobe/reader/mac/AcrobatDC/"$STR_VERSION"/AcroRdrDCUpd"$STR_VERSION"_MUI.dmg"
//bin/echo $STR_DC_URL
//bin/echo $STR_RD_URL

########################################
###ダウンロード起動時に削除する項目
USER_TEMP_DIR=$(/usr/bin/mktemp -d /private/tmp/XXXXXXX)
/bin/chmod 777 "$USER_TEMP_DIR"
/bin/echo "起動時に削除されるディレクトリ：" "$USER_TEMP_DIR"
/bin/echo $USER_TEMP_DIR
########################################
if [ "$BOOL_DC_INSTALL" = "true" ]; then
	###ファイル名を取得
	DC_DMG_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_DC_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
	/bin/echo "DL_FILE_NAME:$DL_FILE_NAME"
	if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/$DC_DMG_NAME" "$STR_DC_URL" --connect-timeout 20; then
		/bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
		if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/$DC_DMG_NAME" "$STR_DC_URL" --http1.1 --connect-timeout 20; then
			/bin/echo "ファイルのダウンロードに失敗しました"
			exit 1
		fi
	fi
fi
########################################
if [ "$BOOL_RD_INSTALL" = "true" ]; then
	###ファイル名を取得
  RD_DMG_NAME=$(/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' "$STR_RD_URL" | /usr/bin/rev | /usr/bin/cut -d'/' -f1 | /usr/bin/rev)
	/bin/echo "DL_FILE_NAME:$RD_DMG_NAME"
	if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/$RD_DMG_NAME" "$STR_RD_URL" --connect-timeout 20; then
		/bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
		if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/$RD_DMG_NAME" "$STR_RD_URL" --http1.1 --connect-timeout 20; then
			/bin/echo "ファイルのダウンロードに失敗しました"
			exit 1
		fi
	fi
fi
########################################
if [ "$BOOL_DC_INSTALL" = "true" ]; then
/bin/echo  "ディスクイメージをマウントします（Finderには表示されません）"
/bin/mkdir -p "/private/tmp/MountPoint/DC"
/bin/chmod 777 "/private/tmp/MountPoint/DC"
/usr/bin/hdiutil attach "$USER_TEMP_DIR/$DC_DMG_NAME" -noverify -nobrowse -noautoopen -mountpoint "/private/tmp/MountPoint/DC"
sleep 2
/bin/echo  "インストールします"
STR_DMG_NAME=$(/bin/ls "/private/tmp/MountPoint")
STR_PKG_NAME=$(/bin/ls "/private/tmp/MountPoint/DC")
/usr/sbin/installer  -pkg  "/private/tmp/MountPoint/$STR_DMG_NAME/$STR_PKG_NAME" -target / -dumplog -allowUntrusted -verboseR -lang ja
/bin/echo  "インストール終了"
/usr/bin/hdiutil detach "/private/tmp/MountPoint/$STR_DMG_NAME" -force
/bin/echo  "ディスクイメージ　アンマウント"
sleep 2
/bin/rmdir "/private/tmp/MountPoint/DC"
fi

########################################
if [ "$BOOL_RD_INSTALL" = "true" ]; then
/bin/echo  "ディスクイメージをマウントします（Finderには表示されません）"
/bin/mkdir -p "/private/tmp/MountPoint/RD"
/bin/chmod 777 "/private/tmp/MountPoint/RD"
/usr/bin/hdiutil attach "$USER_TEMP_DIR/$RD_DMG_NAME" -noverify -nobrowse -noautoopen -mountpoint "/private/tmp/MountPoint/RD"
sleep 2
/bin/echo  "インストールします"
STR_DMG_NAME=$(/bin/ls "/private/tmp/MountPoint")
STR_PKG_NAME=$(/bin/ls "/private/tmp/MountPoint/RD")
/usr/sbin/installer  -pkg  "/private/tmp/MountPoint/$STR_DMG_NAME/$STR_PKG_NAME" -target / -dumplog -allowUntrusted -verboseR -lang ja
/bin/echo  "インストール終了"
/usr/bin/hdiutil detach "/private/tmp/MountPoint/$STR_DMG_NAME" -force
/bin/echo  "ディスクイメージ　アンマウント"
/bin/rmdir "/private/tmp/MountPoint/RD"
fi
