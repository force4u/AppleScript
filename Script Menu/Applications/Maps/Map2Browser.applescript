#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 	マップで表示中の位置をグーグルマップでブラウザ転送
# 
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use framework "UniformTypeIdentifiers"
use scripting additions


property refMe : a reference to current application



tell application "Maps"
	activate
end tell

set strURL to ""
doCopyMap()
set strURL to (the clipboard) as text

################################
######ペーストボードを取得
################################
##set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
#####テキストとして受け取る
##set ocidReadPasteboardTypeString to ocidPasteboard's stringForType:(refMe's NSPasteboardTypeString)
##set strURL to ocidReadPasteboardTypeString as text

################################################
###### URL部分
################################################
set coidURLStr to refMe's NSString's stringWithString:strURL
set coidURL to refMe's NSURL's URLWithString:coidURLStr
set ocidComponents to refMe's NSURLComponents's alloc()'s initWithURL:coidURL resolvingAgainstBaseURL:false



################################################
###### ホスト名取り出し
################################################
set ocidHostName to ocidComponents's |host|()
set strHostName to ocidHostName as text
####処理分岐するなら
if strHostName contains "maps.apple.com" then
	log "AppleMap"
	set ocidGeoLLArray to doGetLLappleMap(coidURL)
	set strLatitude to (ocidGeoLLArray's objectAtIndex:0) as text
	set strLongitude to (ocidGeoLLArray's objectAtIndex:1) as text
else
	log "他サービス"
	return "緯度経度値を取得できません"
end if

log strLatitude
log strLongitude

set strURL to "https://www.google.com/maps/@" & strLatitude & "," & strLongitude & ",17z/"


set ocidURLString to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)

################################################
###### ブラウザで開く
################################################
###設定項目ドキュメントのURL
set strScheme to "https://" as text
###NSURL
set ocidScheme to refMe's NSURL's URLWithString:(strScheme)
###ワークスペース初期化
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
###URLタイプのデフォルトアプリケーション
set ocidAppPathURL to appShardWorkspace's URLsForApplicationsToOpenURL:(ocidScheme)

###ダイアログ用のアプリケーション名リスト
set listAppName to {} as list
###アプリケーションのURLを参照させるためのレコード
set ocidBrowserDictionary to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
####################################################
####httpがスキームとして利用可能なアプリケーション一覧を取得する
####################################################
repeat with itemAppPathURL in ocidAppPathURL
	###アプリケーションの名前
	set listResponse to (itemAppPathURL's getResourceValue:(reference) forKey:(refMe's NSURLNameKey) |error|:(missing value))
	set strAppName to (item 2 of listResponse) as text
	log "ブラウザの名前は：" & strAppName & "です"
	copy strAppName to end of listAppName
	####パス
	set aliasAppPath to itemAppPathURL's absoluteURL() as alias
	log "ブラウザのパスは：" & aliasAppPath & "です"
	####バンドルID取得
	set ocidAppBunndle to (refMe's NSBundle's bundleWithURL:(itemAppPathURL))
	set ocidBunndleID to ocidAppBunndle's bundleIdentifier
	set strBundleID to ocidBunndleID as text
	log "ブラウザのBunndleIDは：" & strBundleID & "です"
	(ocidBrowserDictionary's setObject:(itemAppPathURL) forKey:(strAppName))
end repeat

################################
##ダイアログ
################################
###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listAppName with title "選んでください" with prompt "URLを開くアプリケーションを選んでください" default items (item 1 of listAppName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed)
on error
	log "エラーしました"
	return "エラーしました"
end try
if listResponse is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text
################################
##アプリケーションのURLを取得する
################################
###アプリケーションのURLを取り出す
set ocidAppPathURL to ocidBrowserDictionary's objectForKey:(strResponse)
set ocidAppBundle to refMe's NSBundle's bundleWithURL:(ocidAppPathURL)
set strOpenBundleID to (ocidAppBundle's bundleIdentifier()) as text
tell application id strOpenBundleID to launch
tell application id strOpenBundleID to activate


tell application id strOpenBundleID
	open location strURL
end tell


(*
###OPENするファイルのURLリスト
set ocidOpenURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidOpenURLArray's addObject:(ocidURL)
###OPEN config
set ocidConfig to refMe's NSWorkspaceOpenConfiguration's configuration()
ocidConfig's setHides:(false as boolean)
ocidConfig's setActivates:(true as boolean)
ocidConfig's setRequiresUniversalLinks:(false as boolean)
###指定のブラウザで開く
try
	run script (appShardWorkspace's openURLs:(ocidOpenURLArray) withApplicationAtURL:(ocidAppPathURL) configuration:(ocidConfig) completionHandler:(missing value))
on error
	
	delay 1
	set ocidAppBundle to refMe's NSBundle's bundleWithURL:(ocidAppPathURL)
	set strOpenBundleID to (ocidAppBundle's bundleIdentifier()) as text
	
	tell application id strOpenBundleID
		open location strURL
	end tell
	
end try
*)

################################################
######　サブルーチン
################################################

###################################################
###AppleMap処理
to doGetLLappleMap(argURL)
	
	################################################
	###### URLをコンポーネントに
	################################################
	set ocidComponents to refMe's NSURLComponents's alloc()'s initWithURL:argURL resolvingAgainstBaseURL:false
	
	################################################
	###### コンポーネントからクエリーを取り出し
	################################################
	set ocidURLQueryArray to ocidComponents's queryItems()
	
	################################################
	###### クエリーをレコードに
	################################################
	###格納用の可変ディクショナリ
	set ocidQueryDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	###クエリーの数だけ繰り返し
	repeat with itemURLQueryArray in ocidURLQueryArray
		###KEY
		set ocidQueryKey to itemURLQueryArray's |name|()
		####値
		set ocidQueryValue to itemURLQueryArray's value()
		####ディクショナリに格納
		(ocidQueryDict's setObject:ocidQueryValue forKey:ocidQueryKey)
	end repeat
	
	################################################
	###### 　キーで値を取り出す
	################################################
	###緯度経度取得
	set ocidGeoLL to (ocidQueryDict's valueForKey:"ll")
	###カンマで区切ってArrayにして
	set ocidGeoLLArray to ocidGeoLL's componentsSeparatedByString:","
	
	###戻り値はArrayのまま戻す
	return ocidGeoLLArray
	
	
	(* 	##値を取り出す時は
	set strLatitude to (ocidGeoLLArray's objectAtIndex:0) as text
	set strLongitude to (ocidGeoLLArray's objectAtIndex:1) as text
	*)
	
end doGetLLappleMap


###################################################
###　Mapのコピー処理


to doCopyMap()
	tell application "System Events"
		launch
	end tell
	tell application "Maps"
		activate
	end tell
	try
		tell application "System Events"
			tell process "Maps"
				##	get every menu bar
				tell menu bar 1
					##	get every menu bar item
					tell menu bar item "編集"
						##	get every menu bar item
						tell menu "編集"
							##	get every menu item
							tell menu item "リンクをコピー"
								click
							end tell
						end tell
					end tell
				end tell
			end tell
		end tell
		tell application "System Events"
			tell process "Maps"
				##	get every menu bar
				tell menu bar 1
					##	get every menu bar item
					tell menu bar item "編集"
						##	get every menu bar item
						tell menu "編集"
							##	get every menu item
							tell menu item "リンクをコピー"
								click
							end tell
						end tell
					end tell
				end tell
			end tell
		end tell
	on error
		try
			tell application id "com.apple.Maps"
				activate
				tell application "System Events"
					tell process "Maps"
						activate
						click menu item "リンクをコピー" of menu 1 of menu bar item "編集" of menu bar 1
					end tell
				end tell
			end tell
		end try
	end try
end doCopyMap
