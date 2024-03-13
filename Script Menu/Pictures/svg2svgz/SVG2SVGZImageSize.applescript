#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

on run
	
	set aliasIconPass to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/MultipleItemsIcon.icns") as alias
	set strDialogText to "ドロップしても利用できます"
	set strTitleText to "画像ファイルを選んでください"
	set listButton to {"ファイルを選びます", "キャンセル"} as list
	display dialog strDialogText buttons listButton default button 1 cancel button 2 with title strTitleText with icon aliasIconPass giving up after 1 with hidden answer
	
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
	set listChooseFileUTI to {"public.svg-image"}
	set strPromptText to "イメージファイルを選んでください" as text
	set strPromptMes to "イメージファイルを選んでください" as text
	set listAliasFilePath to (choose file strPromptMes with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with showing package contents, invisibles and multiple selections allowed) as list
	
	-->値をOpenに渡たす
	open listAliasFilePath
end run


on open listAliasFilePath
	
	set appFileManager to refMe's NSFileManager's defaultManager()
	##対象の拡張子のURLだけ格納するARRAY
	set ocidFilePathURLArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
	##開いたエイリアスの数だけ々	
	repeat with itemAliasFilePath in listAliasFilePath
		#パス処理
		set strFilePath to (POSIX path of itemAliasFilePath) as text
		set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath))
		#拡張子を小文字で取得して
		set ocidExtensionName to ocidFilePathURL's pathExtension()
		set strExtensionName to ocidExtensionName's lowercaseString() as text
		#対象の拡張子のURLだけARRAYに格納していく
		if strExtensionName is "svg" then
			(ocidFilePathURLArrayM's addObject:(ocidFilePathURL))
		else if strExtensionName is "svgz" then
			(ocidFilePathURLArrayM's addObject:(ocidFilePathURL))
		end if
	end repeat
	##########################
	##対象の拡張子のURLファイルの数だけ繰り返し
	repeat with itemArray in ocidFilePathURLArrayM
		#Arrayの中身はURLなので
		set ocidFilePathURL to itemArray
		set strFilePath to ocidFilePathURL's |path| as text
		#拡張子をとって
		set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
		#拡張子を小文字で取得
		set ocidExtensionName to ocidFilePathURL's pathExtension()
		set strExtensionName to ocidExtensionName's lowercaseString() as text
		#SVGZを解凍する
		if strExtensionName is "svgz" then
			#
			set ocidDistFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:("svg"))
			#
			set boolDirExists to (appFileManager's fileExistsAtPath:(ocidDistFilePathURL's |path|) isDirectory:(false))
			if boolDirExists = true then
				repeat with itemIntNo from 10 to 1 by -1
					set ocidTmpFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:(itemIntNo as text))
					set ocidDistFilePathURL to (ocidTmpFilePathURL's URLByAppendingPathExtension:("svg"))
					set boolDirExists to (appFileManager's fileExistsAtPath:(ocidDistFilePathURL's |path|) isDirectory:(false))
					if boolDirExists = false then
						set strDistFilePath to ocidDistFilePathURL's |path| as text
					end if
				end repeat
				
			else if boolDirExists = false then
				set strDistFilePath to ocidDistFilePathURL's |path| as text
			end if
			#
			try
				set strCommandText to ("/usr/bin/gunzip -c \"" & strFilePath & "\" > \"" & strDistFilePath & "\"") as text
				do shell script strCommandText
			end try
		else if strExtensionName is "svg" then
			#
			set ocidDistFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:("svgz"))
			#
			set boolDirExists to (appFileManager's fileExistsAtPath:(ocidDistFilePathURL's |path|) isDirectory:(false))
			if boolDirExists = true then
				repeat with itemIntNo from 10 to 1 by -1
					set ocidTmpFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:(itemIntNo as text))
					set ocidDistFilePathURL to (ocidTmpFilePathURL's URLByAppendingPathExtension:("svgz"))
					set boolDirExists to (appFileManager's fileExistsAtPath:(ocidDistFilePathURL's |path|) isDirectory:(false))
					if boolDirExists = false then
						set strDistFilePath to ocidDistFilePathURL's |path| as text
					end if
				end repeat
			else if boolDirExists = false then
				set strDistFilePath to ocidDistFilePathURL's |path| as text
			end if
			#
			try
				set strCommandText to ("/usr/bin/gzip -c \"" & strFilePath & "\" > \"" & strDistFilePath & "\"") as text
				do shell script strCommandText
			end try
		end if
		
	end repeat
end open
