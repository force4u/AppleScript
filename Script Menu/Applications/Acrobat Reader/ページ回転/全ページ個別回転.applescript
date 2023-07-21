#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#　全ページ　各ページの回転を元に　追加で回転させます
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "PDFKit"
use framework "Quartz"
use scripting additions

property refMe : a reference to current application

##################################
#### 文書を開いているか？
##################################
tell application id "com.adobe.Reader"
	activate
	tell active doc
		set numAllPage to do script ("this.numPages;")
		try
			if numAllPage is "undefined" then
				error number -1708
			end if
		on error
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
			display alert "エラー:文書が選択されていません" buttons {"OK", "キャンセル"} default button "OK" as informational giving up after 10
			return "エラー:文書が選択されていません"
		end try
	end tell
end tell
#######################
#####Acraobatでの削除ページ指定
#######################
tell application id "com.adobe.Reader"
	activate
	##ファイルパス
	tell active doc
		set aliasFilePath to file alias
	end tell
	##開いているファイルのページ数
	tell active doc
		set numCntAllPage to (count every page) as integer
	end tell
	##表示中のページ番号
	tell active doc
		tell front PDF Window
			set numNowPage to page number as integer
			set numNowPageJs to numNowPage - 1 as integer
		end tell
	end tell
end tell
#######################
#####ダイアログ
#######################
tell application id "com.adobe.Reader"
	launch
	activate
	set numCancel to 0
	set numRote to 0
	do script ("var boolCancel = 0;")
	do script ("var doTheDialog = {initialize:function (dialog) {var numRote = \"\"; strAns1 = \"\";strAns2 = \"\";strAns3 = \"\";this.strError1 = \"１つ選んでください\";this.strError2 = \"中止する時はキャンセルしてください\";dialog.load({\"Err1\": this.strError1,});},commit: function (dialog) {var objResults = dialog.store();strAns1 = objResults[\"Ans1\"];strAns2 = objResults[\"Ans2\"];strAns3 = objResults[\"Ans3\"];},ok: function (dialog) {console.println(\"OKを実行しました\");},cancel: function (dialog) {boolCancel = 2; numRote = 0;},destroy: function (dialog) {console.println(\"ダイアログを閉じました\");},validate: function (dialog) {var objResults = dialog.store();console.println(\"objResults:\"+ objResults);strAns1 = objResults[\"Ans1\"];strAns2 = objResults[\"Ans2\"];strAns3 = objResults[\"Ans3\"];if (strAns1 === true) {return true;}else if (strAns2 === true) {return true;}else if (strAns3 === true) {return true;} else {dialog.load({\"Err1\": this.strError2});return false;}},description:{name: \"Dialog Box\",first_tab: \"Ans1\",width: 427,height: 190,elements:[{type: \"cluster\",align_children: \"align_top\",name: \"【" & numNowPage & "：ページの】回転角度を選んでください\",bold: true,width: 420,height: 80,elements: [{item_id: \"Ans1\",type: \"radio\",group_id:\"PageRote\",next_tab: \"Submit\",name: \"右90度回転\",font: \"dialog\",bold: true,italic: false,},{item_id: \"Ans2\",type: \"radio\",group_id:\"PageRote\",next_tab: \"Submit\",name: \"左90度回転\",font: \"dialog\",bold: true,italic: false,},{item_id: \"Ans3\",type: \"radio\",group_id:\"PageRote\",next_tab: \"Submit\",name: \"180度回転\",font: \"dialog\",bold: true,italic: false,}]}, {type: \"static_text\",item_id: \"Err1\",name: \"Err1\",char_width: 36,char_height: 16,height: 24,font: \"dialog\",bold: true,},{type: \"cluster\",width: 420,height: 50,alignment: \"align_center\",elements: [{item_id: \"Submit\",alignment: \"align_right\",type: \"ok_cancel\",ok_name: \"Ok\",cancel_name: \"Cancel\"}]}]}};")
	do script ("app.execDialog(doTheDialog);")
	do script ("if (strAns1 === true) {var numRote = \"90\";}else if (strAns2 === true) {var numRote = \"270\";}else if (strAns3 === true) {var numRote = \"180\";}")
	set numCancel to (do script ("boolCancel")) as integer
	set numRote to (do script ("numRote")) as integer
	
end tell
if numCancel is 2 then
	return "キャンセルしました"
end if

##################################
####一旦閉じる
##################################
tell application id "com.adobe.Reader"
	activate
	set objAvtivDoc to active doc
	tell objAvtivDoc
		set boolMode to modified
		###変更箇所があるなら保存する
		if boolMode is true then
			save
		end if
	end tell
	close objAvtivDoc
end tell

#######################
#####本処理
#######################
####パス
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:strFilePath
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidFilePath
####PDFファイルを格納
set ocidPDFDocument to refMe's PDFDocument's alloc()'s initWithURL:ocidFilePathURL
####念の為ページ数
set numAllPage to (ocidPDFDocument's pageCount()) as integer

#################################
##ページ順に処理
#################################
repeat with itemIntNo from 1 to (numAllPage) by 1
	###ページオブジェクトを取得
	set ocidPdfPage to (ocidPDFDocument's pageAtIndex:(itemIntNo - 1))
	set numNowRotation to (ocidPdfPage's |rotation|()) as integer
	#################################
	##今の回転を元に　設定する回転を決める
	#################################
	if numRote is 90 then
		if numNowRotation = 0 then
			set numNewRotation to 90 as integer
		else if numNowRotation = 90 then
			set numNewRotation to 180 as integer
		else if numNowRotation = 180 then
			set numNewRotation to 270 as integer
		else if numNowRotation = 270 then
			set numNewRotation to 0 as integer
		end if
	end if
	if numRote is 270 then
		if numNowRotation = 0 then
			set numNewRotation to 270 as integer
		else if numNowRotation = 90 then
			set numNewRotation to 0 as integer
		else if numNowRotation = 180 then
			set numNewRotation to 90 as integer
		else if numNowRotation = 270 then
			set numNewRotation to 180 as integer
		end if
	end if
	if numRote is 180 then
		if numNowRotation = 0 then
			set numNewRotation to 180 as integer
		else if numNowRotation = 90 then
			set numNewRotation to 270 as integer
		else if numNowRotation = 180 then
			set numNewRotation to 0 as integer
		else if numNowRotation = 270 then
			set numNewRotation to 90 as integer
		end if
	end if
	#################################
	###ページ回転設定する
	#################################
	(ocidPdfPage's setRotation:numNewRotation)
	
end repeat




#################################
#####保存する　
#################################
ocidPDFDocument's writeToURL:(ocidFilePathURL)
delay 1

#################################
#####アクロバットで開く
#################################
(*
open option
https://quicktimer.cocolog-nifty.com/icefloe/2023/03/post-bcc393.html
*)
set strOptionText to "page=" & numNowPage & "&zoom=top&view=Fit&pagemode=thumbs" as text
tell application id "com.adobe.Reader"
	activate
	tell front PDF Window
		open aliasFilePath options strOptionText
	end tell
	tell active doc
		tell front PDF Window
			set page number to numNowPage
		end tell
	end tell
end tell
