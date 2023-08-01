#!/bin/bash

###マウント時のボリュームの名前
STR_VOLUME_NAME="ディスクイメージ"
###元になるアイコンファイルへのパス
STR_ICON_PATH="$HOME/Desktop/アイコン.icns"
###ボリューム上でのファイルパス
STR_VOLUME_ICON_PATH="/Volumes/$STR_VOLUME_NAME/.VolumeIcon.icns"
###アイコンをボリュームにリネームしてのコピー
/usr/bin/ditto "$STR_ICON_PATH" "$STR_VOLUME_ICON_PATH"
###ボリュームアイコンを定義
/usr/bin/SetFile  -c icnC "$STR_VOLUME_ICON_PATH"
###アトリビュート　アイコンをセット
/usr/bin/SetFile  -a C  "/Volumes/$STR_VOLUME_NAME"

exit 0
