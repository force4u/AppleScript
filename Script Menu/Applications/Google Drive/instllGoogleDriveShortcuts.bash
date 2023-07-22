#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
########################################
/bin/echo "処理開始"
##定型処理
/bin/mkdir -p "$HOME/Applications"
/bin/chmod 700 "$HOME/Applications"
/usr/bin/touch "$HOME/Applications/.localized"

/bin/mkdir -p "$HOME/Applications/Utilities"
/bin/chmod 755 "$HOME/Applications/Utilities"
/usr/bin/touch "$HOME/Applications/Utilities/.localized"

/bin/mkdir -p "$HOME/Applications/CloudStorage"
/bin/chmod 755 "$HOME/Applications/CloudStorage"

/bin/mkdir -p "$HOME/Library/Scripts/Applications/Finder/CloudStorage"
/bin/chmod 755 "$HOME/Library/Scripts/Applications/Finder/CloudStorage"

/usr/bin/chflags nohidden "$HOME"/Library
/usr/bin/SetFile -a v "$HOME"/Library
/bin/echo "定型処理終了"
########################################
##ダウンロード
STR_TMP_DIR=$(/usr/bin/mktemp -d)
/bin/echo "$STR_TMP_DIR"
/usr/bin/curl -L -o "$STR_TMP_DIR/GoogleDrive.dmg" 'https://dl.google.com/drive-file-stream/GoogleDrive.dmg' --connect-timeout 20
##ディスクをマウント
/usr/bin/hdiutil attach "$STR_TMP_DIR/GoogleDrive.dmg" -noverify -nobrowse -noautoopen
##PKGをコピー
/usr/bin/ditto "/Volumes/Install Google Drive/GoogleDrive.pkg" "$STR_TMP_DIR/GoogleDrive.pkg"
##ディスクをアンマウント
/usr/bin/hdiutil detach "/Volumes/Install Google Drive" -force
##パッケージ第一階層を解凍
/usr/sbin/pkgutil --expand "$STR_TMP_DIR/GoogleDrive.pkg" "$STR_TMP_DIR/GoogleDriveExpaned"
##GoogleDriveShortcuts.pkgのPayloadを解凍
/usr/bin/ditto -xz "$STR_TMP_DIR/GoogleDriveExpaned/GoogleDriveShortcuts.pkg/Payload" "$STR_TMP_DIR/GoogleDriveShortcuts"
##必要な場所にコピー
/usr/bin/ditto "$STR_TMP_DIR/GoogleDriveShortcuts/Google Docs.app" "$HOME/Library/Scripts/Applications/Finder/CloudStorage/Google Docs.app"
/usr/bin/ditto "$STR_TMP_DIR/GoogleDriveShortcuts/Google Sheets.app" "$HOME/Library/Scripts/Applications/Finder/CloudStorage/Google Sheets.app"
/usr/bin/ditto "$STR_TMP_DIR/GoogleDriveShortcuts/Google Slides.app" "$HOME/Library/Scripts/Applications/Finder/CloudStorage/Google Slides.app"

/usr/bin/ditto "$STR_TMP_DIR/GoogleDriveShortcuts/Google Docs.app" "$HOME/Applications/CloudStorage/Google Docs.app"
/usr/bin/ditto "$STR_TMP_DIR/GoogleDriveShortcuts/Google Sheets.app" "$HOME/Applications/CloudStorage/Google Sheets.app"
/usr/bin/ditto "$STR_TMP_DIR/GoogleDriveShortcuts/Google Slides.app" "$HOME/Applications/CloudStorage/Google Slides.app"

###作業ファイルをゴミ箱に
function DO_MOVE_TO_TRASH() {
	if [ -e "$1" ]; then
		TRASH_DIR=$(/usr/bin/mktemp -d "$HOME/.Trash/XXXXXXXX")
		/bin/mv "$1" "$TRASH_DIR"
	fi
}
DO_MOVE_TO_TRASH "$STR_TMP_DIR"
exit 0
