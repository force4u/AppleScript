#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

##デスクトップ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
###
set strDateNO to doGetDateNo("yyyyMMdd") as text
###作成するパス
set ocidMakeDirPathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strDateNO)


############################
#####属性を指定しておく
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set numUID to user ID of (system info) as number
###所有者ID
ocidAttrDict's setValue:numUID forKey:(refMe's NSFileOwnerAccountID)
###グループID
ocidAttrDict's setValue:80 forKey:(refMe's NSFileGroupOwnerAccountID)
#####NSFileGroupOwnerAccountID
(* ゲストのGID
80-->admin
20-->staff
201-->_guest
99-->_unknown
-2-->nobody
*)
####パーミッション
set numPermissionDem to doOct2Dem(777) as integer
log numPermissionDem
ocidAttrDict's setValue:numPermissionDem forKey:(refMe's NSFilePosixPermissions)
###作るフォルダの属性
(*
###主要なモード NSFilePosixPermissions
777-->511
775-->509
770-->504
755-->493
750-->488
700-->448
555-->365
333-->219
*)
ocidAttrDict's setValue:(refMe's NSFileProtectionNone) forKey:(refMe's NSFileProtectionKey)
ocidAttrDict's setValue:0 forKey:(refMe's NSFileAppendOnly)

############################
###フォルダを作る
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidMakeDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

############################
####ラベルを指定する場合
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
set listDone to ocidMakeDirPathURL's setResourceValue:0 forKey:(refMe's NSURLLabelNumberKey) |error|:(reference)
log item 1 of listDone
############################
####コメントの追加
set aliasDirPath to (ocidMakeDirPathURL's absoluteURL()) as alias
set strCommentText to ("作成: " & strDateNO) as text
tell application "Finder" to set comment of item aliasDirPath to strCommentText


###################################
#####日付
###################################
to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to refMe's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to refMe's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo


###################################
#####パーミッション　８進→１０進
###################################
to doOct2Dem(argOctNo)
	set strOctalText to argOctNo as text
	set num3Line to first item of strOctalText as number
	set num2Line to 2nd item of strOctalText as number
	set num1Line to last item of strOctalText as number
	set numDecimal to (num3Line * 64) + (num2Line * 8) + (num1Line * 1)
	return numDecimal
end doOct2Dem
