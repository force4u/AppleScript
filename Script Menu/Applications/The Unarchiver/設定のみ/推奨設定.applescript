#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#�A�[�J�C�u���[�e�B���e�B�̐����ݒ�
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##��������os12�Ȃ̂�2.8�ɂ��Ă��邾���ł�
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

###UTI
set listBundleID to {"com.apple.archiveutility", "com.macpaw.site.theunarchiver"} as list

tell application id strBundleID to quit

repeat with itemBundleID in listBundleID
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " createFolder -integer 2"
	do shell script strCommandText
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " extractionDestination -integer 1"
	do shell script strCommandText
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " folderModifiedDate -integer 2"
	do shell script strCommandText
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " LaunchCount -integer 0"
	do shell script strCommandText
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " filenameEncoding -integer 8"
	do shell script strCommandText
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " TUConfigInformationBannerViewedCount -integer 0"
	do shell script strCommandText
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " OnboardingUserViewedWelcomeSlide -bool true"
	do shell script strCommandText
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " SUEnableAutomaticChecks -bool true"
	do shell script strCommandText
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " userAgreedToNewTOSAndPrivacy -bool true"
	do shell script strCommandText
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " isFreshInstall -bool true"
	do shell script strCommandText
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " TUConfigInformationBannerOpened -bool true"
	do shell script strCommandText
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " deleteExtractedArchive -bool true"
	do shell script strCommandText
	set strCommandText to "/usr/bin/defaults write " & itemBundleID & " TUConfigInformationBannerOpened -bool true"
	do shell script strCommandText
end repeat
