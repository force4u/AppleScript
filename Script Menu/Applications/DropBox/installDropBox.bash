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
## RSSから最新のバージョンを取得する
STR_RSS_URL="https://www.dropboxforum.com/mxpez29397/rss/board?board.id=101003016"
XML_RSS_DATA=$(/usr/bin/curl -s "$STR_RSS_URL" | xmllint --format -)
STR_TITLE=$(echo "$XML_RSS_DATA" | xmllint --xpath "//item/title/text()" -)
IFS=$'\n' read -r -d '' -a LIST_TITLE <<<"$STR_TITLE"

for ITEM_TITLE in "${LIST_TITLE[@]}"; do
  if [[ $ITEM_TITLE == *"Stable"* ]]; then
  /bin/echo "$ITEM_TITLE"
    read -ra ARRAY_TITLE <<<"$ITEM_TITLE"
    STR_VERSION=${ARRAY_TITLE[2]}
  /bin/echo "$STR_VERSION"
    break
  fi
done
#################################
##URLを生成する
STR_BASE_URL="https://edge.dropboxstatic.com/dbx-releng/client/"
###CPUタイプでの分岐
ARCHITEC=$(/usr/bin/arch)
if [ "$ARCHITEC" == "arm64" ]; then
STR_DMG_FILE_NAME="Dropbox%20$STR_VERSION.arm64.dmg"
DL_FILE_NAME="Dropbox $STR_VERSION.arm64.dmg"
STR_URL="$STR_BASE_URL$STR_DMG_FILE_NAME"
else
STR_DMG_FILE_NAME="Dropbox%20$STR_VERSION.dmg" 
DL_FILE_NAME="Dropbox $STR_VERSION.dmg"
STR_URL="$STR_BASE_URL$STR_DMG_FILE_NAME"
fi
  /bin/echo "$STR_URL"
#################################
##ダウンロード
LOCAL_TMP_DIR=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/mktemp -d)
/bin/echo "TMPDIR：" "$LOCAL_TMP_DIR"

if [ "$ARCHITEC" == "arm64" ]; then
  /bin/echo "Running on $ARCHITEC"
  ###ダウンロード
  if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$DL_FILE_NAME" "$STR_URL" --connect-timeout 20; then
    /bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
    if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$DL_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20; then
      /bin/echo "ファイルのダウンロードに失敗しました"
      exit 1
    fi
  fi
else
  /bin/echo "Running on $ARCHITEC"
  ###ダウンロード
  if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$DL_FILE_NAME" "$STR_URL" --connect-timeout 20; then
    /bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
    if ! /usr/bin/curl -L -o "$LOCAL_TMP_DIR/$DL_FILE_NAME" "$STR_URL" --http1.1 --connect-timeout 20; then
      /bin/echo "ファイルのダウンロードに失敗しました"
      exit 1
    fi
  fi
fi
#################################
###プロセス終了
STR_APP_NAME="Dropbox.app"
###
STR_PLIST_PATH="/Applications/$STR_APP_NAME/Contents/Info.plist"
STR_BUNDLE_ID=$(/usr/bin/defaults read "$STR_PLIST_PATH" CFBundleIdentifier)
/bin/echo "STR_BUNDLE_ID" "$STR_BUNDLE_ID"
##念の為　KILLもする
/usr/bin/killall "Dropbox" 2>/dev/null
/usr/bin/killall "Dropbox Helper" 2>/dev/null
/usr/bin/killall "Dropbox Helper (Renderer)" 2>/dev/null
/usr/bin/killall "Dropbox Helper (Plugin)" 2>/dev/null
/usr/bin/killall "Dropbox Helper (GPU)" 2>/dev/null
/usr/bin/killall "DropboxActivityProvider" 2>/dev/null
/usr/bin/killall "DropboxFileProviderCH" 2>/dev/null
/usr/bin/killall "DropboxFileProvider" 2>/dev/null
/usr/bin/killall "DropboxTransferExtension" 2>/dev/null
/bin/echo "アプリケーション終了"
/bin/sleep 2

#################################
	function DO_MOVE_TO_TRASH() {
		if [ -e "$1" ]; then
			TRASH_DIR=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/mktemp -d "/var/folders/TemporaryItems/XXXXXXXX")
			/usr/bin/sudo /bin/chmod 777 "$TRASH_DIR"
			/usr/bin/sudo /bin/mv "$1" "$TRASH_DIR"
			##削除
			/usr/bin/sudo /usr/bin/find "$TRASH_DIR" -mindepth 1 -delete
		fi
  }
#####古いファイルをゴミ箱に  LOCAL
DO_MOVE_TO_TRASH "/Library/DropboxHelperTools"
DO_MOVE_TO_TRASH "/Applications/Dropbox.app"
DO_MOVE_TO_TRASH "/Users/$SUDO_USER/Library/Dropbox"
DO_MOVE_TO_TRASH "/Users/$SUDO_USER/Library/HTTPStorages/com.dropbox.DropboxMacUpdate"
DO_MOVE_TO_TRASH "/Users/$SUDO_USER/Library/HTTPStorages/com.getdropbox.dropbox"
#################################
/usr/bin/hdiutil attach  "$LOCAL_TMP_DIR/$DL_FILE_NAME" -noverify -nobrowse -noautoopen


###########この方法だとサイレントにならない
#/usr/bin/sudo "/Volumes/Dropbox Offline Installer/Dropbox.app/Contents/MacOS/Dropbox" - nolaunch

/usr/bin/ditto "/Volumes/Dropbox Offline Installer/Dropbox.app" "/Applications/Dropbox.app"

/usr/bin/hdiutil detach "/Volumes/Dropbox Offline Installer" -force

###ここは好みの問題か？
/usr/bin/sudo  chown -Rf root "/Applications/Dropbox.app"
#/usr/bin/sudo  chown -Rf "$SUDO_USER" "/Applications/Dropbox.app"

###実行はユーザーにまかせるのもあり？
##/usr/bin/sudo "/Applications/Dropbox.app/Contents/MacOS/Dropbox" - nolaunch
##/usr/bin/sudo -u "$SUDO_USER" "/Applications/Dropbox.app/Contents/MacOS/Dropbox" - nolaunch

exit 0

