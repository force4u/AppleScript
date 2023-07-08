#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#	
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "PDFKit"
use framework "Quartz"
use scripting additions


(*
0:ラベル無し
1:グレー
2:グリーン
3:パープル
4:ブルー
5:イエロー
6:レッド
7:オレンジ
*)

property refMe : a reference to current application

set objFileManager to refMe's NSFileManager's defaultManager()

##############################
#####ダイアログを前面に出す
##############################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
#######################################
#####ファイル選択ダイアログ
#######################################
###ダイアログのデフォルト
set ocidUserDesktopPath to (objFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set aliasDefaultLocation to ocidUserDesktopPath as alias
tell application "Finder"
end tell
set listChooseFileUTI to {"com.adobe.pdf"}
set strPromptText to "PDFファイルを選んでください" as text
set listAliasFilePath to (choose file with prompt strPromptText default location (aliasDefaultLocation) of type listChooseFileUTI with invisibles and multiple selections allowed without showing package contents) as list

#######################################
###ダイアログで選択した書類の数だけ繰り返し
#######################################

####ファイルの数だけ繰り返し
repeat with itemAliasFilePath in listAliasFilePath
	####ラベルの名前のリストの初期化
	set ocidTagNameArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
	###ラベル番号の初期化
	set numLabelNo to 0 as integer
	###パスとファイル名
	set strFilePath to POSIX path of itemAliasFilePath as text
	set ocidFilePathStr to (refMe's NSString's stringWithString:strFilePath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
	set strFileName to ocidFilePath's lastPathComponent() as text
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath isDirectory:false)
	#####PDFDocumentとして読み込み
	set ocidActivDoc to (refMe's PDFDocument's alloc()'s initWithURL:ocidFilePathURL)
	################################
	### パスワードチェック
	################################
	####ドキュメントを開くパスワードが設定されているか？
	set boolLocked to ocidActivDoc's isLocked() as boolean
	###ドキュメント開くパスワードがあると内容を調べられない
	if boolLocked is true then
		log strFileName & "開くのにパスワードが必要です"
		####ラベルを指定
		(ocidTagNameArray's addObjectsFromArray:{"PDF開封制限"})
		set numLabelNo to 6 as integer
	else
		################################
		####注釈があるか？チェック
		################################
		
		set numAllPageCnt to ocidActivDoc's pageCount()
		set numCntPageNO to 0 as integer
		set numCntAnotationAll to 0 as integer
		repeat numAllPageCnt times
			set ocidPageObject to (ocidActivDoc's pageAtIndex:numCntPageNO)
			set ocidAnotationArray to ocidPageObject's annotations()
			set numCntAnotation to (count of ocidAnotationArray) as integer
			set numCntAnotationAll to numCntAnotationAll + numCntAnotation as integer
			set numCntPageNO to numCntPageNO + 1 as integer
		end repeat
		if numCntAnotationAll ≥ 1 then
			####ラベルを指定
			(ocidTagNameArray's addObjectsFromArray:{"PDF注釈入"})
			set numLabelNo to 5 as integer
		end if
		
		################################
		### 暗号化チェック
		################################
		set boolEncrypted to ocidActivDoc's isEncrypted()
		if boolEncrypted is true then
			log strFileName & "暗号化されています"
			####ラベルを指定
			(ocidTagNameArray's addObjectsFromArray:{"PDF暗号化"})
			###ラベルを塗る 単色
			set numLabelNo to 7 as integer
			################################
			### 署名チェック
			################################
			####Attributesを読み込み（レコード形式）
			set ocidDocAttrDict to ocidActivDoc's documentAttributes()
			set ocidItemValue to (ocidDocAttrDict's valueForKey:"Producer")
			if (ocidItemValue as text) is "Acrobat Sign" then
				log strFileName & "はAcrobatで署名されています"
				####ラベルを指定
				(ocidTagNameArray's addObjectsFromArray:{"PDF署名済"})
				###ラベルを塗る 単色
				set numLabelNo to 4 as integer
			end if
		else
			log strFileName & "はセキュリティ設定されていません"
			set numLabelNo to 0 as integer
		end if
	end if
	####タグネームを付与
	(ocidFilePathURL's setResourceValue:(ocidTagNameArray) forKey:(refMe's NSURLTagNamesKey) |error|:(reference))
	###ラベルNOを付与
	(ocidFilePathURL's setResourceValue:numLabelNo forKey:(refMe's NSURLLabelNumberKey) |error|:(reference))
	####リソース解放
	set ocidActivDoc to ""
	set ocidDocAttrDict to ""
end repeat


return "処理終了"
