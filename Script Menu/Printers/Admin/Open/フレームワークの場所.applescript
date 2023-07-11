#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# プリンタ関連のディレクトリを開くだけ
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


set aliasDir to POSIX file "/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Versions/A/Resources" as alias
tell application "Finder"
	activate
	make new Finder window to aliasDir
	select file "GenericPostscriptPrinter.icns" of aliasDir
end tell



set aliasDir to POSIX file "/System/Library/PrivateFrameworks/PrintingPrivate.framework/Versions/A/Plugins" as alias
tell application "Finder"
	activate
	###make new Finder window to aliasDir
	set thepath to (reveal aliasDir)
end tell

