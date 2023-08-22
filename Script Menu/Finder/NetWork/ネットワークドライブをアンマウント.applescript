#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
############################
#######ディスクの情報を取得する
############################

set appFileManager to refMe's NSFileManager's defaultManager()
set ocidResourceKeyArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidResourceKeyArray's addObject:(refMe's NSURLVolumeIsInternalKey)
ocidResourceKeyArray's addObject:(refMe's NSURLVolumeIsLocalKey)
ocidResourceKeyArray's addObject:(refMe's NSURLVolumeNameKey)
ocidResourceKeyArray's addObject:(refMe's NSURLPathKey)

set ocidEnuOption to refMe's NSVolumeEnumerationSkipHiddenVolumes
set listDisk to appFileManager's mountedVolumeURLsIncludingResourceValuesForKeys:ocidResourceKeyArray options:ocidEnuOption

############################
#######ディスクの数だけ繰り返し
############################

repeat with itemDisk in listDisk
	log itemDisk as alias
	set itemURLKeyArray to (itemDisk's getResourceValue:(reference) forKey:(refMe's NSURLVolumeIsInternalKey) |error|:(reference))
	if (item 2 of itemURLKeyArray) = (missing value) then
		set itemURLKeyArray to (itemDisk's getResourceValue:(reference) forKey:(refMe's NSURLVolumeIsLocalKey) |error|:(reference))
		if (item 2 of itemURLKeyArray) = (refMe's NSNumber's numberWithBool:false) then
			#### 物理ドライブでは無くて　＋ 内部ドライブか不明 =　ネットワークドライブを開いた物
			####パスを取得して
			set itemURLKeyArray to (itemDisk's getResourceValue:(reference) forKey:(refMe's NSURLPathKey) |error|:(reference))
			set ocidDiskPath to (item 2 of itemURLKeyArray)
			set ocidFilePath to ocidDiskPath's stringByExpandingTildeInPath()
			####URLに
			set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false)
			######アンマウントする
			set appNSWorkspace to refMe's NSWorkspace's sharedWorkspace()
			(appNSWorkspace's unmountAndEjectDeviceAtURL:ocidFilePathURL |error|:(reference))
		end if
	end if
	
end repeat


