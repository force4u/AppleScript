#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

set strBundleID to "cx.c3.theunarchiver" as text



#####ダイアログを前面に
tell current application
  set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
  tell application "Finder" to activate
else
  tell current application to activate
end if
tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
set listUTI to {"com.pkware.zip-archive", "public.zip-archive", "public.zip-archive.first-part", "com.rarlab.rar-archive", "org.7-zip.7-zip-archive", "cx.c3.lha-archive", "com.winzip.zipx-archive", "com.allume.stuffit-archive", "com.stuffit.archive.sit", "com.stuffit.archive.sitx", "com.apple.binhex-archive", "com.apple.macbinary-archive", "com.apple.applesingle-archive", "org.gnu.gnu-zip-archive", "org.gnu.gnu-zip-tar-archive", "public.bzip2-archive", "org.bzip.bzip2-archive", "public.tar-bzip2-archive", "org.bzip.bzip2-tar-archive", "org.tukaani.xz-archive", "public.xz-archive", "org.tukaani.xz-tar-archive", "public.tar-xz-archive", "public.tar-archive", "public.iso-image", "com.padus.cdi-image", "com.nero.nrg-image", "com.alcohol-soft.mdf-image", "org.gnu.gnu-tar-archive", "public.z-archive", "cx.c3.compress-tar-archive", "org.tukaani.lzma-archive", "public.lzma-archive", "com.apple.xar-archive", "public.xar-archive", "com.apple.xip-archive", "com.winace.ace-archive", "cx.c3.arj-archive", "cx.c3.arc-archive", "cx.c3.zoo-archive", "cx.c3.lbr-archive", "cx.c3.pma-archive", "com.microsoft.cab-archive", "com.redhat.rpm-archive", "com.real.realmedia", "org.debian.deb-archive", "com.altools.alz-archive", "com.symantec.dd-archive", "com.cyclos.cpt-archive", "com.network172.pit-archive", "com.nowsoftware.now-archive", "com.apple.self-extracting-archive", "com.microsoft.windows-executable", "com.microsoft.msi-installer", "public.cpio-archive", "com.apple.bom-compressed-cpio", "cx.c3.pax-archive", "public.pax-archive", "org.archive.warc-archive", "cx.c3.ha-archive", "com.amiga.adf-archive", "com.amiga.adz-archive", "cx.c3.dms-archive", "cx.c3.lhf-archive", "cx.c3.lzx-archive", "cx.c3.dcs-archive", "cx.c3.packdev-archive", "cx.c3.xmash-archive", "cx.c3.zoom-archive", "cx.c3.pp-archive", "com.nscripter.nsa-archive", "com.nscripter.sar"} as list
set listFilePath to (choose file with prompt "ファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with multiple selections allowed without invisibles and showing package contents) as list

###ファイルの数だけ繰返し
repeat with itemFilePath in listFilePath
	set aliasFilePath to itemFilePath as alias
	tell application id strBundleID to open file aliasFilePath
end repeat


return
