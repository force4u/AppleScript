use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


on run {argAliasFilePath}
	repeat with itemAliasFilePath in argAliasFilePath
		set strSelectionFilePath to (POSIX path of itemAliasFilePath) as text
		do shell script "plutil -convert xml1 \"" & strSelectionFilePath & "\""
	end repeat
end run