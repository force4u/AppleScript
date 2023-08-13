#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

###################################
########まずは処理するアプリケーションを終了させる
###################################
doQuitApp2UTI("com.adobe.Reader")
doQuitApp2UTI("com.adobe.Acrobat.Pro")
doQuitApp2UTI("com.adobe.distiller")


###################################
########	Application Supportフォルダー
###################################
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/SaveAsAdobePDF DC/FontCache")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/Preflight Acrobat Continuous/FontCache")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/Distiller DC/FontCache")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/Distiller DC/Messages.log")
log doMoveToTrash("~/Library/Application Support/Adobe/com.adobe.ARMDCHelper/download")
#########DC
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/AdobeCMapFnt22.lst")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/AdobeSysFnt22.lst")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/AdobeComFnt22.lst")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/ProtectedView¥AdobeSysFnt22.lst")
###
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/AdobeCMapFnt23.lst")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/AdobeSysFnt23.lst")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/AdobeComFnt23.lst")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/ProtectedView¥AdobeSysFnt23.lst")

###
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/DCAPIDiscoveryCacheAcrobat")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/DCAPIDiscoveryCacheReader")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/Exchange-ProMessages")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/BHCache")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/JSCache")
log doMoveToTrash("~Library/Application Support/Adobe/Acrobat/DC/ThumbCache")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/ToolsSearchCacheRdr")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/ToolsSearchCacheAcro")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/ProtectedView")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/ConnectorIcons")

log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/UserCache64.bin")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/IconCacheAcro65536.dat")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/IconCacheRdr65536.dat")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/SOPHIA/Acrobat")

####リーダー用
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/Reader/Synchronizer")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/Reader/Eureka")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/DC/Reader/SOPHIA/Reader")
log doMoveToTrash("~/Library/Application Support/Adobe/Acrobat/Reader/DCThumbCache/Reader")

###
log doMoveToTrash("~/Library/Application Support/Adobe UXP Developer Tool/Cache")
log doMoveToTrash("~/Library/Application Support/Adobe UXP Developer Tool/Code Cache")
log doMoveToTrash("~/Library/Application Support/Adobe UXP Developer Tool/GPUCache")

log doMoveToTrash("~/Library/Application Support/Adobe/AcroCef/DC/Acrobat/Cache")

log doMoveToTrash("~/Library/Application Support/Adobe/PseudoFontsCache")

###################################
########キャッシュ
###################################

log doMoveToTrash("~/Library/Caches/Adobe")
log doMoveToTrash("~/Library/Caches/com.adobe.Acrobat.Pro")
log doMoveToTrash("~/Library/Caches/com.adobe.acrobat.AcroPatchInstall")
log doMoveToTrash("~/Library/Caches/com.adobe.Acrobat.Pro")
log doMoveToTrash("~/Library/Caches/com.adobe.Reader")
log doMoveToTrash("~/Library/Caches/Acrobat/DC")
log doMoveToTrash("~/Library/Caches/Acrobat/Reader")

###################################
########Group Containers
###################################
log doMoveToTrash("~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Startup.localized/Word/~$nkCreation.dotm")
log doMoveToTrash("~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Startup.localized/Excel/~$SaveAsAdobePDF.xlam")
log doMoveToTrash("~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Startup.localized/Powerpoint/~$SaveAsAdobePDF.ppam")
log doMoveToTrash("~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Add-Ins.localized/Word/~$nkCreation.dotm")
log doMoveToTrash("~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Add-Ins.localized/Excel/~$SaveAsAdobePDF.xlam")
log doMoveToTrash("~/Library/Group Containers/UBF8T346G9.Office/User Content.localized/Add-Ins.localized/Powerpoint/~$SaveAsAdobePDF.ppam")



###################################
########キャッシュNSTemporaryDirectory
###################################
### T
set ocidTempDir to (refMe's NSTemporaryDirectory())
set ocidTemporaryTPathURL to refMe's NSURL's fileURLWithPath:(ocidTempDir)
### 
set ocidTempURL to ocidTemporaryTPathURL's URLByDeletingLastPathComponent()
### C
set ocidTemporaryCPathURL to ocidTempURL's URLByAppendingPathComponent:"C"

log doMoveToTrash(ocidTemporaryCPathURL's URLByAppendingPathComponent:"com.adobe.Acrobat.Pro")
log doMoveToTrash(ocidTemporaryCPathURL's URLByAppendingPathComponent:"com.adobe.AdobeAcroCEFHelperGPU")
log doMoveToTrash(ocidTemporaryCPathURL's URLByAppendingPathComponent:"com.adobe.Reader")
log doMoveToTrash(ocidTemporaryCPathURL's URLByAppendingPathComponent:"com.adobe.AdobeRdrCEFHelperGPU")
log doMoveToTrash(ocidTemporaryCPathURL's URLByAppendingPathComponent:"com.adobe.distiller")



###################################
########処理　ゴミ箱に入れる
###################################

to doMoveToTrash(argFilePath)
	###ファイルマネジャー初期化
	set appFileManager to refMe's NSFileManager's defaultManager()
	#########################################
	###渡された値のClassを調べてとりあえずNSURLにする
	set refClass to class of argFilePath
	if refClass is list then
		return "エラー:リストは処理しません"
	else if refClass is text then
		log "テキストパスです"
		set ocidArgFilePathStr to (refMe's NSString's stringWithString:argFilePath)
		set ocidArgFilePath to ocidArgFilePathStr's stringByStandardizingPath
		set ocidArgFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidArgFilePath)
	else if refClass is alias then
		log "エイリアスパスです"
		set strArgFilePath to (POSIX path of argFilePath) as text
		set ocidArgFilePathStr to (refMe's NSString's stringWithString:strArgFilePath)
		set ocidArgFilePath to ocidArgFilePathStr's stringByStandardizingPath
		set ocidArgFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidArgFilePath)
	else
		set refClass to (className() of argFilePath) as text
		if refClass contains "NSPathStore2" then
			log "NSPathStore2です"
			set ocidArgFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:argFilePath)
		else if refClass contains "NSCFString" then
			log "NSCFStringです"
			set ocidArgFilePath to argFilePath's stringByStandardizingPath
			set ocidArgFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidArgFilePath)
		else if refClass contains "NSURL" then
			set ocidArgFilePathURL to argFilePath
			log "NSURLです"
		end if
	end if
	#########################################
	###
	-->false
	set ocidFalse to (refMe's NSNumber's numberWithBool:false)'s boolValue
	-->true
	set ocidTrue to (refMe's NSNumber's numberWithBool:true)'s boolValue
	#########################################
	###NSURLがエイリアス実在するか？
	set ocidArgFilePath to ocidArgFilePathURL's |path|()
	set boolFileAlias to appFileManager's fileExistsAtPath:(ocidArgFilePath)
	###パス先が実在しないなら処理はここまで
	if boolFileAlias = false then
		log ocidArgFilePath as text
		log "処理中止 パス先が実在しない"
		return false
	end if
	#########################################
	###NSURLがディレクトリなのか？ファイルなのか？
	set listBoolDir to ocidArgFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference)
	#		log (item 1 of listBoolDir)
	#		log (item 2 of listBoolDir)
	#		log (item 3 of listBoolDir)
	if (item 2 of listBoolDir) = ocidTrue then
		#########################################
		log "ディレクトリです"
		log ocidArgFilePathURL's |path| as text
		##内包リスト
		set listResult to appFileManager's contentsOfDirectoryAtURL:ocidArgFilePathURL includingPropertiesForKeys:{refMe's NSURLPathKey} options:0 |error|:(reference)
		###結果
		set ocidContentsPathURLArray to item 1 of listResult
		###リストの数だけ繰り返し
		repeat with itemContentsPathURL in ocidContentsPathURLArray
			###ゴミ箱に入れる
			set listResult to (appFileManager's trashItemAtURL:itemContentsPathURL resultingItemURL:(missing value) |error|:(reference))
		end repeat
	else
		#########################################
		log "ファイルです"
		set listBoolDir to ocidArgFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsAliasFileKey) |error|:(reference)
		if (item 2 of listBoolDir) = ocidTrue then
			log "エイリアスは処理しません"
			return false
		end if
		set listBoolDir to ocidArgFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsSymbolicLinkKey) |error|:(reference)
		if (item 2 of listBoolDir) = ocidTrue then
			log "シンボリックリンクは処理しません"
			return false
		end if
		set listBoolDir to ocidArgFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsSystemImmutableKey) |error|:(reference)
		if (item 2 of listBoolDir) = ocidTrue then
			log "システムファイルは処理しません"
			return false
		end if
		###ファイルをゴミ箱に入れる
		set listResult to (appFileManager's trashItemAtURL:ocidArgFilePathURL resultingItemURL:(missing value) |error|:(reference))
	end if
	return true
end doMoveToTrash

###################################
########アプリケーションを終了させる
###################################
to doQuitApp2UTI(argUTI)
	set strUTI to argUTI as text
	###　まずは普通に終了を試みる
	tell application id strUTI to quit
	delay 2
	set ocidResultsArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:strUTI
	set numCntArray to ocidResultsArray count
	if numCntArray ≠ 0 then
		set ocidRunApp to ocidResultsArray's objectAtIndex:0
		
		###通常終了
		set boolDone to ocidRunApp's terminate()
		####強制終了
		set boolDone to ocidRunApp's forceTerminate()
		
		#### killallを使う場合
		set ocidExecAppURL to ocidRunApp's executableURL()
		set ocidFileName to ocidExecAppURL's lastPathComponent()
		set strFileName to ocidFileName as text
		
		set strCommandText to ("/usr/bin/killall -z " & strFileName & "") as text
		set ocidCommandText to refMe's NSString's stringWithString:strCommandText
		set ocidTermTask to refMe's NSTask's alloc()'s init()
		ocidTermTask's setLaunchPath:"/bin/zsh"
		ocidTermTask's setArguments:({"-c", ocidCommandText})
		set listDoneReturn to ocidTermTask's launchAndReturnError:(reference)
		
		
		####killを使う場合
		set ocidPID to ocidRunApp's processIdentifier()
		set strPID to ocidPID as text
		log strPID
		set strCommandText to ("/bin/kill -9 " & strPID & "") as text
		set ocidCommandText to refMe's NSString's stringWithString:strCommandText
		set ocidTermTask to refMe's NSTask's alloc()'s init()
		ocidTermTask's setLaunchPath:"/bin/zsh"
		ocidTermTask's setArguments:({"-c", ocidCommandText})
		set listDoneReturn to ocidTermTask's launchAndReturnError:(reference)
		
		
	end if
end doQuitApp2UTI

