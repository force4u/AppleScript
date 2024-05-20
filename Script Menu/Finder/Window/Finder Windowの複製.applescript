#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 前面Finder Windowの複製　詳細版
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use scripting additions

###ウィンドウの有無チェック
tell application "Finder"
	set numCntWindow to (count of every Finder window) as integer
end tell
if numCntWindow = 0 then
	return "保存するウィンドウがありません"
end if
# Finder Window 前面のだけ処理する
tell application "Finder"
	tell front Finder window
		set aliasTargetPath to target as alias
		set listPosition to position as list
		set listBounds to bounds as list
		set numSideBarWidth to sidebar width as integer
		set boolToolBarVisible to toolbar visible as boolean
		set boolStatusBarVisible to statusbar visible as boolean
		set boolPathBarVisible to pathbar visible as boolean
		set boolZoomed to zoomed as boolean
		set boolCollapsed to collapsed as boolean
		set constantCurrentView to current view as constant
	end tell
	##オプション分岐
	if constantCurrentView is column view then
		tell column view options of front Finder window
			set numTextSize to text size as integer
			set boolShowIcon to shows icon as boolean
			set boolShowsIconPreview to shows icon preview as boolean
			set boolShowsPreviewColumn to shows preview column as boolean
			set boolDisClosesPreviewPane to discloses preview pane as boolean
		end tell
	else if constantCurrentView is icon view then
		tell icon view options of front Finder window
			set constantArrangement to arrangement as constant
			set constantLabelPosition to label position as constant
			set listBackgroundColor to background color as list
			set numTextSize to text size as integer
			set numIconSize to icon size as integer
			set boolShowsItemInfo to shows item info as boolean
			set boolShowsIconPreview to shows icon preview as boolean
		end tell
	else if constantCurrentView is list view then
		tell list view options of front Finder window
			set constantIconSize to icon size as constant
			set columnSortColumn to sort column
			set numTextSize to text size as integer
			set boolCalculatesFolderSizes to calculates folder sizes as boolean
			set boolShowsIconPreview to shows icon preview as boolean
			set boolUsesRelativeDates to uses relative dates as boolean
		end tell
	end if
end tell
#####################
#複製
tell application "Finder"
	set objNewWindow to (make new Finder window to folder aliasTargetPath)
	tell objNewWindow
		#右下方向に２０ピクセルつづずらす
		set numSetX to ((item 1 of listPosition) + 20) as integer
		set numSetY to ((item 2 of listPosition) + 20) as integer
		set listSetPosition to {numSetX, numSetY} as list
		set position to listSetPosition
		#右下方向に２０ピクセルつづずらす
		set numSetX to ((item 1 of listBounds) + 20) as integer
		set numSetY to ((item 2 of listBounds) + 20) as integer
		set numSetW to ((item 3 of listBounds) + 20) as integer
		set numSetH to ((item 4 of listBounds) + 20) as integer
		set listSetBounds to {numSetX, numSetY, numSetW, numSetH} as list
		set bounds to listSetBounds
		set sidebar width to numSideBarWidth
		set toolbar visible to boolToolBarVisible
		set statusbar visible to boolStatusBarVisible
		set pathbar visible to boolPathBarVisible
		set zoomed to boolZoomed
		set collapsed to boolCollapsed
		set current view to constantCurrentView
	end tell
	##オプション分岐
	if constantCurrentView is column view then
		tell column view options of front Finder window
			set text size to numTextSize
			set shows icon to boolShowIcon
			set shows icon preview to boolShowsIconPreview
			set shows preview column to boolShowsPreviewColumn
			set discloses preview pane to boolDisClosesPreviewPane
		end tell
	else if constantCurrentView is icon view then
		tell icon view options of front Finder window
			set arrangement to constantArrangement
			set label position to constantLabelPosition
			set background color to listBackgroundColor
			set text size to numTextSize
			set icon size to numIconSize
			set shows item info to boolShowsItemInfo
			set shows icon preview to boolShowsIconPreview
		end tell
	else if constantCurrentView is list view then
		tell list view options of front Finder window
			set icon size to constantIconSize
			set sort column to columnSortColumn
			set text size to numTextSize
			set calculates folder sizes to boolCalculatesFolderSizes
			set shows icon preview to boolShowsIconPreview
			set uses relative dates to boolUsesRelativeDates
		end tell
	end if
end tell
