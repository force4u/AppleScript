use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


property numYpx : 0
property numXpx : 0


on run {argAliasFilePath}
	set strFilePath to (POSIX path of argAliasFilePath) as text
	set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	set strExtensionName to (ocidFilePathURL's pathExtension()) as text
	set ocidFileName to ocidFilePathURL's lastPathComponent()
	set strBaseFileName to (ocidFileName's stringByDeletingPathExtension()) as text
	set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
	set objImageRep to (refMe's NSBitmapImageRep's imageRepWithContentsOfURL:(ocidFilePathURL))
	tell objImageRep
		set numHpx to pixelsHigh()
		set numWpx to pixelsWide()
	end tell
	set objImageRep to ""
	set strNewFileName to (strBaseFileName & "." & numWpx & "x" & numHpx & "." & strExtensionName) as text
	set ocidNewFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:(strNewFileName)
	set appFileManager to refMe's NSFileManager's defaultManager()
	set listDone to appFileManager's moveItemAtURL:(ocidFilePathURL) toURL:(ocidNewFilePathURL) |error|:(reference)
end run