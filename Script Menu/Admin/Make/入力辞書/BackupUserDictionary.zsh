
#!/bin/zsh
#com.cocolog-nifty.quicktimer.icefloe
########################################
###
CONSOLE_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }')
/bin/echo "コンソールユーザー(scutil):$CONSOLE_USER"

########################################
###保存先
STR_SAVE_DIR="/Users/$CONSOLE_USER/Documents/Apple/system_profiler"
/bin/mkdir -p "$STR_SAVE_DIR"
###デバイスUUIDを取得する
STR_DEVICE_UUID=$(/usr/sbin/system_profiler SPHardwareDataType -json > "$STR_SAVE_DIR/SPHardwareDataType.json")
/usr/bin/plutil -convert xml1  "$STR_SAVE_DIR/SPHardwareDataType.json" -o "$STR_SAVE_DIR/SPHardwareDataType.plist" 
STR_DEVICE_UUID=$(/usr/libexec/PlistBuddy -c "Print :SPHardwareDataType:0:platform_UUID:" "$STR_SAVE_DIR/SPHardwareDataType.plist" )
/bin/echo "デバイスUUID：" "$STR_DEVICE_UUID"

########################################
###
STR_SAVE_DIR="/Users/$CONSOLE_USER/Documents/Apple/UserDictionary"
/bin/mkdir -p "$STR_SAVE_DIR"
STR_SAVE_PLIST_PATH="$STR_SAVE_DIR/UserDictionary.db"
/bin/echo "STR_SAVE_PLIST_PATH: $STR_SAVE_PLIST_PATH"
########################################
###読み取り元
STR_SUPPORT_DIR_NAME="/Users/$CONSOLE_USER/Library/Dictionaries/CoreDataUbiquitySupport/"$CONSOLE_USER"~"$STR_DEVICE_UUID"/UserDictionary/"
STR_DB_DIR_PATH=$(/bin/ls "$STR_SUPPORT_DIR_NAME")
/bin/echo "DBID: $STR_DB_DIR_PATH"
STR_READ_DB_PATH="$STR_SUPPORT_DIR_NAME$STR_DB_DIR_PATH"
STR_DB_FILEPATH="$STR_READ_DB_PATH/store/UserDictionary.db"
/bin/echo "STR_DB_FILEPATH: $STR_DB_FILEPATH"
########################################
###	PLISTに書き出しは使えなくなった‥
##	/usr/bin/sqlite3  "$STR_DB_FILEPATH" "select * from Z_MODELCACHE;" >> "$STR_SAVE_PLIST_PATH"
/usr/bin/ditto  "$STR_DB_FILEPATH" "$STR_SAVE_PLIST_PATH"
