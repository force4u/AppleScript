#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#�@
(*
�t�@�C���̕\����؂�ւ��܂�
*)
#
#
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

try
	---AppleShowAllFiles�𒲂ׂ�
	set numResponce to (do shell script "defaults read  com.apple.finder AppleShowAllFiles") as number
	---�P�Ȃ�
	if numResponce = 1 then
		---�s���t�@�C����\�����Ȃ��ɕύX
		do shell script "defaults write  com.apple.finder AppleShowAllFiles -bool NO"
	else
		---�s���t�@�C����\������ɕύX
		do shell script "defaults write  com.apple.finder AppleShowAllFiles -bool YES"
	end if
on error
	---�G���[������������Ƃ肠�����@�s���t�@�C����\�����Ȃ��ɕύX
	do shell script "defaults write  com.apple.finder AppleShowAllFiles -bool NO"
end try
---�t�@�C���_�[���ċN�����ĕ\�����m��
do shell script "killall Finder"