#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# Automator ワークフロー用 (クイックアクション)
# ワークフローが受け取るのは『フォルダ』 アプリケーションは『Finder』
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use scripting additions

on run {input}
	set strUTI to "jp.tmkk.XLD" as text
	####フォルダの数だけ繰り返し
	repeat with itemFolderPath in input
		######パス フォルダのエイリアス
		set aliasDirPath to itemFolderPath as alias
		##############################
		###フォルダ判定 A Finderを使う
		##############################
		###シンボリックリンクは判定出来ない（エイリアスのリンク先を参照する）
		###エイリアス判定もするのでわりと堅実
		tell application "Finder"
			set strKind to (kind of aliasDirPath)
		end tell
		log strKind
		if strKind is not "フォルダ" then
			return "処理対象はフォルダのみですA"
		end if
		###入力のフォルダのエイリアスをアプリで開く
		tell application id strUTI
			open aliasDirPath
		end tell
	end repeat
end run
