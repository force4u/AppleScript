#!/usr/bin/osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

on run (argKeyWord)
	if (argKeyWord as text) is "-h" then
		log doPrintHelp()
		return
else 	if (argKeyWord as text) is "" then
		log doPrintHelp()
		return
	end if
	if (item 1 of argKeyWord) is "-i" then
		set strSetHost to ("images.google.com") as text
		set strSetPath to ("/images") as text
		set strKeyWord to (item 2 of argKeyWord) as text
	else
		set strSetHost to ("www.google.com") as text
		set strSetPath to ("/search") as text
		set strKeyWord to argKeyWord as text
	end if
	set ocidKeyWord to current application's NSString's stringWithString:(strKeyWord)
	set ocidURLComponents to current application's NSURLComponents's alloc()'s init()
	ocidURLComponents's setScheme:("https")
	ocidURLComponents's setHost:(strSetHost)
	ocidURLComponents's setPath:(strSetPath)
	set ocidQueryItems to current application's NSMutableArray's alloc()'s initWithCapacity:(0)
	ocidQueryItems's addObject:(current application's NSURLQueryItem's alloc()'s initWithName:("q") value:(ocidKeyWord))
	ocidURLComponents's setQueryItems:(ocidQueryItems)
	set ocidOpenURL to ocidURLComponents's |URL|()
	set appSharedWorkspace to current application's NSWorkspace's sharedWorkspace()
	set boolDone to appSharedWorkspace's openURL:(ocidOpenURL)
	return
end run

on doPrintHelp()
	set strHelpText to ("
　キーワードをGoogleで検索します
　ブラウザはユーザーのデフォルトブラウザになります
使用方法:
	google.applescript キーワード 　で通常検索
	google.applescript -i キーワード 画像検索
引数:
	キーワード　検索語句になります
例:
google.applescript オープンタイプフォント
google.applescript -i アイドル


") as text
	return strHelpText
end doPrintHelp

