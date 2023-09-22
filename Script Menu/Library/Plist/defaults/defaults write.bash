#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
##################################################
##新規作成
/usr/bin/plutil -create xml1 "$HOME/Desktop/some.plist"
##
/usr/bin/defaults write "$HOME/Desktop/some.plist" someStr -string "テキスト情報"
/usr/bin/defaults write "$HOME/Desktop/some.plist" someInt-A -integer 100
/usr/bin/defaults write "$HOME/Desktop/some.plist" someInt-B -integer 0
/usr/bin/defaults write "$HOME/Desktop/some.plist" someInt-C -integer -100
/usr/bin/defaults write "$HOME/Desktop/some.plist" someNumber-A -float 10.25
/usr/bin/defaults write "$HOME/Desktop/some.plist" someNumber-B -float 0.0
/usr/bin/defaults write "$HOME/Desktop/some.plist" someNumber-C -float -10.25
/usr/bin/defaults write "$HOME/Desktop/some.plist" someBool-A -boolean true
/usr/bin/defaults write "$HOME/Desktop/some.plist" someBool-B -boolean false
/usr/bin/defaults write "$HOME/Desktop/some.plist" someBool-C -boolean yes
/usr/bin/defaults write "$HOME/Desktop/some.plist" someBool-D -boolean no
##
STR_DATE=$(/bin/date)
/usr/bin/defaults write "$HOME/Desktop/some.plist" someDate -date "$STR_DATE"
##Array
/usr/bin/defaults write "$HOME/Desktop/some.plist" someArray-A -array
/usr/bin/defaults write "$HOME/Desktop/some.plist" someArray-B -array "AAAA" "BBBB" "CCCC" "DDDD"
/usr/bin/defaults write "$HOME/Desktop/some.plist" someArray-C -array "(1111,2222,3333,4444 )" "(AAAA,BBBB,CCCC,DDDD )"
/usr/bin/defaults write "$HOME/Desktop/some.plist" someArray-D -array "(1111,2222,3333,(555,666,777,888))" "((EEE,FFF,GGG,HHH),BBBB,CCCC,DDDD )"
/usr/bin/defaults write "$HOME/Desktop/some.plist" someArray-E -array "(1111,2222,3333,{444=EEE; 555=GGG;})" "(AAAA,BBBB,CCCC,DDDD )"
##
/usr/bin/defaults write "$HOME/Desktop/some.plist" someArray-F -array
/usr/bin/defaults write "$HOME/Desktop/some.plist" someArray-F -array-add -string "AAAAA"
/usr/bin/defaults write "$HOME/Desktop/some.plist" someArray-F -array-add -integer 11111
/usr/bin/defaults write "$HOME/Desktop/some.plist" someArray-F -array-add "(AAA,BBB)"
/usr/bin/defaults write "$HOME/Desktop/some.plist" someArray-F -array-add "{CCC=DDD; EEE=FFF;}"
##Dict
/usr/bin/defaults write "$HOME/Desktop/some.plist" someDict-A -dict
/usr/bin/defaults write "$HOME/Desktop/some.plist" someDict-B -dict "AAA" "BBB" "CCC" "DDD"
/usr/bin/defaults write "$HOME/Desktop/some.plist" someDict-C -dict "AAA" "BBB" "CCC" "(1111,2222,3333,4444)"
/usr/bin/defaults write "$HOME/Desktop/some.plist" someDict-D -dict "AAA" "BBB" "CCC" "{DDD=EEE; FFF=GGG;}"
###
/usr/bin/defaults write "$HOME/Desktop/some.plist" someDict-E -dict
/usr/bin/defaults write "$HOME/Desktop/some.plist" someDict-E -dict-add "AAAAA" -string "BBBBB"
/usr/bin/defaults write "$HOME/Desktop/some.plist" someDict-E -dict-add "BBBBB" "(1111,2222,3333,4444)"
/usr/bin/defaults write "$HOME/Desktop/some.plist" someDict-E -dict-add "CCCCC" "{DDD=EEE; FFF=GGG;}"
###
/usr/bin/defaults write "$HOME/Desktop/some.plist" someDict-E "{AAAAA = BBBBB;BBBBB = (1111,2222,3333,ZZZZ);CCCCC = {DDD = ZZZZ;FFF = GGG;};}"
exit 0

