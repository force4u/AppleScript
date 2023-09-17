#!/bin/bash
#com.cocolog-nifty.quicktimer.icefloe
#####################################

LIST_BUNDLEID=("cx.c3.theunarchiver" "com.macpaw.site.theunarchiver")

for ITEM_BUNDLEID in "${LIST_BUNDLEID[@]}"; do
/bin/echo "$ITEM_BUNDLEID"
	/usr/bin/defaults write "$ITEM_BUNDLEID" createFolder -integer 2
	/usr/bin/defaults write "$ITEM_BUNDLEID" extractionDestination -integer 1
	/usr/bin/defaults write "$ITEM_BUNDLEID" folderModifiedDate -integer 2
	/usr/bin/defaults write "$ITEM_BUNDLEID" LaunchCount -integer 0
	/usr/bin/defaults write "$ITEM_BUNDLEID" filenameEncoding -integer 8
	/usr/bin/defaults write "$ITEM_BUNDLEID" TUConfigInformationBannerViewedCount -integer 0
	/usr/bin/defaults write "$ITEM_BUNDLEID" OnboardingUserViewedWelcomeSlide -bool true
	/usr/bin/defaults write "$ITEM_BUNDLEID" SUEnableAutomaticChecks -bool true
	/usr/bin/defaults write "$ITEM_BUNDLEID" userAgreedToNewTOSAndPrivacy -bool true
	/usr/bin/defaults write "$ITEM_BUNDLEID" isFreshInstall -bool true
	/usr/bin/defaults write "$ITEM_BUNDLEID" TUConfigInformationBannerOpened -bool true
	/usr/bin/defaults write "$ITEM_BUNDLEID" deleteExtractedArchive -bool true
	/usr/bin/defaults write "$ITEM_BUNDLEID" TUConfigInformationBannerOpened -bool true
done

sleep 1

"/usr/bin/killall" cfprefsd

/bin/echo "Done"
exit 0
