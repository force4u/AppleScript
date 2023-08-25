#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

###パス（ホスト）リスト
set listURLs to {"edge-urls", "about", "accessibility", "app-service-internals", "app-settings", "application-guard-internals", "apps", "attribution-internals", "augloop-internals", "autofill-internals", "blob-internals", "bluetooth-internals", "browser-essentials", "collected-cookies-dialog", "commerce-internals", "compat", "components", "connectors-internals", "crashes", "credits", "data-viewer", "device-log", "discards", "download-internals", "downloads", "edge-dlp-internals", "extensions", "extensions-internals", "favorites", "flags", "floc-internals", "gcm-internals", "gpu", "help", "histograms", "history", "history-clusters-internals", "indexeddb-internals", "inspect", "interstitials", "invalidations", "launch-source", "local-state", "mam-internals", "management", "media-engagement", "media-internals", "metrics-internals", "net-export", "net-internals", "network-errors", "newtab", "ntp-tiles-internals", "omnibox", "optimization-guide-internals", "password-manager", "password-manager-internals", "policy", "predictors", "prefs-internals", "print", "private-aggregation-internals", "process-internals", "profile-internals", "push-internals", "quota-internals", "serviceworker-internals", "settings", "signin-internals", "site-engagement", "suggest-internals", "super-resolution-popup", "sync-internals", "system", "tab-search.top-chrome", "terms", "topics-internals", "tracing", "translate-internals", "ukm", "usb-internals", "user-actions", "version", "web-app-internals", "webrtc-internals", "webrtc-logs"} as list


##############################
###ダイアログ
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###
set strTitle to "選んでください" as text
set strPrompt to "選んでください" as text
try
	set listResponse to (choose from list listURLs with title strTitle with prompt strPrompt default items (item 1 of listURLs) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
	error "エラーしました" number -200
end try
if listResponse = {} then
	log "何も選択していない"
	return "何も選択していない"
else if (item 1 of listResponse) is false then
	return "キャンセルしました"
	error "キャンセルしました" number -200
else
	##############################
	###選択されたホスト名を順番に開く
	repeat with itemResponse in listResponse
		###テキストに確定
		set strResponse to itemResponse as text
		###URLコンポーネント初期化
		set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
		###スキーム を追加
		(ocidURLComponents's setScheme:("edge"))
		###パスを追加（setPathじゃないよ）
		(ocidURLComponents's setHost:(strResponse))
		set ocidTagURL to ocidURLComponents's |URL|
		set strTagURL to ocidTagURL's absoluteString() as text
		tell application "Microsoft Edge"
			activate
			tell front window
				set objNewTab to make new tab
				tell objNewTab to set URL to strTagURL
			end tell
		end tell
		
	end repeat
end if

