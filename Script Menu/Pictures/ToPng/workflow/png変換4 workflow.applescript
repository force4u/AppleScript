#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#オートメーターのワークフロー用
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "CoreImage"
use scripting additions

property refMe : a reference to current application

on run {input}
	repeat with itemAliasFilePath in input
		###入力パス
		set strFilePath to POSIX path of itemAliasFilePath
		set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false)
		#####拡張子を取って
		set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
		######新しい拡張子を加える
		set ocidSaveFilePathURL to (ocidFilePathURL's URLByAppendingPathExtension:"png")
		
		###イメージデータ展開
		set ocidImageRep to (refMe's NSBitmapImageRep's imageRepWithContentsOfURL:(ocidFilePathURL))
		####NSImageColorSyncProfileData
		set ocidColorSpace to refMe's NSColorSpace's displayP3ColorSpace()
		set ocidColorSpaceData to ocidColorSpace's colorSyncProfile()
		####NSImageEXIFData
		set ocidEXIFData to (ocidImageRep's valueForProperty:(refMe's NSImageEXIFData))
		
		####ガンマ値換算 まぁ2.2入れておけば間違い無いか…しらんけど
		set numGamma to (1 / 2.2) as number
		####propertiesデータレコード整形(PNG用)
		set ocidImageProperties to {NSImageGamma:(numGamma), NSImageEXIFData:(ocidEXIFData), NSImageInterlaced:false, NSImageColorSyncProfileData:(ocidColorSpaceData)} as record
		
		#####PNGデータに変換
		set ocidSaveData to (ocidImageRep's representationUsingType:(refMe's NSBitmapImageFileTypePNG) |properties|:(ocidImageProperties))
		
		set ocidWroteToFileDone to (ocidSaveData's writeToURL:ocidSaveFilePathURL options:0 |error|:(reference))
		
		set ocidSaveData to ""
		set ocidImageRep to ""
		
	end repeat
end run
