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

##########################################
##JSON ダウンロード
STR_JSON_FILE_NAME="Autoupdate3.json"
STR_JSON_URL="https://cdn07.boxcdn.net/Autoupdate3.json"
##起動時に削除される項目
LOCAL_TMP_DIR=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/mktemp -d)
/bin/echo "TMPDIR：" "$LOCAL_TMP_DIR"
##ダウンロード
  if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$STR_JSON_FILE_NAME" "$STR_JSON_URL" --connect-timeout 20; then
    /bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
    if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$STR_JSON_FILE_NAME" "$STR_JSON_URL" --http1.1 --connect-timeout 20; then
      /bin/echo "ファイルのダウンロードに失敗しました"
      exit 1
    fi
  fi
/bin/echo "JSONダウンロードOK"
/bin/sleep 1
##########################################
##PLISTに変換
STR_PLIST_FILE_NAME="Autoupdate3.plist"
/usr/bin/plutil -convert xml1 "$LOCAL_TMP_DIR/$STR_JSON_FILE_NAME" -o "$LOCAL_TMP_DIR/$STR_PLIST_FILE_NAME"
/bin/echo "PLIST変換OK"
/bin/sleep 1
##########################################
## ダウンロードURLとバージョン（今回はバージョンチェックはせずEAPアーリーアクセスを利用する）
STR_PKG_URL_EAP=$(/usr/libexec/PlistBuddy -c "Print:mac:eap:download-url" "$LOCAL_TMP_DIR/$STR_PLIST_FILE_NAME")
/bin/echo "EAP:" "$STR_PKG_URL_EAP"
STR_PKG_VER_EAP=$(/usr/libexec/PlistBuddy -c "Print:mac:eap:version" "$LOCAL_TMP_DIR/$STR_PLIST_FILE_NAME")
/bin/echo "EAPv:" "$STR_PKG_VER_EAP"
STR_PKG_URL_RO=$(/usr/libexec/PlistBuddy -c "Print:mac:free:rollout-url" "$LOCAL_TMP_DIR/$STR_PLIST_FILE_NAME")
/bin/echo "Rollout:" "$STR_PKG_URL_RO"
STR_PKG_VER_RO=$(/usr/libexec/PlistBuddy -c "Print:mac:free:rollout-version" "$LOCAL_TMP_DIR/$STR_PLIST_FILE_NAME")
/bin/echo "Rolloutv:" "$STR_PKG_VER_RO"

#################################
###CPUタイプでの分岐
ARCHITEC=$(/usr/bin/arch)
if [ "$ARCHITEC" == "arm64" ]; then
  PKG_FILE_NAME="BoxDrive.pkg"
  STR_URL=$STR_PKG_URL_EAP
else
  PKG_FILE_NAME="BoxDrive.pkg"
  STR_URL=$STR_PKG_URL_EAP
fi
/bin/echo "$STR_URL"
#################################
##ダウンロード
LOCAL_TMP_DIR=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/mktemp -d)
/bin/echo "TMPDIR：" "$LOCAL_TMP_DIR"

if [ "$ARCHITEC" == "arm64" ]; then
  /bin/echo "Running on $ARCHITEC"
  ###ダウンロード
  if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$PKG_FILE_NAME" "$STR_URL" --connect-timeout 20; then
    /bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
    if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$PKG_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20; then
      /bin/echo "ファイルのダウンロードに失敗しました"
      exit 1
    fi
  fi
else
  /bin/echo "Running on $ARCHITEC"
  ###ダウンロード
  if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$PKG_FILE_NAME" "$STR_URL" --connect-timeout 20; then
    /bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
    if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$PKG_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20; then
      /bin/echo "ファイルのダウンロードに失敗しました"
      exit 1
    fi
  fi
fi
#################################
###プロセス終了
STR_APP_NAME="Box.app"
###
STR_PLIST_PATH="/Applications/$STR_APP_NAME/Contents/Info.plist"
STR_BUNDLE_ID=$(/usr/bin/defaults read "$STR_PLIST_PATH" CFBundleIdentifier)
/bin/echo "STR_BUNDLE_ID" "$STR_BUNDLE_ID"
##念の為　KILLもする
/usr/bin/sudo /usr/bin/killall "Box" 2>/dev/null
/usr/bin/sudo /usr/bin/killall "Box Autoupdater" 2>/dev/null
/usr/bin/sudo /usr/bin/killall "Box Edit" 2>/dev/null
/usr/bin/sudo /usr/bin/killall "Box Edit Finder Extension" 2>/dev/null
/usr/bin/sudo /usr/bin/killall "Box Helper" 2>/dev/null
/usr/bin/sudo /usr/bin/killall "Box Local Com Server" 2>/dev/null
/usr/bin/sudo /usr/bin/killall "Box UI" 2>/dev/null
/usr/bin/sudo /bin/echo "アプリケーション終了"
/bin/sleep 2

#################################
### インストール（上書き）を実行する
/usr/bin/sudo /usr/sbin/installer -pkg "$LOCAL_TMP_DIR/$PKG_FILE_NAME" -target / -dumplog -allowUntrusted -lang ja

/bin/echo "処理終了"
exit 0
