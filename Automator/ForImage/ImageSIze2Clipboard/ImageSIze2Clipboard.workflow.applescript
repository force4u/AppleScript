use AppleScript version "2.8"
use scripting additions
use framework "Foundation"
use framework "AppKit"
property refMe : a reference to current application


property numYpx : 0
property numXpx : 0

on run {argAliasFilePath}
	set strFilePath to (POSIX path of argAliasFilePath) as text
	set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set objImageRep to (refMe's NSBitmapImageRep's imageRepWithContentsOfFile:(ocidFilePath))
	tell objImageRep
		set numXpx to pixelsHigh()
		set numYpx to pixelsWide()
	end tell
	set strResponse to "width:" & numYpx & "px;height:" & numXpx & "px;" as text
	set the clipboard to strResponse as text
end run