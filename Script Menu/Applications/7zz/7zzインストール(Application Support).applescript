#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*

ユーザーの ~/Library/Application Support　にインストールする

githubのRSSから対象のバイナリーをダウンロード展開する
7zz インストール

v2 20250422 XMLとHTMLで処理をわけた
com.cocolog-nifty.quicktimer.icefloe *)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application


###################
#【設定項目１】展開（解凍）先
#インストール場所はお好みで
#	set str7zPath to ("~/bin/7zip/7zz") as text
set str7zPath to ("~/Library/Application Support/7zip/7zz") as text

###################
#【設定項目2】GitHubURL
set strRepositoryURL to ("https://github.com/ip7z/7zip") as text


###################
#なければインストール
set ocid7zPathStr to refMe's NSString's stringWithString:(str7zPath)
set ocid7zPath to ocid7zPathStr's stringByStandardizingPath()
set ocid7zPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocid7zPath) isDirectory:(false)
set appFileManager to refMe's NSFileManager's defaultManager()
set boolDirExists to appFileManager's fileExistsAtPath:(ocid7zPath) isDirectory:(true)
if boolDirExists is true then
	log "インストール済み"
else
	log "インストールします"
end if

##########################
# インストール先フォルダを確保
set ocidBinDirPathURL to ocid7zPathURL's URLByDeletingLastPathComponent()
set strBinDirPath to ocidBinDirPathURL's |path|() as text
#BinDirインストール先
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s init()
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listDone to appFileManager's createDirectoryAtURL:(ocidBinDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)

##########################
# GitHub RSSのURL
set strRssURL to ("" & strRepositoryURL & "/tags.atom") as text
set ocidURLString to refMe's NSString's stringWithString:(strRssURL)
set ocidRssURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
log ocidRssURL's absoluteString() as text

##########################
#XML取得
set ocidReadXML to doGetRootElementXML(ocidRssURL)
if ocidReadXML is false then
	return "XMLの取得に失敗しました"
end if


##########################
#バージョン取得 linkのURLを使う
set ocidRootElement to ocidReadXML's rootElement()
#リンクの最初の項目が最新
set listResponse to (ocidRootElement's nodesForXPath:("//entry/link/@href") |error|:(reference))
set ocidLinkElementArray to (item 1 of listResponse)
#▼▼▼▼【要カスタマイズ】Arrayの何コ目が対象か？
set ocidFirstElement to ocidLinkElementArray's objectAtIndex:(0)
set ocidFirstElement to ocidFirstElement's stringValue()
#リリースページのURL
set ocidLinkURL to refMe's NSURL's alloc()'s initWithString:(ocidFirstElement)
log ocidLinkURL's absoluteString() as text
#ラストパス＝バージョン
set ocidVerNo to ocidLinkURL's lastPathComponent()
#【要customize】ここはアプリケーションによってカスタマイズが必要
set ocidVerNo to (ocidVerNo's stringByReplacingOccurrencesOfString:("v") withString:(""))
#カンマ有りのバージョン番号
set strVerNo to ocidVerNo as text
#カンマ無しのバージョン番号
set ocidVerNoStr to (ocidVerNo's stringByReplacingOccurrencesOfString:(".") withString:(""))
set strVerNoStr to ocidVerNoStr as text

##########################
#リリースアセットのHTMLパーツ部分
set strAssetsURL to ("" & strRepositoryURL & "/releases/expanded_assets/" & strVerNo & "") as text
set ocidAssetsURL to (refMe's NSURL's alloc()'s initWithString:(strAssetsURL))
log ocidAssetsURL's absoluteString() as text

##########################
#HTML取得
set ocidReadXML to doGetRootElementHTML(ocidAssetsURL)

##########################
#バージョン取得 linkのURLを使う
set ocidRootElement to ocidReadXML's rootElement()
#	log ocidRootElement's XMLString() as text
#リンクの最初の項目が最新
set listResponse to (ocidRootElement's nodesForXPath:("//div/ul/li/div/a/@href") |error|:(reference))
set ocidReleaseNodeArray to (item 1 of listResponse)
#▼▼▼▼【要カスタマイズ】　アセットの何番目が対象か？
set ocidReleaseNode to ocidReleaseNodeArray's objectAtIndex:(7)
set ocidReleasePath to ocidReleaseNode's stringValue()

#URLコンポーネント初期化
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
###スキーム を追加
ocidURLComponents's setScheme:("https")
###ホストを追加
ocidURLComponents's setHost:("github.com")
###パスを追加
ocidURLComponents's setPath:(ocidReleasePath)
##URLに戻して テキストにしておく
set ocidReleaseURL to ocidURLComponents's |URL|()
log ocidReleaseURL's absoluteString() as text
#
set ocidReleaseFileName to ocidReleaseURL's lastPathComponent()


##########################
#保存先テンポラリーディレクトリ
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:(true)

#フォルダ作成
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s init()
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:(true) attributes:(ocidAttrDict) |error|:(reference)

###パス
set ocidDownloadFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidReleaseFileName) isDirectory:(false)
set strDownloadFilePath to ocidDownloadFilePathURL's |path|() as text

log "ダウンロード開始"
##########################
#NSDATA
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listResponse to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidReleaseURL) options:(ocidOption) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "initWithContentsOfURL 正常処理"
	set ocidReadData to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	set strErrorNO to (item 2 of listResponse)'s code() as text
	set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
	refMe's NSLog("■：" & strErrorNO & strErrorMes)
	return "initWithContentsOfURL エラーしました" & strErrorNO & strErrorMes
end if

##NSDATA
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidReadData's writeToURL:(ocidDownloadFilePathURL) options:(ocidOption) |error|:(reference)
if (item 1 of listDone) is true then
	log "writeToURL ダウンロード正常処理"
else if (item 2 of listDone) ≠ (missing value) then
	set strErrorNO to (item 2 of listDone)'s code() as text
	set strErrorMes to (item 2 of listDone)'s localizedDescription() as text
	refMe's NSLog("■：" & strErrorNO & strErrorMes)
	return "writeToURL エラーしました" & strErrorNO & strErrorMes
end if

##########################
#▼▼▼▼【要カスタマイズ】
#提供ファイル形式によってカスタマイズ
set strCommandText to ("/usr/bin/bsdtar -xJf \"" & strDownloadFilePath & "\" -C \"" & strBinDirPath & "\"")
log doZshShellScript(strCommandText)

##########################
#インストール先を開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's openURL:(ocidBinDirPathURL)

return

##########################
# 【通常】ZSH　実行
to doZshShellScript(argCommandText)
	set strCommandText to argCommandText as text
	log "\r" & strCommandText & "\r"
	set strExec to ("/bin/zsh -c '" & strCommandText & "'") as text
	log "\r" & strExec & "\r"
	##########
	#コマンド実行
	try
		log "コマンド開始"
		set strResnponse to (do shell script strExec) as text
		log "コマンド終了"
	on error
		return false
	end try
	return true
end doZshShellScript



##########################
#XML取得
to doGetRootElementXML(argURL)
	##########################
	#NSDATA
	set ocidOption to (refMe's NSXMLNodePreserveAll) + (refMe's NSDataReadingMappedIfSafe)
	set listResponse to refMe's NSData's alloc()'s initWithContentsOfURL:(argURL) options:(ocidOption) |error|:(reference)
	if (item 2 of listResponse) = (missing value) then
		#		log "initWithContentsOfURL 正常処理"
		set ocidReadData to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		set strErrorNO to (item 2 of listResponse)'s code() as text
		set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
		refMe's NSLog("■：" & strErrorNO & strErrorMes)
		log "initWithContentsOfURL エラーしました" & strErrorNO & strErrorMes
		return false
	end if
	##########################
	#NSXML
	set ocidOption to (refMe's NSXMLDocumentTidyXML)
	set listResponse to refMe's NSXMLDocument's alloc()'s initWithData:(ocidReadData) options:(ocidOption) |error|:(reference)
	if (item 2 of listResponse) = (missing value) then
		#		log "initWithData 正常処理"
		set ocidReadXML to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		set strErrorNO to (item 2 of listResponse)'s code() as text
		set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
		refMe's NSLog("■：" & strErrorNO & strErrorMes)
		log "initWithData エラーしました" & strErrorNO & strErrorMes
	end if
	return ocidReadXML
end doGetRootElementXML



##########################
#HTML取得
to doGetRootElementHTML(argURL)
	##########################
	#NSDATA
	set ocidOption to (refMe's NSDataReadingMappedIfSafe)
	set listResponse to refMe's NSData's alloc()'s initWithContentsOfURL:(argURL) options:(ocidOption) |error|:(reference)
	if (item 2 of listResponse) = (missing value) then
		log "initWithContentsOfURL 正常処理"
		set ocidReadData to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		set strErrorNO to (item 2 of listResponse)'s code() as text
		set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
		refMe's NSLog("■：" & strErrorNO & strErrorMes)
		log "initWithContentsOfURL エラーしました" & strErrorNO & strErrorMes
		return false
	end if
	##########################
	#NSXML
	set ocidOption to (refMe's NSXMLNodePreserveAll) + (refMe's NSXMLDocumentTidyHTML)
	set listResponse to refMe's NSXMLDocument's alloc()'s initWithData:(ocidReadData) options:(ocidOption) |error|:(reference)
	if (item 2 of listResponse) = (missing value) then
		log "initWithData 正常処理"
		set ocidReadHTML to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		set ocidReadHTML to (item 1 of listResponse)
		#HTMLの場合エラーのログは出すけどエラーで終了にはしない
		set strErrorNO to (item 2 of listResponse)'s code() as text
		set strErrorMes to (item 2 of listResponse)'s localizedDescription() as text
		refMe's NSLog("■：" & strErrorNO & strErrorMes)
		log "initWithData エラーしました" & strErrorNO & strErrorMes
	end if
	return ocidReadHTML
end doGetRootElementHTML
