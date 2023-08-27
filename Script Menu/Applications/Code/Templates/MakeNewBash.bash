#!/bin/bash
#
#新規BASHのテンプレート
############################################
STR_DATE=$(/bin/date '+%s')
/bin/echo "$STR_DATE"
STR_FILE_PATH="$HOME/Desktop/$STR_DATE.bash"
/usr/bin/touch "$STR_FILE_PATH"
/bin/chmod 755 "$STR_FILE_PATH"
###このファイル
SCRIPT_PATH="${BASH_SOURCE[0]}"
/bin/echo "実行したファイル： $SCRIPT_PATH"
###コンテナ
STR_CONTAINER_DIR_PATH=$(/usr/bin/dirname "$SCRIPT_PATH")
/bin/echo "コンテナ: $STR_CONTAINER_DIR_PATH"
###テンプレートファイル※ここで指定したファイルを新規で開く
STR_TMP_FILE_PATH="$STR_CONTAINER_DIR_PATH""/MakeUserDir.txt"
/bin/echo "テンプレートファイル: $STR_TMP_FILE_PATH"
###ファイルを作って
/usr/bin/touch "$STR_FILE_PATH"
###内容をコピーする
/bin/echo "$(/bin/cat "$STR_TMP_FILE_PATH")" >> "$STR_FILE_PATH"

###########
#できたファイルをVS CODEで開く
exec /usr/bin/osascript - "$STR_FILE_PATH" <<EOF
property theFilePath : ""
on run theFilePath
set aliasFilePath to posix file theFilePath as alias
	tell application "System Events"
		tell application id "com.microsoft.VSCode"
			open theFilePath
		end tell
	end tell
end run
EOF


###########
exit 0;


