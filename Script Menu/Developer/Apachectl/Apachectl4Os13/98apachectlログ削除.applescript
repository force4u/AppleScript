#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


set strCommandText to "sudo /usr/sbin/apachectl stop"
do shell script strCommandText with administrator privileges



set strCommandText to "/usr/bin/sudo /bin/mkdir -pm 775 /private/var/log/apache2"
do shell script strCommandText with administrator privileges

set strCommandText to "/usr/bin/sudo /bin/rm /private/var/log/apache2/error_log"
do shell script strCommandText with administrator privileges

set strCommandText to "/usr/bin/sudo /bin/rm /private/var/log/apache2/access_log"
do shell script strCommandText with administrator privileges

set strCommandText to "/usr/bin/sudo /bin/rm /private/var/log/apache2/combined_log"
do shell script strCommandText with administrator privileges

set strCommandText to "/usr/bin/sudo /usr/bin/touch  /private/var/log/apache2/error_log"
do shell script strCommandText with administrator privileges

set strCommandText to "/usr/bin/sudo /usr/bin/touch  /private/var/log/apache2/access_log"
do shell script strCommandText with administrator privileges

set strCommandText to "/usr/bin/sudo /usr/bin/touch /private/var/log/apache2/combined_log"
do shell script strCommandText with administrator privileges


set strCommandText to "sudo chown -Rf _www  /private/var/log/apache2"
do shell script strCommandText with administrator privileges

set strCommandText to "sudo chmod 666 /private/var/log/apache2/error_log"
do shell script strCommandText with administrator privileges

set strCommandText to "sudo chmod 666  /private/var/log/apache2/access_log"
do shell script strCommandText with administrator privileges

set strCommandText to "sudo chmod 666  /private/var/log/apache2/combined_log"
do shell script strCommandText with administrator privileges



set strCommandText to "sudo /usr/sbin/apachectl graceful"
do shell script strCommandText with administrator privileges

