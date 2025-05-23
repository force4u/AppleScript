#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#システム設定オープン用のスクリプト作成補助 
#	アンカーのないタイプのパネルに対応した
#	作成されるスクリプトにウィンドウの最小化を解除する手順を入れた
# v5 macOS14でreveal anchor の位置がずれるのに対応した
# v6 英語で利用中でも取得できるようにした
# v7 ユーザーインストールのパネルも取得できるようにした
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set strBundleID to "com.apple.systempreferences" as text

############################
###【１】システム設定の起動を確定させる
set ocidRunAppArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
if (count of ocidRunAppArray) ≠ 0 then
	log "起動中です"
	tell application id strBundleID to activate
else
	####ゾンビ対策終了させてから処理させる
	tell application id strBundleID
		set numCntWindow to (count of every window) as integer
	end tell
	if numCntWindow = 0 then
		tell application id strBundleID to quit
	else
		tell application id strBundleID
			close (every window)
			quit
		end tell
	end if
	####半ゾンビ化対策	
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate
	end repeat
	###システム設定を起動させる
	try
		tell application id strBundleID to activate
	on error
		tell application "System Settings" to activate
	end try
	###起動待ち
	tell application id strBundleID
		###起動確認　最大１０秒
		repeat 10 times
			activate
			set boolFrontMost to frontmost as boolean
			log boolFrontMost
			if boolFrontMost is true then
				###魔法の１秒
				delay 0.5
				exit repeat
			else
				delay 0.5
			end if
		end repeat
	end tell
end if
delay 3
############################
###【２】全てのパネルのIDを取得
tell application id "com.apple.systempreferences"
	set listPanelID to (id of every pane) as list
end tell
############################
#言語モードを取得
set ocidUserDefaultDict to refMe's NSUserDefaults's standardUserDefaults()
set ocidLangArray to ocidUserDefaultDict's objectForKey:("AppleLanguages")
set ocidPrimaryLang to ocidLangArray's firstObject()
set boolEn to (ocidPrimaryLang's containsString:("en")) as boolean

############################
###【A】正順レコード
set ocidPaneDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
###【B】逆順レコード
set ocidReversePaneDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
###【３】１で取得したリストの数だけ繰り返し
repeat with itemPanelID in listPanelID
	set strPanelID to itemPanelID as text
	tell application "System Settings"
		if strPanelID is "com.apple.systempreferences.GeneralSettings" then
			if boolEn is false then
				set strPanelName to ("一般") as text
			else if boolEn is true then
				set strPanelName to ("General") as text
			end if
		else
			set strPanelName to (name of pane id strPanelID) as text
		end if
	end tell
	###【A】正順レコード
	set ocidItemDict to (refMe's NSDictionary's dictionaryWithObject:(strPanelName) forKey:(strPanelID))
	(ocidPaneDict's addEntriesFromDictionary:(ocidItemDict))
	###【B】逆順レコード
	set ocidItemDict to (refMe's NSDictionary's dictionaryWithObject:(strPanelID) forKey:(strPanelName))
	(ocidReversePaneDict's addEntriesFromDictionary:(ocidItemDict))
end repeat

############################
###【４】ダイアログ用に正順レコードのLISTを作る
set ocidAllValueArray to ocidPaneDict's allValues()
##ソートしておく
set ocidDescriptor to refMe's NSSortDescriptor's sortDescriptorWithKey:("self") ascending:(true) selector:("localizedStandardCompare:")
set ocidDescriptorArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
ocidDescriptorArray's addObject:(ocidDescriptor)
set ocidSortedKey to (ocidAllValueArray's sortedArrayUsingDescriptors:(ocidDescriptorArray))
set listAllValueArray to ocidSortedKey as list
############################
###【５】ダイアログ　　パネル
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listAllValueArray with title "選んでください" with prompt "選択したパネルを開きます" default items (item 1 of listAllValueArray) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
else
	set strResponse to (item 1 of listResponse) as text
end if
log strResponse
############################
###【６】戻り値を逆順リストで検索してパネルIDを取得
set ocidPaneID to ocidReversePaneDict's valueForKey:(strResponse)
set strPaneID to ocidPaneID as text
log strPaneID

############################
###【７】アンカーの値の取得
tell application "System Settings"
	set listPaneAnchor to (name of anchors of pane strResponse) as list
	log listPaneAnchor
end tell
###【７−１】一般選択時のみアンカーが無い
#日本語　一般
if strResponse is "一般" then
	set listPaneAnchor to {"Main"} as list
	#英語　General
else if strResponse is "General" then
	set listPaneAnchor to {"Main"} as list
	#それ以外で　アンカーが無い場合
else if listPaneAnchor is {} then
	set listPaneAnchor to {""} as list
	set strFilePath to (missing value)
	#パネルの名前からIDを取得
	tell application id "com.apple.systempreferences"
		tell pane strResponse
			set strPaneID to id as text
		end tell
	end tell
	
	#コンテンツの収集の準備
	set ocidOption to (refMe's NSDirectoryEnumerationSkipsSubdirectoryDescendants as integer) + (refMe's NSDirectoryEnumerationSkipsHiddenFiles as integer)
	set ocidPropertieArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
	ocidPropertieArray's addObject:(refMe's NSURLPathKey)
	ocidPropertieArray's addObject:(refMe's NSURLNameKey)
	#ローカルドメインのPreferencePanes
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPreferencePanesDirectory) inDomains:(refMe's NSLocalDomainMask))
	set ocidLocalDirPathURL to ocidURLsArray's firstObject()
	#収集
	set listResponse to appFileManager's contentsOfDirectoryAtURL:(ocidLocalDirPathURL) includingPropertiesForKeys:(ocidPropertieArray) options:(ocidOption) |error|:(reference)
	set ocidFilePathURLArray to (item 1 of listResponse)
	#ユーザードメインのPreferencePanes
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPreferencePanesDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidUserDirPathURL to ocidURLsArray's firstObject()
	#収集
	set listResponse to appFileManager's contentsOfDirectoryAtURL:(ocidUserDirPathURL) includingPropertiesForKeys:(ocidPropertieArray) options:(ocidOption) |error|:(reference)
	set ocidUserURLArray to (item 1 of listResponse)
	ocidFilePathURLArray's addObjectsFromArray:(ocidUserURLArray)
	#収集したURLを調べる
	repeat with itemFilePathURL in ocidFilePathURLArray
		set ocidPlistFilePathURL to (itemFilePathURL's URLByAppendingPathComponent:("Contents/Info.plist"))
		set listResponse to (refMe's NSDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL) |error|:(reference))
		set ocidPlistData to (item 1 of listResponse)
		set strGetBundleID to (ocidPlistData's valueForKey:("CFBundleIdentifier")) as text
		if strGetBundleID is strPaneID then
			set ocidPaneURL to itemFilePathURL
			set strFilePath to (itemFilePathURL's |path|()) as text
			exit repeat
		end if
	end repeat
end if


############################
###【８】ダイアログ　アンカー
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listPaneAnchor with title "選んでください" with prompt "選択したアンカーを開きます" default items (item 1 of listPaneAnchor) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
else
	set strPaneAnchor to (item 1 of listResponse) as text
end if
log strPaneAnchor


############################
###【９】URLにする
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
###スキーム
ocidURLComponents's setScheme:("x-apple.systempreferences")
###パネルIDをパスにセット
ocidURLComponents's setPath:(ocidPaneID)
###アンカーをクエリーとして追加
ocidURLComponents's setQuery:(strPaneAnchor)
set ocidOpenAppURL to ocidURLComponents's |URL|
set strOpenAppURL to ocidOpenAppURL's absoluteString() as text
log strOpenAppURL

############################
###【１０】ワークスペースで開く
###ファイルURLとパネルのURLをArrayにしておく
set ocidOpenUrlArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidOpenUrlArray's insertObject:(ocidOpenAppURL) atIndex:0
###FinderでURLを開くのでFinderのURLを用意
set strBundleID to "com.apple.finder" as text
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidAppPathURL to appShardWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
###NSWorkspaceで開く
set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration()
ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true)
ocidOpenConfig's setAllowsRunningApplicationSubstitution:(refMe's NSNumber's numberWithBool:true)
appShardWorkspace's openURLs:(ocidOpenUrlArray) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)

####システム設定が前面に来るまで待つ
repeat 20 times
	set boolFrontMost to frontmost of application id "com.apple.systempreferences"
	if boolFrontMost is false then
		tell application id "com.apple.systempreferences" to activate
	else
		exit repeat
	end if
	delay 0.2
end repeat


#################################
###【１１】ダイアログ用に値を用意
if listPaneAnchor is {""} then
	set strScript to ("#!/usr/bin/env osascript\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\n#\n# com.cocolog-nifty.quicktimer.icefloe\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\nuse AppleScript version \"2.8\"\nuse framework \"Foundation\"\nuse framework \"AppKit\"\nuse scripting additions\n\nproperty refMe : a reference to current application\ntell application id \"com.apple.systempreferences\" to activate\ndelay 2\nset strFilePath to (\"" & strFilePath & "\") as text\nset ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)\nset ocidFilePath to ocidFilePathStr's stringByStandardizingPath()\nset ocidSystemPreferencesURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)\n##\nset ocidWorkspace to refMe's NSWorkspace's sharedWorkspace()\nset boolDone to ocidWorkspace's openURL:(ocidSystemPreferencesURL)\nif boolDone is false then\n\tset aliasFilePath to (POSIX file strFilePath) as alias\n\ttell application \"Finder\"\n\t\topen location aliasFilePath\n\tend tell\nend if\n\ntell application id \"com.apple.systempreferences\"\n\tactivate\n\tset miniaturized of the settings window to false\nend tell\ntell application id \"com.apple.finder\"\n\topen location \"x-apple.systempreferences:" & strPaneID & "\"\nend tell\n\ntell application id \"com.apple.systempreferences\"\n\ttell pane id \"" & strPaneID & "\"\n\t\treveal\n\tend tell\nend tell\n\ntell application id \"com.apple.systempreferences\" to activate\n\n\nreturn") as text
else
	set strScript to ("#!/usr/bin/env osascript\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\n#com.cocolog-nifty.quicktimer.icefloe\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\nuse AppleScript version \"2.8\"\nuse framework \"Foundation\"\nuse framework \"AppKit\"\nuse framework \"UniformTypeIdentifiers\"\nuse scripting additions\nproperty refMe : a reference to current application\nset strBundleID to (\"com.apple.systempreferences\") as text\n###URLにする\nset ocidURLComponents to refMe's NSURLComponents's alloc()'s init()\n###スキーム\nocidURLComponents's setScheme:(\"x-apple.systempreferences\")\n###パネルIDをパスにセット\nocidURLComponents's setPath:(\"" & strPaneID & "\")\n###アンカーをクエリーとして追加\nocidURLComponents's setQuery:(\"" & strPaneAnchor & "\")\nset ocidOpenAppURL to ocidURLComponents's |URL|\nset strOpenAppURL to ocidOpenAppURL's absoluteString() as text\n###ワークスペースで開く\nset appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()\nset boolDone to appShardWorkspace's openURL:(ocidOpenAppURL)\nlog boolDone\nif boolDone is false then\ntell application id \"com.apple.systempreferences\"\nactivate\nset miniaturized of the settings window to false\nend tell\ntell application id \"com.apple.finder\"\nopen location \"" & strOpenAppURL & "\"\nend tell\ntell application id \"com.apple.systempreferences\"\nreveal anchor \"" & strPaneAnchor & "\" of pane id \"" & strPaneID & "\"\nend tell\ntell application id \"com.apple.systempreferences\" to activate\nend if\nreturn\n") as text
end if
#################################
###【１２】戻り値ダイアログ
set strName to (name of current application) as text
log strName
if strName is "osascript" then
	repeat 20 times
		set boolFrontMost to frontmost of application "Finder"
		if boolFrontMost is false then
			tell application "Finder" to activate
		else
			exit repeat
		end if
		delay 0.2
	end repeat
else
	repeat 5 times
		set boolFrontMost to frontmost of application "Script Editor"
		log boolFrontMost
		if boolFrontMost is false then
			tell current application to activate
		else
			exit repeat
		end if
		delay 0.2
	end repeat
	
end if
###ダイアログ
set strIconPath to "/System/Library/CoreServices/ManagedClient.app/Contents/PlugIns/ConfigurationProfilesUI.bundle/Contents/Resources/SystemPrefApp.icns"
set aliasIconPath to POSIX file strIconPath as alias
set recordResult to (display dialog "スクリプト戻り値です" with title "【３】スクリプト" default answer strScript buttons {"クリップボードにコピー", "キャンセル", "スクリプトエディタで開く"} default button "スクリプトエディタで開く" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)
#################################
###【１３】クリップボードにコピー
if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if
#################################
###【１４】OK押したらスクリプト生成
if button returned of recordResult is "スクリプトエディタで開く" then
	##ファイル名
	set strFileName to (strResponse & "." & (ocidPaneID as text) & "." & strPaneAnchor & ".applescript") as text
	##保存先はスクリプトメニュー
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidLibraryDIrURL to ocidURLsArray's firstObject()
	set ocidScriptDirPathURL to ocidLibraryDIrURL's URLByAppendingPathComponent:("Scripts/Applications/System Settings/Open")
	###フォルダを作って
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidScriptDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	#非互換文字の置換
	set strSaveFileName to doFileName4Mac(strFileName)
	set ocidSaveFilePathURL to ocidScriptDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
	###スクリプトをテキストで保存
	set ocidScript to refMe's NSString's stringWithString:(strScript)
	##改行はLFで
	set ocidLFScript to ocidScript's stringByReplacingOccurrencesOfString:("\r") withString:("\n")
	#	set ocidEnc to (refMe's NSUTF16LittleEndianStringEncoding)
	#	ターミナルからの実行を配慮してUTF8に
	set ocidEnc to (refMe's NSUTF8StringEncoding)
	set listDone to ocidLFScript's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(ocidEnc) |error|:(reference)
	delay 0.5
	set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
	###ターミナルから実行できるように755に
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listDone to appFileManager's setAttributes:(ocidAttrDict) ofItemAtPath:(ocidSaveFilePathURL's |path|()) |error|:(reference)
	
	
	###保存したスクリプトを開く
	tell application "Script Editor"
		open aliasSaveFilePath
	end tell
end if




#######################################
###ファイル名に使えない文字を全角に置換（Win互換）
#######################################
to doFileName4Mac(atgFileName)
	###受け取った値をテキストに
	set strFileName to atgFileName as text
	set ocidRetuenFileName to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
	ocidRetuenFileName's setString:(strFileName)
	###置換レコード
	set ocidLength to ocidRetuenFileName's |length|()
	set ocidRange to refMe's NSMakeRange(0, ocidLength)
	set ocidOption to (refMe's NSCaseInsensitiveSearch)
	###基本レコード
	set recordProhibit to {|:|:"：", |/|:"\\:", |\\|:"\\\\", |*|:"\\*", |(|:"\\(", |)|:"\\)", |[|:"\\[", |]|:"\\]", |{|:"\\{", |}|:"\\}", |'|:"\\'", |"|:"\\\"", |\||:"\\\\|", |;|:"\\;"} as record
	set ocidProhibitDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidProhibitDict's setDictionary:(recordProhibit)
	###キーのリストを取出して
	set ocidKeyArray to ocidProhibitDict's allKeys()
	###キーの数だけ繰り返し
	repeat with itemKey in ocidKeyArray
		##キーから
		set strKey to itemKey as text
		##値を取出して
		set strValue to (ocidProhibitDict's valueForKey:(itemKey)) as text
		##キー文字をヴァリュー文字に置換
		(ocidRetuenFileName's replaceOccurrencesOfString:(strKey) withString:(strValue) options:(ocidOption) range:(ocidRange))
	end repeat
	##置換されたテキストを
	set strRetuenFileName to ocidRetuenFileName as text
	###戻す
	return strRetuenFileName
end doFileName4Mac