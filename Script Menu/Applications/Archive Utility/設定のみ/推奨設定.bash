#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#####################################

STR_UTI="com.apple.archiveutility"

"/usr/bin/defaults" write "$STR_UTI" dearchive-into -string "."

"/usr/bin/defaults" write "$STR_UTI"  archive-info -string "."

"/usr/bin/defaults" write "$STR_UTI"  dearchive-move-after -string "~/.Trash"

"/usr/bin/defaults" write "$STR_UTI"  archive-move-after -string "."

"/usr/bin/defaults" write "$STR_UTI" archive-format -string "zip"

"/usr/bin/defaults" write "$STR_UTI"  dearchive-recursively -boolean true

"/usr/bin/defaults" write "$STR_UTI"  archive-reveal-after -boolean true

"/usr/bin/defaults" write "$STR_UTI"  dearchive-reveal-after -boolean true

sleep 1

"/usr/bin/killall" cfprefsd

/bin/echo "Done"
exit 0
