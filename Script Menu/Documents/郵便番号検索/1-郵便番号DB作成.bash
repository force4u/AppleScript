#!/bin/bash
# V2 都道府県市区町村を追加
#com.cocolog-nifty.quicktimer.icefloe
##################################################
###設定項目　CSVのファイル名
STR_CSV_FILE_NAME="utf_all.csv"
### path to me
SCRIPT_PATH="${BASH_SOURCE[0]}"
/bin/echo "このスクリプトのパス $SCRIPT_PATH"
STR_CONTAINER_DIR_PATH=$(/usr/bin/dirname "$SCRIPT_PATH")
/bin/echo "コンテナディレクトリ $STR_CONTAINER_DIR_PATH"
STR_DATA_DIR_PATH="$STR_CONTAINER_DIR_PATH/data"
/bin/mkdir -p "$STR_DATA_DIR_PATH"
/bin/echo "データ格納ディレクトリ $STR_DATA_DIR_PATH"
STR_CSV_FILE_PATH="$STR_DATA_DIR_PATH/$STR_CSV_FILE_NAME"
/bin/echo "CSVのファイルパス $STR_CSV_FILE_PATH"
STR_IMPORT_FILE_PATH="$STR_DATA_DIR_PATH/$STR_CSV_FILE_NAME.import.csv"
/bin/echo "SQLインポート用CSVの書き出しパス $STR_IMPORT_FILE_PATH"
STR_DB_FILE_PATH="$STR_DATA_DIR_PATH/postno.db"
/bin/echo "SQLDBのパス $STR_DB_FILE_PATH"
##################################################
###古いデータは削除する
/usr/bin/touch "$STR_IMPORT_FILE_PATH"
/usr/bin/touch "$STR_DB_FILE_PATH"
/usr/bin/touch "$STR_CSV_FILE_PATH"
/bin/rm  "$STR_IMPORT_FILE_PATH"
/bin/rm  "$STR_DB_FILE_PATH"
/bin/rm  "$STR_CSV_FILE_PATH"
##################################################
STR_URL="https://www.post.japanpost.jp/zipcode/dl/utf/zip/utf_all.zip"
###ダウンロード起動時に削除する項目
USER_TEMP_DIR=$(/usr/bin/mktemp -d)
/bin/echo "起動時に削除されるディレクトリ $USER_TEMP_DIR"
if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/utf_all.zip" "$STR_URL" --connect-timeout 20; then
	/bin/echo "ファイルのダウンロードに失敗しました HTTP1.1で再トライします"
	if ! /usr/bin/curl -L -o "$USER_TEMP_DIR/utf_all.zip" "$STR_URL" --http1.1 --connect-timeout 20; then
		/bin/echo "ファイルのダウンロードに失敗しました"
		exit 1
	fi
fi
/bin/echo "ダウンロードしたZIPファイル　$USER_TEMP_DIR/utf_all.zip"
##################################################
###解凍
/usr/bin/cd "$STR_DATA_DIR_PATH"
/usr/bin/bsdtar -xzvf "$USER_TEMP_DIR/utf_all.zip" -C "$STR_DATA_DIR_PATH"
/bin/echo "ダウンロードデータ解凍OK"
##################################################
###クオテーション除去
STR_TMP_FILE_PATH="$USER_TEMP_DIR/$STR_CSV_FILE_NAME.tmp.csv"
/usr/bin/sed 's/"//g' "$STR_CSV_FILE_PATH" > "$STR_TMP_FILE_PATH"
###改行変更
/usr/bin/sed 's/\r$//' "$STR_TMP_FILE_PATH" > "$STR_IMPORT_FILE_PATH"
/bin/echo "データ整形終了"
##################################################
###１行目挿入 この処理は不要だった
##  STR_HEADER_TEXT="code,old_no,p_no,prefecture_kana,city_kana,town_kana,prefecture,city,town,more,aza,cho,contain,update,change"
##  /usr/bin/touch "$STR_IMPORT_FILE_PATH"
##  /bin/echo  "$STR_HEADER_TEXT" > "$STR_IMPORT_FILE_PATH"
##  /bin/cat "$STR_TMPB_FILE_PATH" >> "$STR_IMPORT_FILE_PATH"
##################################################
/bin/echo "データインポート開始"
###インポート DB作成
/usr/bin/sqlite3 "$STR_DB_FILE_PATH" <<EOF
CREATE TABLE postalcode (code TEXT,old_no TEXT,p_no TEXT,prefecture_kana TEXT,city_kana TEXT,town_kana TEXT,prefecture TEXT,city TEXT,town TEXT,more INTEGER,azamore INTEGER,chomore INTEGER,containmore INTEGER,updatemore INTEGER,changemore INTEGER);
.mode csv
.import "$STR_IMPORT_FILE_PATH" postalcode
EOF
/bin/echo "データインポート終了"
sleep 2
/bin/echo "都道府県＋地区町村作成開始"
/usr/bin/sqlite3 "$STR_DB_FILE_PATH" <<EOF
ALTER TABLE postalcode ADD COLUMN pref_and_city TEXT;
EOF
/bin/echo "都道府県＋地区町村作成開始　OK"

/bin/echo "都道府県＋地区町村　データ結合開始"
/usr/bin/sqlite3 "$STR_DB_FILE_PATH" <<EOF
UPDATE postalcode SET pref_and_city = prefecture || city;
EOF
/bin/echo "都道府県＋地区町村　データ結合開始 ok"


/bin/echo "処理終了しました"
exit 0
