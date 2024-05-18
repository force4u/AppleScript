#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#
SCRIPT_PATH="${BASH_SOURCE[0]}"
/bin/echo "実行ファイル \"$SCRIPT_PATH\""
STR_DATE=$(/bin/date +"%Y%m%d_%H%M%S")
STAT_USR=$(/usr/bin/stat -f%Su /dev/console)
/bin/echo "STAT_USR(console): $STAT_USR"
########################################
##保存先
STR_MKDIR_PATH="/Users/${STAT_USR}/Library/Logs/Apple/BluetoothReporter"
/bin/mkdir -p "$STR_MKDIR_PATH"
/usr/sbin/chown "$STAT_USR" "$STR_MKDIR_PATH"
/bin/chmod 700 "$STR_MKDIR_PATH"
##実行
/usr/bin/sudo /System/Library/Frameworks/IOBluetooth.framework/Resources/BluetoothReporter --dumpPacketLog "${STR_MKDIR_PATH}/${STR_DATE}_BluetoothReporter.pklg"
##開く
open -b com.apple.PacketLogger "${STR_MKDIR_PATH}/${STR_DATE}_BluetoothReporter.pklg"

exit 0
