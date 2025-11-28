#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
システム設定オープン用のスクリプト作成補助 
アンカーのないタイプのパネルに対応した
作成されるスクリプトにウィンドウの最小化を解除する手順を入れた
v5 macOS14でreveal anchor の位置がずれるのに対応した
v6 英語で利用中でも取得できるようにした
v7 ユーザーインストールのパネルも取得できるようにした
v7.1 記述を少し統一してダイアログをSYSTEMUISERVERに設定
v7.1.1 １ケ所間違い修正
v7.1.2 macOS26でアンカーが無い場合の対応でtryと保存ファイル名に修正を入れた
v7.1.3 macOS26でSYSTEMUISERVERがよくないみたいなのでUIの呼び出しをSystem Eventsに戻した
v8 『一般』の呼称をマルチリンガル対応した


com.cocolog-nifty.quicktimer.icefloe *)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set strBundleID to "com.apple.systempreferences" as text

############################
#【１】システム設定の起動を確定させる
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
		end tell
		delay 0.5
		tell application id strBundleID to quit
	end if
	#半ゾンビ化対策	
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate
	end repeat
	#システム設定を起動させる
	try
		tell application id strBundleID to activate
	on error
		tell application "System Settings" to activate
	end try
	#起動待ち
	tell application id strBundleID
		#起動確認　最大１０秒
		repeat 10 times
			activate
			set boolFrontMost to frontmost as boolean
			log boolFrontMost
			if boolFrontMost is true then
				#魔法の１秒
				delay 0.5
				exit repeat
			else
				delay 0.5
			end if
		end repeat
	end tell
end if
####################
#地域と言語(Region and language)
set appLocale to refMe's NSLocale's currentLocale()
set ocidLocaleID to appLocale's objectForKey:(refMe's NSLocaleIdentifier)
set strLocaleID to ocidLocaleID as text

#ダイアログ用のメッセージ辞書の取得
#(Get a message dictionary for dialogs)
set ocidMsgDict to doGetGeneral(appLocale)
set strGeneral to (ocidMsgDict's objectForKey:("GENERAL")) as text
set strOK to (ocidMsgDict's objectForKey:("OK")) as text
set strCancel to (ocidMsgDict's objectForKey:("Cancel")) as text
set strChoose to (ocidMsgDict's objectForKey:("Choose")) as text
set strGoToPane to (ocidMsgDict's objectForKey:("Go to Enclosing Pane")) as text
set strSelection to (ocidMsgDict's objectForKey:("4.title")) as text
set strStoreScript to (ocidMsgDict's objectForKey:("Store Script")) as text
set strCopy to (ocidMsgDict's objectForKey:("157.title")) as text


############################
#【２】全てのパネルのIDを取得
tell application id "com.apple.systempreferences"
	set listPanelID to (id of every pane) as list
end tell


############################
###【A】正順レコード
set ocidPaneDict to (refMe's NSMutableDictionary's alloc()'s init())
###【B】逆順レコード
set ocidReversePaneDict to (refMe's NSMutableDictionary's alloc()'s init())
###【３】１で取得したリストの数だけ繰り返し
repeat with itemPanelID in listPanelID
	set strPanelID to itemPanelID as text
	tell application "System Settings"
		if strPanelID is "com.apple.systempreferences.GeneralSettings" then
			set strPanelName to (strGeneral) as text
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
set ocidDescriptorArray to refMe's NSMutableArray's alloc()'s init()
ocidDescriptorArray's addObject:(ocidDescriptor)
set ocidSortedKey to (ocidAllValueArray's sortedArrayUsingDescriptors:(ocidDescriptorArray))
set listAllValueArray to ocidSortedKey as list


############################
###【５】ダイアログ　　パネル
try
	tell application "System Events"
		activate
		set listResponse to (choose from list listAllValueArray with title strChoose with prompt (strSelection & "\r" & strGoToPane) default items (item 1 of listAllValueArray) OK button name strOK cancel button name strCancel without multiple selections allowed and empty selection allowed) as list
	end tell
on error strErrMes number numErrNo
	tell application "System Events" to quit
	log strErrMes & numErrNo
	return false
end try
if (item 1 of listResponse) is false then
	return false
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
if strResponse is strGeneral then
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
	set ocidPropertieArray to refMe's NSMutableArray's alloc()'s init()
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
try
	tell application "System Events"
		activate
		set listResponse to (choose from list listPaneAnchor with title strChoose with prompt (strSelection & "\r" & strGoToPane) default items (item 1 of listPaneAnchor) OK button name strOK cancel button name strCancel without multiple selections allowed and empty selection allowed) as list
	end tell
on error strErrMes number numErrNo
	tell application "System Events" to quit
	log strErrMes & numErrNo
	return false
end try
if (item 1 of listResponse) is false then
	return false
else
	set strPaneAnchor to (item 1 of listResponse) as text
end if
log strPaneAnchor
tell application "System Events" to quit

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
set ocidOpenUrlArray to refMe's NSMutableArray's alloc()'s init()
ocidOpenUrlArray's insertObject:(ocidOpenAppURL) atIndex:(0)
###FinderでURLを開くのでFinderのURLを用意
set strBundleID to "com.apple.finder" as text
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidAppPathURL to appShardWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
###NSWorkspaceで開く
set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration()
ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:(true))
ocidOpenConfig's setAllowsRunningApplicationSubstitution:(refMe's NSNumber's numberWithBool:(true))
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
	set strScript to ("#!/usr/bin/env osascript\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\n#\n# com.cocolog-nifty.quicktimer.icefloe\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\nuse AppleScript version \"2.8\"\nuse framework \"Foundation\"\nuse framework \"AppKit\"\nuse scripting additions\n\nproperty refMe : a reference to current application\ntell application id \"com.apple.systempreferences\" to activate\ndelay 2\nset strFilePath to (\"" & strFilePath & "\") as text\nset ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)\nset ocidFilePath to ocidFilePathStr's stringByStandardizingPath()\nset ocidSystemPreferencesURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)\n##\nset ocidWorkspace to refMe's NSWorkspace's sharedWorkspace()\nset boolDone to ocidWorkspace's openURL:(ocidSystemPreferencesURL)\nif boolDone is false then\ntry\nset aliasFilePath to (POSIX file strFilePath) as alias\ntell application \"Finder\"\nopen location aliasFilePath\nend tell\nend try\nend if\n\ntell application id \"com.apple.systempreferences\"\nactivate\nset miniaturized of the settings window to false\nend tell\ntell application id \"com.apple.finder\"\nopen location \"x-apple.systempreferences:" & strPaneID & "\"\nend tell\n\ntell application id \"com.apple.systempreferences\"\ntell pane id \"" & strPaneID & "\"\nreveal\nend tell\nend tell\n\ntell application id \"com.apple.systempreferences\" to activate\n\n\nreturn") as text
	
else if strPaneAnchor is "Main" then
	set strScript to ("#!/usr/bin/env osascript\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\n(*\n\t\n\tcom.cocolog-nifty.quicktimer.icefloe *)\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\nuse AppleScript version \"2.8\"\nuse framework \"Foundation\"\nuse framework \"AppKit\"\nuse framework \"UniformTypeIdentifiers\"\nuse scripting additions\nproperty refMe : a reference to current application\nset strBundleID to (\"com.apple.systempreferences\") as text\n###URLにする\nset ocidURLComponents to refMe's NSURLComponents's alloc()'s init()\n###スキーム\nocidURLComponents's setScheme:(\"x-apple.systempreferences\")\n###パネルIDをパスにセット\nocidURLComponents's setPath:(\"" & strPaneID & "\")\n###アンカーをクエリーとして追加\nocidURLComponents's setQuery:(\"" & strPaneAnchor & "\")\nset ocidOpenAppURL to ocidURLComponents's |URL|\nset strOpenAppURL to ocidOpenAppURL's absoluteString() as text\n###ワークスペースで開く\nset appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()\nset boolDone to appShardWorkspace's openURL:(ocidOpenAppURL)\nlog boolDone\nif boolDone is false then\ntell application id \"com.apple.systempreferences\"\nactivate\nset miniaturized of the settings window to false\nend tell\ntell application id \"com.apple.finder\"\nopen location \"" & strOpenAppURL & "\"\nend tell\ntell application id \"com.apple.systempreferences\"\nreveal anchor \"" & strPaneAnchor & "\" of pane id \"" & strPaneID & "\"\nend tell\ntell application id \"com.apple.systempreferences\" to activate\nend if\n###開くのを待つ\nrepeat 10 times\ntell application id \"com.apple.systempreferences\"\nset boolFrontMost to frontmost as boolean\nend tell\nif boolFrontMost is true then\ndelay 1\nexit repeat\nelse\ntell application id \"com.apple.systempreferences\" to activate\ndelay 0.5\nend if\nend repeat\n###アンカーを再指定\n##tell application \"System Events\"\ntell application \"System Settings\"\ntell pane id \"" & strPaneID & "\"\nreveal\nend tell\nend tell\n##end tell\nreturn 0") as text
else
	set strScript to ("#!/usr/bin/env osascript\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\n#com.cocolog-nifty.quicktimer.icefloe\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\nuse AppleScript version \"2.8\"\nuse framework \"Foundation\"\nuse framework \"AppKit\"\nuse framework \"UniformTypeIdentifiers\"\nuse scripting additions\nproperty refMe : a reference to current application\nset strBundleID to (\"com.apple.systempreferences\") as text\n###URLにする\nset ocidURLComponents to refMe's NSURLComponents's alloc()'s init()\n###スキーム\nocidURLComponents's setScheme:(\"x-apple.systempreferences\")\n###パネルIDをパスにセット\nocidURLComponents's setPath:(\"" & strPaneID & "\")\n###アンカーをクエリーとして追加\nocidURLComponents's setQuery:(\"" & strPaneAnchor & "\")\nset ocidOpenAppURL to ocidURLComponents's |URL|\nset strOpenAppURL to ocidOpenAppURL's absoluteString() as text\n###ワークスペースで開く\nset appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()\nset boolDone to appShardWorkspace's openURL:(ocidOpenAppURL)\nlog boolDone\nif boolDone is false then\ntell application id \"com.apple.systempreferences\"\nactivate\nset miniaturized of the settings window to false\nend tell\ntell application id \"com.apple.finder\"\nopen location \"" & strOpenAppURL & "\"\nend tell\ntell application id \"com.apple.systempreferences\"\nreveal anchor \"" & strPaneAnchor & "\" of pane id \"" & strPaneID & "\"\nend tell\ntell application id \"com.apple.systempreferences\" to activate\nend if\n###開くのを待つ\nrepeat 10 times\ntell application id \"com.apple.systempreferences\"\nset boolFrontMost to frontmost as boolean\nend tell\nif boolFrontMost is true then\ndelay 1\nexit repeat\nelse\ntell application id \"com.apple.systempreferences\" to activate\ndelay 0.5\nend if\nend repeat\n###パネルを確認して\nrepeat 10 times\ntell application id \"com.apple.systempreferences\"\nactivate\ntell current pane\nset strPaneID to id\nend tell\nend tell\nif strPaneID is \"com.apple.systempreferences.GeneralSettings\" then\ndelay 0.5\nelse if strPaneID is \"" & strPaneID & "\" then\nexit repeat\nend if\nend repeat\n###アンカーを再指定\ntell application \"System Settings\"\ntell pane id \"" & strPaneID & "\"\ntell anchor \"" & strPaneAnchor & "\"\ntry\nreveal\nend try\n\nend tell\nend tell\nend tell\nreturn 0") as text
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


###ダイアログを前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "System Events" to activate
else
	tell current application to activate
end if
tell application "System Events"
	activate
	set recordResult to (display dialog strSelection with title strChoose default answer strScript buttons {strCopy, strCancel, strStoreScript} default button strStoreScript cancel button strCancel giving up after 20 with icon aliasIconPath without hidden answer)
end tell

#################################
###【１３】クリップボードにコピー
if button returned of recordResult is strCopy then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if
#################################
###【１４】OK押したらスクリプト生成
if button returned of recordResult is strStoreScript then
	##ファイル名
	if strPaneAnchor is "" then
		set strFileName to (strResponse & "." & (ocidPaneID as text) & ".applescript") as text
	else
		set strFileName to (strResponse & "." & (ocidPaneID as text) & "." & strPaneAnchor & ".applescript") as text
	end if
	##保存先はスクリプトメニュー
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidLibraryDIrURL to ocidURLsArray's firstObject()
	set ocidScriptDirPathURL to ocidLibraryDIrURL's URLByAppendingPathComponent:("Scripts/Applications/System Settings/Open")
	###フォルダを作って
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s init()
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidScriptDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	#非互換文字の置換
	set strSaveFileName to doFileName4Mac(strFileName)
	set ocidSaveFilePathURL to ocidScriptDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
	###スクリプトをテキストで保存
	set ocidScript to refMe's NSString's stringWithString:(strScript)
	##改行はLFで
	set ocidLFScript to ocidScript's stringByReplacingOccurrencesOfString:("\n") withString:("\n")
	#	set ocidEnc to (refMe's NSUTF16LittleEndianStringEncoding)
	#	ターミナルからの実行を配慮してUTF8に
	set ocidEnc to (refMe's NSUTF8StringEncoding)
	set listDone to ocidLFScript's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(ocidEnc) |error|:(reference)
	delay 0.5
	set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
	###ターミナルから実行できるように755に
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s init()
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listDone to appFileManager's setAttributes:(ocidAttrDict) ofItemAtPath:(ocidSaveFilePathURL's |path|()) |error|:(reference)
	
	###
	#保存したスクリプトを開く
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set boolDone to appSharedWorkspace's openURL:(ocidSaveFilePathURL)
	if boolDone is false then
		tell application "Script Editor"
			open file aliasSaveFilePath
		end tell
	end if
end if
tell application "System Events" to quit

return

#######################################
###ファイル名に使えない文字を全角に置換（Win互換）
#######################################
to doFileName4Mac(atgFileName)
	###受け取った値をテキストに
	set strFileName to atgFileName as text
	set ocidRetuenFileName to refMe's NSMutableString's alloc()'s init()
	ocidRetuenFileName's setString:(strFileName)
	###置換レコード
	set ocidLength to ocidRetuenFileName's |length|()
	set ocidRange to refMe's NSMakeRange(0, ocidLength)
	set ocidOption to (refMe's NSCaseInsensitiveSearch)
	###基本レコード
	set recordProhibit to {|:|:"：", |/|:"\\:", |\\|:"\\\\", |*|:"＊", |(|:"\\(", |)|:"\\)", |[|:"\\[", |]|:"\\]", |{|:"\\{", |}|:"\\}", |'|:"\\'", |"|:"\\\"", |\||:"\\\\|", |;|:"\\;"} as record
	set ocidProhibitDict to refMe's NSMutableDictionary's alloc()'s init()
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




####################
#ローカライズメッセージ取得(Get Localize message)
to doGetGeneral(argLocale)
	set ocidLanguageCode to argLocale's objectForKey:(refMe's NSLocaleLanguageCode)
	set strLanguageCode to ocidLanguageCode as text
	set ocidLocaleID to argLocale's objectForKey:(refMe's NSLocaleIdentifier)
	set strLocaleID to ocidLocaleID as text
	log strLocaleID
	log strLanguageCode
	#LPROJフォルダ名(LPROJ folder name)
	set listLproj to {"ar", "ca", "cs", "da", "de", "el", "en_AU", "en_GB", "en", "es_419", "es", "fi", "fr_CA", "fr", "he", "hi", "hr", "hu", "id", "it", "ja", "ko", "ms", "nl", "no", "pl", "pt_BR", "pt_PT", "ro", "ru", "sk", "sl", "sv", "th", "tr", "uk", "vi", "zh_CN", "zh_HK", "zh_TW"} as list
	#その中でラングエージコードになっている言語(使ってないけど)
	set listLangID to {"ar", "ca", "cs", "da", "de", "el", "en", "es", "fi", "fr", "he", "hi", "hr", "hu", "id", "it", "ja", "ko", "ms", "nl", "no", "pl", "ro", "ru", "sk", "sl", "sv", "th", "tr", "uk", "vi"} as list
	#その中でロケールIDになっている言語(Among them, the language that is the locale ID)
	set listLocalID_Lproj to {"zh_CN", "zh_HK", "zh_TW", "pt_BR", "pt_PT", "en_AU", "en_GB", "fr_CA", "es_419"} as list
	########
	#FOR TEST
	#   set strLanguageCode to ("nn") as text
	#   set strLanguageCode to ("cy") as text
	#   set strLanguageCode to ("fr") as text
	#   set strLanguageCode to ("pt") as text
	#   set strLanguageCode to ("rm") as text
	#set strLanguageCode to ("zh") as text
	#set strLanguageCode to ("zh_TW") as text
	
	#言語判定　追加事項(Additional items for language judgment)
	if listLproj does not contain strLanguageCode then
		#ランゲージCodeがLPROJのフォルダ名に含まれていない場合
		#ランゲージCodeがLPROJのフォルダ名に含まれていない場合
		if strLanguageCode is "br" then
			set strSetUIlangID to ("fr") as text
		else if strLanguageCode is "gd" or strLanguageCode is "cy" then
			set strSetUIlangID to ("en_GB") as text
		else if strLanguageCode is "gl" or strLanguageCode is "eu" then
			set strSetUIlangID to ("en_GB") as text
		else if strLanguageCode is "nb" or strLanguageCode is "nn" then
			set strSetUIlangID to ("sv") as text
		else if strLanguageCode is "rm" then
			set strSetUIlangID to ("de") as text
		else
			#ロケールIDがLPROJのフォルダ名の場合
			if listLocalID_Lproj contains strLocaleID then
				set strSetUIlangID to (strLocaleID) as text
			else
				#追加判定にない場合はen表示
				set strSetUIlangID to ("en") as text
			end if
		end if
	else
		if listLocalID_Lproj contains strLocaleID then
			set strSetUIlangID to (strLocaleID) as text
		else
			set strSetUIlangID to (strLanguageCode) as text
		end if
	end if
	
	#マージした辞書にする
	set ocidMergeDict to refMe's NSMutableDictionary's alloc()'s init()
	
	
	#翻訳辞書を開く(Open the translation dictionary)
	#ScriptingAdditionsの辞書を使用(Use the dictionary of ScriptingAdditions)
	set strFilePath to ("/System/Applications/System Settings.app/Contents/Resources/MainMenu.loctable") as text
	set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath) isDirectory:(false)
	#loctableを開く(Open loctable file)
	set listResponse to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL) |error|:(reference)
	set ocidLocTableDict to (first item of listResponse)
	#対象の言語の翻訳を取得(Get the translation of the target language)
	if strSetUIlangID is "en" then
		set ocidMainMenuDict to ocidLocTableDict's objectForKey:("en_GB")
	else
		set ocidMainMenuDict to ocidLocTableDict's objectForKey:(strSetUIlangID)
	end if
	#マージ
	ocidMergeDict's addEntriesFromDictionary:(ocidMainMenuDict)
	
	
	#翻訳辞書を開く(Open the translation dictionary)
	#System Settingsの辞書を使用(Use the dictionary of System Settings.app)
	set strFilePath to ("/System/Applications/System Settings.app/Contents/Resources/Localizable.loctable") as text
	set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath) isDirectory:(false)
	#loctableを開く(Open loctable file)
	set listResponse to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL) |error|:(reference)
	set ocidLocTableDict to (first item of listResponse)
	#対象の言語の翻訳を取得(Get the translation of the target language)
	set ocidSystemSettingsDict to ocidLocTableDict's objectForKey:(strSetUIlangID)
	#マージ
	ocidMergeDict's addEntriesFromDictionary:(ocidSystemSettingsDict)
	
	#翻訳辞書を開く(Open the translation dictionary)
	#ScriptingAdditionsの辞書を使用(Use the dictionary of ScriptingAdditions)
	set strFilePath to ("/System/Library/ScriptingAdditions/StandardAdditions.osax/Contents/Resources/Localizable.loctable") as text
	set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath) isDirectory:(false)
	#loctableを開く(Open loctable file)
	set listResponse to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL) |error|:(reference)
	set ocidLocTableDict to (first item of listResponse)
	#対象の言語の翻訳を取得(Get the translation of the target language)
	set ocidStandardAdditionsDict to ocidLocTableDict's objectForKey:(strSetUIlangID)
	#マージ
	ocidMergeDict's addEntriesFromDictionary:(ocidStandardAdditionsDict)
	
	#翻訳辞書を開く(Open the translation dictionary)
	#ScriptingAdditionsの辞書を使用(Use the dictionary of ScriptingAdditions)
	set strFilePath to ("/System/Library/ScriptingAdditions/StandardAdditions.osax/Contents/Resources/ChooseFromList.loctable") as text
	set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath) isDirectory:(false)
	#loctableを開く(Open loctable file)
	set listResponse to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL) |error|:(reference)
	set ocidLocTableDict to (first item of listResponse)
	#対象の言語の翻訳を取得(Get the translation of the target language)
	if strSetUIlangID is "en" then
		set ocidChooseFromListDict to ocidLocTableDict's objectForKey:("en_GB")
	else
		set ocidChooseFromListDict to ocidLocTableDict's objectForKey:(strSetUIlangID)
	end if
	#マージ
	ocidMergeDict's addEntriesFromDictionary:(ocidChooseFromListDict)
	
	
	
	
	
	return ocidMergeDict
end doGetGeneral
