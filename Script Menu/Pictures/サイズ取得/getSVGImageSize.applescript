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
		#ファイル名
		set ocidFileName to ocidFilePathURL's lastPathComponent()
		#拡張子を小文字で取得
		set ocidExtensionName to ocidFilePathURL's pathExtension()
		set strExtensionName to ocidExtensionName's lowercaseString() as text
		#SVGZを解凍する
		if strExtensionName is "svgz" then
			#解凍先ディレクトリ　起動時に削除する項目
			set appFileManager to refMe's NSFileManager's defaultManager()
			set ocidTempDirURL to appFileManager's temporaryDirectory()
			set ocidUUID to refMe's NSUUID's alloc()'s init()
			set ocidUUIDString to ocidUUID's UUIDString
			set ocidSaveDirPathURL to (ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true)
			set appFileManager to refMe's NSFileManager's defaultManager()
			set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
			# 777-->511 755-->493 700-->448 766-->502 
			(ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions))
			set listBoolMakeDir to (appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
			#解凍先のファイルパス
			set ocidTmpFilePathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidFileName) isDirectory:false)
			#コマンド用にパステキストに
			set strFilePath to ocidFilePathURL's |path| as text
			set strTmpeFilePath to ocidTmpFilePathURL's |path| as text
			#
			set strCommandText to ("/usr/bin/gunzip -c \"" & strFilePath & "\" > \"" & strTmpeFilePath & "\"") as text
			do shell script strCommandText
			set ocidFilePathURL to ocidTmpFilePathURL
		end if
		####################################
		##サイズ取得 
		#ファイルを読み込み
		set listReadData to (refMe's NSXMLDocument's alloc()'s initWithContentsOfURL:(ocidFilePathURL) options:(refMe's NSXMLNodeOptionsNone) |error|:(reference))
		set ocidXmlDoc to (item 1 of listReadData)
		#ROOTエレメントを取得して
		set ocidRootElement to ocidXmlDoc's rootElement
		#viewBoxを取得
		set ocidViewBox to (ocidRootElement's attributeForName:("viewBox"))
		#テキストにして
		set ocidViewBoxStr to ocidViewBox's stringValue()
		#スペースを区切り文字でリストにして
		set ocidViewBoxArray to (ocidViewBoxStr's componentsSeparatedByString:(" "))
		#３番目と４番目が横縦ピクセルサイズ
		set ocidPixelWidth to (ocidViewBoxArray's objectAtIndex:(2))
		set ocidPixelHeight to (ocidViewBoxArray's objectAtIndex:(3))
		set numPixelWidth to ocidPixelWidth as integer
		set numPixelHeight to ocidPixelHeight as integer
		##戻り値
		set strResponseText to ("W: " & numPixelWidth & "\nH: " & numPixelHeight & "\n<img src=\"パス\" width=\"" & numPixelWidth & "\" height=\"" & numPixelHeight & "\" alt=\"" & (ocidFileName as text) & "\">\n\nmax-width: " & numPixelWidth & "px;\nmax-height: " & numPixelHeight & "px;\n") as text
		
		#####ダイアログを前面に
		tell current application
			set strName to name as text
		end tell
		####スクリプトメニューから実行したら
		if strName is "osascript" then
			tell application "Finder" to activate
		else
			tell current application to activate
		end if
		set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
		###ダイアログ
		set recordResult to (display dialog "SVGサイズ戻り値です" with title "戻り値です" default answer strResponseText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)
		###クリップボードコピー
		if button returned of recordResult is "クリップボードにコピー" then
			set strText to text returned of recordResult as text
			####ペーストボード宣言
			set appPasteboard to refMe's NSPasteboard's generalPasteboard()
			set ocidText to (refMe's NSString's stringWithString:(strText))
			appPasteboard's clearContents()
			(appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString))
		end if
		
		
	end repeat
end open
