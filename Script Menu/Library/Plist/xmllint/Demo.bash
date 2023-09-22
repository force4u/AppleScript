#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
####################################
STR_PLIST_PATH="$HOME/Library/Preferences/com.apple.archiveutility.plist"
###表示
/usr/bin/xmllint --format "$STR_PLIST_PATH"
##表示
/usr/bin/xmllint --xpath 'string(//dict)'  "$STR_PLIST_PATH"
/usr/bin/xmllint --xpath 'string(//dict/key)'  "$STR_PLIST_PATH"
/usr/bin/xmllint --xpath 'string(//dict/string)' "$STR_PLIST_PATH"


exit 0
