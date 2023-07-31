use AppleScript version "2.8"
use scripting additions

tell application "Finder" to activate

###対象は選択中のファイル
tell application "Finder"
	set listAliasPath to selection as list
end tell

repeat with itemAliasFilePath in listAliasPath
	set aliasAliasFilePath to itemAliasFilePath as alias
	tell application "Finder"
		set strKind to kind of aliasAliasFilePath
		if strKind is "フォルダ" then
			return "フォルダは処理しない"
		end if
		set strExtension to name extension of aliasAliasFilePath
		if strExtension is "applescript" then
			log "applescript"
		else if strExtension is "bash" then
			log "bash"
		else if strExtension is "command" then
			log "command"
		else if strExtension is "sh" then
			log "sh"
		else
			return "対象ファイル以外は処理しない"
		end if
		
	end tell
	set strFilePath to (POSIX path of aliasAliasFilePath) as text
	set strCommandText to ("\"" & strFilePath & "\"") as text
	do shell script strCommandText
end repeat
