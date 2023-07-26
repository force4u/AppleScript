#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　各種キャッシュファイルをゴミ箱に移動します
#　削除はご自分で判断してください
#　
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

set strBundleID to "com.microsoft.edgemac"

###################################
########まずは処理するアプリケーションを終了させる
###################################
doQuitApp2UTI(strBundleID)

###################################
########	ローカルドメインエラーになるけど
###################################
log doMoveToTrash("/Library/Application Support/Microsoft/EdgeUpdater")
log doMoveToTrash("/Library/Microsoft/EdgeUpdater")


###################################
########	Application Supportフォルダー
###################################

log doMoveToTrash("~/Library/Application Support/Microsoft/EdgeUpdater")


log doMoveToTrash("~/Library/Application Support/Microsoft Edge/component_crx_cache")
log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Crashpad")
log doMoveToTrash("~/Library/Application Support/Microsoft Edge/CrashpadMetrics-active.pma")
log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Diagnostic Data")
log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Diagnostic Data-wal")
log doMoveToTrash("~/Library/Application Support/Microsoft Edge/extensions_crx_cache")
log doMoveToTrash("~/Library/Application Support/Microsoft Edge/GrShaderCache")
log doMoveToTrash("~/Library/Application Support/Microsoft Edge/SafetyTips")
log doMoveToTrash("~/Library/Application Support/Microsoft Edge/ShaderCache")
log doMoveToTrash("~/Library/Application Support/Microsoft Edge/SmartScreen")
log doMoveToTrash("~/Library/Application Support/Microsoft Edge/extensions_crx_cache")
log doMoveToTrash("~/Library/Application Support/Microsoft Edge/extensions_crx_cache")
###ゲストは丸ごと削除
log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Guest Profile")

###プロファイル内のキャッシュ
repeat with itemIntNo from 1 to 10 by 1
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/Asset Store/assets.db")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/blob_storage")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/BudgetDatabase")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/commerce_subscription_db")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/coupon_db")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/data_reduction_proxy_leveldb")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/DawnCache")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/Download Service")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/GPUCache")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/IndexedDB")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/optimization_guide_hint_cache_store")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/Platform Notifications")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/Service Worker")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/Storage")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/VideoDecodeStats")
	log doMoveToTrash("~/Library/Application Support/Microsoft Edge/Profile " & itemIntNo & "/Web Applications")
	
end repeat
###################################
########Containers
###################################
log doMoveToTrash("~/Library/Containers/com.microsoft.edgemac.wdgExtension/Data/Library/Caches")

###################################
########HTTPStorages
###################################
log doMoveToTrash("~/Library/HTTPStorages/com.microsoft.EdgeUpdater")
log doMoveToTrash("~/Library/HTTPStorages/com.microsoft.edgemac")


###################################
########LOGS
###################################
log doMoveToTrash("~/Library/Logs/Microsoft Edge")
log doMoveToTrash("~/Library/Logs/Microsoft Edge (GPU)")
log doMoveToTrash("~/Library/Logs/Microsoft Edge (Renderer)")

###################################
########EdgeUpdater
###################################
log doMoveToTrash("~/Library/Microsoft/EdgeUpdater")

###################################
########キャッシュ
###################################

log doMoveToTrash("~/Library/Caches/com.microsoft.edgemac")
log doMoveToTrash("~/Library/Caches/Microsoft Edge")


###################################
########Saved Application State
###################################
log doMoveToTrash("~/Library/Saved Application State/com.microsoft.edgemac")
log doMoveToTrash("~/Library/Saved Application State/com.microsoft.edgemac.savedState")

###################################
########WebKit
###################################

log doMoveToTrash("~/Library/WebKit/com.microsoft.edgemac")

###################################
########キャッシュNSTemporaryDirectory
###################################
### T
set ocidTempDir to (refMe's NSTemporaryDirectory())
set ocidTemporaryTPathURL to refMe's NSURL's fileURLWithPath:(ocidTempDir)
log doMoveToTrash(ocidTemporaryTPathURL's URLByAppendingPathComponent:"com.microsoft.edgemac")
log doMoveToTrash(ocidTemporaryTPathURL's URLByAppendingPathComponent:"com.microsoft.edgemac.helper")
log doMoveToTrash(ocidTemporaryTPathURL's URLByAppendingPathComponent:"com.microsoft.edgemac.helper-(GPU)")
log doMoveToTrash(ocidTemporaryTPathURL's URLByAppendingPathComponent:"com.microsoft.edgemac.helper-(Renderer)")

### 
set ocidTempURL to ocidTemporaryTPathURL's URLByDeletingLastPathComponent()
### C
set ocidTemporaryCPathURL to ocidTempURL's URLByAppendingPathComponent:"C"

log doMoveToTrash(ocidTemporaryCPathURL's URLByAppendingPathComponent:"com.microsoft.edgemac")
log doMoveToTrash(ocidTemporaryCPathURL's URLByAppendingPathComponent:"com.microsoft.edgemac.helper")
log doMoveToTrash(ocidTemporaryCPathURL's URLByAppendingPathComponent:"com.microsoft.edgemac.helper-(GPU)")
log doMoveToTrash(ocidTemporaryCPathURL's URLByAppendingPathComponent:"com.microsoft.edgemac.helper-(Renderer)")



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

