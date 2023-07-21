#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#要管理者権限
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set strURL to "https://cdn07.boxcdn.net/Autoupdate3.json" as text

set listUTI to {"com.box.desktop", "com.box.desktop.ui", "com.box.desktop.autoupdater", "com.box.desktop.helper", "com.box.Box-Device-Trust", "com.Box.BoxToolsCustomApps", "com.box.Box-Local-Com-Server", "com.Box.Box-Edit"} as list

####先に管理者モードにしておく
set strCommandText to ("/usr/bin/sudo  /bin/echo \"処理開始\"") as text
###
do shell script strCommandText with administrator privileges
###戻り値格納用のDICT
set ocidPkgDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###URL
set ocidURLString to (refMe's NSString's stringWithString:(strURL))
set ocidJsonURL to (refMe's NSURL's alloc()'s initWithString:(ocidURLString))
###JSON読み込み
set ocidOption to refMe's NSDataReadingMappedIfSafe
set listReadData to (refMe's NSData's dataWithContentsOfURL:(ocidJsonURL) options:(ocidOption) |error|:(reference))
set ocidJsonData to (item 1 of listReadData)
###JSON初期化 してレコードに格納
set listJSONSerialization to (refMe's NSJSONSerialization's JSONObjectWithData:(ocidJsonData) options:0 |error|:(reference))
set ocidJsonData to item 1 of listJSONSerialization
##rootのレコード
set ocidReadDict to (refMe's NSDictionary's alloc()'s initWithDictionary:(ocidJsonData))
set ocidMacDict to (ocidReadDict's objectForKey:("mac"))
set ocidEapDict to (ocidMacDict's objectForKey:("eap"))
set ocidPkgURL to (ocidEapDict's valueForKey:("download-url"))
set ocidVersion to (ocidReadDict's valueForKeyPath:("mac.eap.version"))
log ocidVersion as text
log ocidPkgURL as text
(ocidPkgDict's setValue:(ocidPkgURL) forKey:(ocidVersion))
###ダウンロード
set ocidURL to refMe's NSURL's URLWithString:(ocidPkgURL)
###ファイル名
set ocidFileName to ocidURL's lastPathComponent()
####NSDataで
set ocidPkgData to refMe's NSData's dataWithContentsOfURL:(ocidURL)
###保存先 ディレクトリ 起動時の削除される項目
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
###フォルダ作って
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###保存パス
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidFileName) isDirectory:false
###保存
set boolDone to ocidPkgData's writeToURL:(ocidSaveFilePathURL) atomically:(true)
###インストール用のパス
set strSaveFilePath to ocidSaveFilePathURL's |path|() as text
###関連プロセス終了
repeat with itemUTI in listUTI
	###NSRunningApplication
	set ocidRunningApplication to refMe's NSRunningApplication
	###起動中のすべてのリスト
	set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:(itemUTI))
	###複数起動時も順番に終了
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate()
	end repeat
end repeat
###通知のタイムラグを考慮して１秒まってから
delay 1
###コマンド整形
set strCommandText to ("/usr/bin/sudo /usr/sbin/installer -dumplog -verbose -pkg \"" & strSaveFilePath & "\" -target / -allowUntrusted -lang ja") as text
###実行
do shell script strCommandText with administrator privileges
###
return "処理終了"
