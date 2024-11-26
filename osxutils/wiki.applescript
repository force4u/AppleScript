#!/usr/bin/osascript
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

on run (argKeyWord)
	if (argKeyWord as text) is "" then
		log doPrintHelp()
		return 0
	end if
	set strKeyWord to argKeyWord as text
	set ocidKeyWord to current application's NSString's stringWithString:(strKeyWord)
	set ocidURLComponents to current application's NSURLComponents's alloc()'s init()
	ocidURLComponents's setScheme:("https")
	ocidURLComponents's setHost:("ja.wikipedia.org")
	ocidURLComponents's setPath:("/wiki/Special:Search")
	set ocidQueryItems to current application's NSMutableArray's alloc()'s initWithCapacity:(0)
	ocidQueryItems's addObject:(current application's NSURLQueryItem's alloc()'s initWithName:("search") value:(ocidKeyWord))
	ocidURLComponents's setQueryItems:(ocidQueryItems)
	set ocidOpenURL to ocidURLComponents's |URL|()
	set appSharedWorkspace to current application's NSWorkspace's sharedWorkspace()
	set boolDone to appSharedWorkspace's openURL:(ocidOpenURL)
	if boolDone is ture then
		return 0
	end if
	return "エラーしました"
	return 0
end run

on doPrintHelp()
	set strHelpText to ("
　キーワードをWikiで検索します
　ブラウザはユーザーのデフォルトブラウザになります
使用方法:
 wiki.applescript キーワード 
引数:
	キーワード　検索語句になります
例:
 wiki.applescript オープンタイプフォント

") as text
	return strHelpText
end doPrintHelp

