#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#	com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set listUTI to {"com.wacom.TabletDriver", "com.wacom.DataStoreMgr", "com.wacom.FirmwareUpdater", "com.wacom.IOManager", "com.wacom.MultiTouch", "com.wacom.ProfessionalControlPanel", "com.wacom.RemoveTabletHelper", "com.wacom.RemoveWacomTablet", "com.wacom.TabletDriver", "com.wacom.TabletHelper", "com.wacom.UpdateHelper", "com.wacom.UpgradeHelper", "com.wacom.Wacom-Desktop-Center", "com.wacom.Wacom-Display-Settings", "com.wacom.WacomCenter", "com.wacom.WacomCenterPrefPane", "com.wacom.WacomExperienceProgram", "com.wacom.WacomTabletDriver", "com.wacom.WacomTouchDriver", "com.wacom.displayhelper", "com.wacom.wacomtablet", "com.wacom.DisplayMgr"} as text

repeat with itemUTI in listUTI
	###NSRunningApplication
	set ocidRunningApplication to refMe's NSRunningApplication
	###起動中のすべてのリスト
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(itemUTI))
	###複数起動時も順番に終了
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate()
	end repeat
end repeat
log "通常終了"
delay 3

repeat with itemUTI in listUTI
	###NSRunningApplication
	set ocidRunningApplication to refMe's NSRunningApplication
	###起動中のすべてのリスト
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(itemUTI))
	###複数起動時も順番に終了
	repeat with itemAppArray in ocidAppArray
		itemAppArray's forceTerminate()
	end repeat
end repeat

log "強制終了"


