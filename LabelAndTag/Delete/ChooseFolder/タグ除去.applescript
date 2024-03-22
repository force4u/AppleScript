#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# フォルダ内のコンテンツを収集して内包されている項目全部処理する
#	NSURLTagNamesKeyに空のArrayをセットでも良かったが
#	後日特定のタグだけ削除とかに使いたいので個別で処理する方式にした
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


##############################
### Wクリックで起動時
on run
	###ドロップレットWクリック時にはファイル選択ダイアログを出す
	set strName to (name of current application) as text
	if strName is "osascript" then
		tell application "Finder" to activate
	else if strName is (name of me as text) then
		set strName to (name of me) as text
		tell application strName to activate
	else
		tell current application to activate
	end if
	###デフォルトロケーションはデスクトップ
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
	set aliasDesktopDirPath to (ocidDesktopDirPathURL's absoluteURL()) as alias
	set strMes to "選んでください"
	set listDropOpenPath to (choose folder strMes default location aliasDesktopDirPath with prompt strMes with multiple selections allowed and showing package contents without invisibles) as list
	open listDropOpenPath
end run

##################################
###本処理
##################################
on open listDropOpenPath
	#ファイル　ディレクトリの全てのパスの格納用
	set ocidFilePathURLArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
	#ドロップの数だけ繰り返し
	repeat with itemDropPath in listDropOpenPath
		###ドップパス
		set appFileManager to refMe's NSFileManager's defaultManager()
		set strDropPath to (POSIX path of itemDropPath) as text
		set ocidDropPathStr to (refMe's NSString's stringWithString:(strDropPath))
		set ocidDropPath to ocidDropPathStr's stringByStandardizingPath()
		set ocidDropPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDropPath))
		###ドロップされたのが?
		set listResults to (ocidDropPathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		if (item 2 of listResults) = (refMe's NSNumber's numberWithBool:true) then
			log "このURLはフォルダです"
			##取得するプロパティ
			set ocidProperties to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
			(ocidProperties's addObject:(refMe's NSURLPathKey))
			#	(ocidProperties's addObject:(refMe's NSURLIsRegularFileKey))
			#	(ocidProperties's addObject:(refMe's NSURLContentTypeKey))
			##オプション(隠しファイルは含まない)
			set ocidOption to refMe's NSDirectoryEnumerationSkipsHiddenFiles
			##コンテンツの収集
			set ocidEmuDict to (appFileManager's enumeratorAtURL:(ocidDropPathURL) includingPropertiesForKeys:(ocidProperties) options:(ocidOption) errorHandler:(reference))
			set ocidFilePathURLArray to ocidEmuDict's allObjects()
			#フォルダ自身も追加しておく
			(ocidFilePathURLArray's addObject:(itemDropPath))
		else
			log "このURLはファイルです"
			(ocidFilePathURLArray's addObject:(itemDropPath))
		end if
	end repeat
	
	###不要なんだが念のためパスをURL順に並び替え
	set ocidSortDescriptor to (refMe's NSSortDescriptor's sortDescriptorWithKey:"absoluteString" ascending:(true) selector:"localizedStandardCompare:")
	(ocidFilePathURLArray's sortUsingDescriptors:{ocidSortDescriptor})
	
	repeat with itemFilePathURL in ocidFilePathURLArray
		##設定されているタグの名前を取得して
		set listResult to (itemFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
		set ocidTagArray to (item 2 of listResult)
		if ocidTagArray = (missing value) then
			log "タグは設定されていません"
		else
			#取得したタグの数だけくりかえし
			repeat with itemTag in ocidTagArray
				#タグを削除して
				(ocidTagArray's removeObject:(itemTag))
			end repeat
			#削除したタグArrayを戻す
			set listDone to (itemFilePathURL's setResourceValue:(ocidTagArray) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
			if (item 1 of listDone) = true then
				log "タグを削除しました"
			else
				log itemFilePathURL's |path| as text
				log "タグの削除に失敗しました"
			end if
		end if
	end repeat
	
end open
