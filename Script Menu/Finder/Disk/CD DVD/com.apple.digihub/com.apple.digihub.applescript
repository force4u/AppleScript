#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


###############################################
###Plist編集

##########################################
###【１】パスURL
set strFilePath to "~/Library/Preferences/com.apple.digihub.plist"
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath)

##########################################
### 【２】PLISTを可変レコードとして読み込み
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL)

##########################################
### 【３】処理はここで
set ocidBlankCdDict to ocidPlistDict's objectForKey:("com.apple.digihub.blank.cd.appeared")
set ocidBlankDvdDict to ocidPlistDict's objectForKey:("com.apple.digihub.blank.dvd.appeared")
set ocidMusicCdDict to ocidPlistDict's objectForKey:("com.apple.digihub.cd.music.appeared")
set ocidPictureCdDict to ocidPlistDict's objectForKey:("com.apple.digihub.cd.music.appeared")
set ocidVideoDvdDict to ocidPlistDict's objectForKey:("com.apple.digihub.dvd.video.appeared")
(* ###Set action 
1=無視  
2=動作を確認 
5=otherapp他のアプリケーションで開く　
6=otherscriptスクリプトを実行　
100=Finder 
101=Music 
102=ディスクユーティティ
*)
ocidBlankCdDict's setValue:(1) forKey:("action")
ocidBlankDvdDict's setValue:(1) forKey:("action")
ocidMusicCdDict's setValue:(1) forKey:("action")
ocidPictureCdDict's setValue:(1) forKey:("action")
ocidVideoDvdDict's setValue:(1) forKey:("action")

set ocidSetDict to refMe's NSDictionary's dictionaryWithDictionary:({|_CFURLStringType|:15, |_CFURLString|:"file:///System/Library/CoreServices/Finder.app/"})
ocidBlankCdDict's setObject:(ocidSetDict) forKey:("otherapp")
ocidBlankDvdDict's setObject:(ocidSetDict) forKey:("otherapp")
ocidMusicCdDict's setObject:(ocidSetDict) forKey:("otherapp")
ocidPictureCdDict's setObject:(ocidSetDict) forKey:("otherapp")
ocidVideoDvdDict's setObject:(ocidSetDict) forKey:("otherapp")

set ocidSetDict to refMe's NSDictionary's dictionaryWithDictionary:({|_CFURLStringType|:15, |_CFURLString|:"file:///Library/Scripts/FOOHOGE.applescript"})
ocidBlankCdDict's setObject:(ocidSetDict) forKey:("otherscript")
ocidBlankDvdDict's setObject:(ocidSetDict) forKey:("otherscript")
ocidMusicCdDict's setObject:(ocidSetDict) forKey:("otherscript")
ocidPictureCdDict's setObject:(ocidSetDict) forKey:("otherscript")
ocidVideoDvdDict's setObject:(ocidSetDict) forKey:("otherscript")


##########################################
####【４】保存 ここは上書き
set boolDone to ocidPlistDict's writeToURL:(ocidFilePathURL) atomically:true

log boolDone

return "処理終了"




