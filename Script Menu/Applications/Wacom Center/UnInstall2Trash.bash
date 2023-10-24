#!/bin/bash

########################################
###管理者インストールしているか？チェック
USER_WHOAMI=$(/usr/bin/whoami)
/bin/echo "実行したユーザーは：$USER_WHOAMI"
NUM_UID=$(/usr/bin/id -u)
/bin/echo "実行ユーザーIDは：" "$NUM_UID"
if [ "$USER_WHOAMI" != "root" ]; then
	/bin/echo "このスクリプトを実行するには管理者権限が必要です。"
	/usr/bin/printf "sudo で実行してください\n\n"
	### path to me
	SCRIPT_PATH="${BASH_SOURCE[0]}"
	/bin/echo "/usr/bin/sudo \"$SCRIPT_PATH\""
	/usr/bin/printf "\n  ↑  を実行してください\n\n"
	exit 1
else
	###実行しているユーザー名
	SUDO_USER=$(/bin/echo "$HOME" | /usr/bin/awk -F'/' '{print $NF}')
	/bin/echo "実行ユーザー：" "$SUDO_USER"
	NUM_UID=$(/usr/bin/sudo -u "$SUDO_USER" /usr/bin/id -u)
	/bin/echo "実行ユーザーIDは：" "$NUM_UID"
fi

################################################################
/usr/sbin/spctl --master-disable

/usr/bin/killall "WacomTouchDriver"
/usr/bin/killall "WacomTabletDriver"
/usr/bin/killall "Wacom Desktop Center"
/usr/bin/killall "TabletDriver"
/usr/bin/killall "com.wacom.DataStoreMgr"
/usr/bin/killall "com.wacom.IOManager"
/usr/bin/killall "com.wacom.UpdateHelper"

LIST_UTI=("com.wacom.DataStoreMgr" "com.wacom.FirmwareUpdater" "com.wacom.IOManager" "com.wacom.MultiTouch" "com.wacom.ProfessionalControlPanel" "com.wacom.RemoveTabletHelper" "com.wacom.RemoveWacomTablet" "com.wacom.TabletDriver" "com.wacom.TabletHelper" "com.wacom.UpdateHelper" "com.wacom.UpgradeHelper" "com.wacom.Wacom-Desktop-Center" "com.wacom.Wacom-Display-Settings" "com.wacom.WacomCenter" "com.wacom.WacomCenterPrefPane" "com.wacom.WacomExperienceProgram" "com.wacom.WacomTabletDriver" "com.wacom.WacomTouchDriver" "com.wacom.displayhelper" "com.wacom.wacomtablet" "com.wacom.DisplayMgr")

for ITEM_UTI in "${LIST_UTI[@]}"; do
	/bin/echo "$ITEM_UTI"
	STR_FILE_PATH="/Library/LaunchDaemons/$ITEM_UTI.plist"
	if [ -f "$STR_FILE_PATH" ]; then
		/bin/launchctl stop -w "$STR_FILE_PATH"
		/bin/launchctl unload -w "$STR_FILE_PATH"
		/bin/launchctl bootout -w "$STR_FILE_PATH"
		/bin/rm "$STR_FILE_PATH"
	fi
	STR_FILE_PATH="/Library/LaunchAgents/$ITEM_UTI.plist"
	if [ -f "$STR_FILE_PATH" ]; then
		/bin/launchctl stop -w "$STR_FILE_PATH"
		/bin/launchctl unload -w "$STR_FILE_PATH"
		/bin/launchctl bootout -w "$STR_FILE_PATH"
		/bin/rm "$STR_FILE_PATH"
	fi
done

################################################################
/bin/mkdir -p /var/folders/TemporaryItems
/bin/chmod -Rf 777 /var/folders/TemporaryItems

/sbin/kextunload -b "Wacom Tablet"
/sbin/kextunload -b "Pen Tablet"
/sbin/kextunload -b "SiLabsUSBDriver"
/sbin/kextunload -b "SiLabsUSBDriver64"

################################################################
#####古いファイルをゴミ箱に  LOCAL
function DO_MOVE_TO_TRASH() {
	if [ -e "$1" ]; then
		TRASH_DIR=$(/usr/bin/mktemp -d "/var/folders/TemporaryItems/XXXXXXXX")
		/bin/chmod 777 "$TRASH_DIR"
		/bin/mv "$1" "$TRASH_DIR"
		##削除
		/usr/bin/find "$TRASH_DIR" -mindepth 1 -delete
	fi
}
#####古いファイルをゴミ箱に  LOCAL

DO_MOVE_TO_TRASH "/Applications/Tablet.localized/RemoveTablet.app"
DO_MOVE_TO_TRASH "/Applications/Tablet.localized/.localized"
DO_MOVE_TO_TRASH "/Applications/Tablet.localized/.DS_Store"
DO_MOVE_TO_TRASH "/Applications/Wacom Tablet.localized/RemoveTablet.app"
DO_MOVE_TO_TRASH "/Applications/Wacom Tablet.localized/Wacom Desktop Center.app"
DO_MOVE_TO_TRASH "/Applications/Wacom Tablet.localized"

DO_MOVE_TO_TRASH "/Library/Application Support/Tablet/WacomTabletSpringboard"
DO_MOVE_TO_TRASH "/Library/Application Support/Tablet/WacomTabletDriver.app"
DO_MOVE_TO_TRASH "/Library/Application Support/Tablet/WacomTouchDriver.app"
DO_MOVE_TO_TRASH "/Library/Application Support/Tablet/TabletDriver.app"
DO_MOVE_TO_TRASH "/Library/Application Support/Tablet"
DO_MOVE_TO_TRASH "/Library/Application Support/Wacom"


DO_MOVE_TO_TRASH "/Library/Extensions/WacomTablet.kex"
DO_MOVE_TO_TRASH "/Library/Extensions/Wacom Tablet.kex"
DO_MOVE_TO_TRASH "/Library/Extensions/PenTablet.kext"
DO_MOVE_TO_TRASH "/Library/Extensions/Pen Tablet.kext"
DO_MOVE_TO_TRASH "/Library/Extensions/Tablet Driver.kext"
DO_MOVE_TO_TRASH "/Library/Extensions/TabletDriver.kext"
DO_MOVE_TO_TRASH "/Library/Frameworks/WacomMultiTouch.framework"

DO_MOVE_TO_TRASH "/Library/Internet Plug-Ins/WacomNetscape.plugin"
DO_MOVE_TO_TRASH "/Library/Internet Plug-Ins/WacomSafari.plugin"
DO_MOVE_TO_TRASH "/Library/Internet Plug-Ins/WacomTabletPlugin.plugin"


DO_MOVE_TO_TRASH "/Library/PreferencePanes/WacomTablet.prefpane"
DO_MOVE_TO_TRASH "/Library/PreferencePanes/WacomCenter.prefpane"
DO_MOVE_TO_TRASH "/Library/PreferencePanes/PenTablet.prefpane"
DO_MOVE_TO_TRASH "/Library/PreferencePanes/Tablet.prefPane"

DO_MOVE_TO_TRASH "/Library/Preferences/Tablet"
DO_MOVE_TO_TRASH "/Library/Receipts/InstallConsumerTablet.pkg"
DO_MOVE_TO_TRASH "/Library/Receipts/InstallSemiproTablet.pkg"
DO_MOVE_TO_TRASH "/Library/Receipts/InstallProTablet.pkg"

DO_MOVE_TO_TRASH "/Library/StartupItems/Tablet/TabetDriver.app"
DO_MOVE_TO_TRASH "/Library/StartupItems/Tablet/TabetDriverRelauncher"
DO_MOVE_TO_TRASH "/Library/StartupItems/Tablet/StartupParameters.plist"
DO_MOVE_TO_TRASH "/Library/StartupItems/Tablet"

DO_MOVE_TO_TRASH "/Library/LaunchDaemons/com.wacom.TabletHelper.plist"
DO_MOVE_TO_TRASH "/Library/LaunchAgents/com.wacom.DisplayMgr.plist"

DO_MOVE_TO_TRASH "/Library/Receipts/InstallConsumerTablet.pkg"
DO_MOVE_TO_TRASH "/Library/Receipts/InstallProTablet.pkg"
DO_MOVE_TO_TRASH "/Library/Receipts/InstallSemiproTablet.pkg"

DO_MOVE_TO_TRASH "/Library/PrivilegedHelperTools/com.wacom.TabletHelper.app"
DO_MOVE_TO_TRASH "/Library/PrivilegedHelperTools/com.wacom.DataStoreMgr.app"
DO_MOVE_TO_TRASH "/Library/PrivilegedHelperTools/com.wacom.IOManager.app"
DO_MOVE_TO_TRASH "/Library/PrivilegedHelperTools/com.wacom.UpdateHelper.app"

###USBドライバーは他で使ってないか？確認が必要かな
DO_MOVE_TO_TRASH "/Library/Extensions/SiLabsUSBDriver.kext"
DO_MOVE_TO_TRASH "/Library/Extensions/SiLabsUSBDriver64.kext"


for ITEM_UTI in "${LIST_UTI[@]}"; do
	/bin/echo "処理するUTI：" "$ITEM_UTI"
	STR_FILE_PATH="/Library/PrivilegedHelperTools/$ITEM_UTI.app"
	DO_MOVE_TO_TRASH "$STR_FILE_PATH"
	STR_FILE_PATH="/Library/Preferences/$ITEM_UTI.plist"
	DO_MOVE_TO_TRASH "$STR_FILE_PATH"
done

############################################################
###ローカルのユーザーアカウントを取得
TEXT_RESULT=$(/usr/bin/dscl localhost -list /Local/Default/Users PrimaryGroupID | /usr/bin/awk '$2 == 20 { print $1 }')
###リストにする
read -d '\\n' -r -a LIST_USER <<<"$TEXT_RESULT"
###リスト内の項目数
NUM_CNT=${#LIST_USER[@]}
/bin/echo "ユーザー数：" "$NUM_CNT"
############################################################
##リストの内容を順番に処理
for ITEM_USER in "${LIST_USER[@]}"; do
	/bin/echo "ITEM_USER:MKDIR:" "ITEM_USER"
	##ライブラリの不可視属性を解除
	/usr/bin/sudo -u "$ITEM_USER" /usr/bin/chflags nohidden "/Users/$ITEM_USER/Library"
	/usr/bin/sudo -u "$ITEM_USER" /usr/bin/SetFile -a v "/Users/$ITEM_USER/Library"
	##ユーザーアプリケーションフォルダを作る
	/usr/bin/sudo -u "$ITEM_USER" /bin/mkdir -p "/Users/$ITEM_USER/Applications"
	/usr/bin/sudo -u "$ITEM_USER" /bin/chmod 700 "/Users/$ITEM_USER/Applications"
	/usr/bin/sudo -u "$ITEM_USER" /usr/sbin/chown "$ITEM_USER" "/Users/$ITEM_USER/Applications"
	/usr/bin/sudo -u "$ITEM_USER" /usr/bin/touch "/Users/$ITEM_USER/Applications/.localized"
	##ユーザーユーティリティフォルダを作る
	/usr/bin/sudo -u "$ITEM_USER" /bin/mkdir -p "/Users/$ITEM_USER/Applications/Utilities"
	/usr/bin/sudo -u "$ITEM_USER" /bin/chmod 755 "/Users/$ITEM_USER/Applications/Utilities"
	/usr/bin/sudo -u "$ITEM_USER" /usr/sbin/chown "$ITEM_USER" "/Users/$ITEM_USER/Applications/Utilities"
	/usr/bin/sudo -u "$ITEM_USER" /usr/bin/touch "/Users/$ITEM_USER/Applications/Utilities/.localized"
	##　Managed Itemsフォルダを作る
	/usr/bin/sudo -u "$ITEM_USER" /bin/mkdir -p "/Users/$ITEM_USER/Library/Managed Items"
	/usr/bin/sudo -u "$ITEM_USER" /bin/chmod 755 "/Users/$ITEM_USER/Library/Managed Items"
	/usr/bin/sudo -u "$ITEM_USER" /usr/sbin/chown "$ITEM_USER" "/Users/$ITEM_USER/Library/Managed Items"
	/usr/bin/sudo -u "$ITEM_USER" /usr/bin/touch "/Users/$ITEM_USER/Library/Managed Items/.localized"
	##アクセス権チェック
	/usr/bin/sudo -u "$ITEM_USER" /bin/chmod 700 "/Users/$ITEM_USER/Library"
	/usr/bin/sudo -u "$ITEM_USER" /bin/chmod 777 "/Users/$ITEM_USER/Library/Caches"
	/usr/bin/sudo -u "$ITEM_USER" /bin/chmod 700 "/Users/$ITEM_USER/Movies"
	/usr/bin/sudo -u "$ITEM_USER" /bin/chmod 700 "/Users/$ITEM_USER/Music"
	/usr/bin/sudo -u "$ITEM_USER" /bin/chmod 700 "/Users/$ITEM_USER/Pictures"
	/usr/bin/sudo -u "$ITEM_USER" /bin/chmod 700 "/Users/$ITEM_USER/Downloads"
	/usr/bin/sudo -u "$ITEM_USER" /bin/chmod 700 "/Users/$ITEM_USER/Documents"
	/usr/bin/sudo -u "$ITEM_USER" /bin/chmod 700 "/Users/$ITEM_USER/Desktop"
	##全ローカルユーザーに対して実施したい処理があれば追加する

	/bin/echo "ユーザーディレクトリチェックDONE"
done
############################################################
##ユーザーエージェント停止
for ITEM_USER in "${LIST_USER[@]}"; do
	/bin/echo "ITEM_USER:MKDIR:" "$ITEM_USER"
	for ITEM_UTI in "${LIST_UTI[@]}"; do
		STR_FILE_PATH="/Users/$ITEM_USER/Library/LaunchAgents/$ITEM_UTI.plist"
		if [ -f "$STR_FILE_PATH" ]; then
			/usr/bin/sudo -u "$ITEM_USER" /bin/launchctl stop -w "$STR_FILE_PATH"
			/usr/bin/sudo -u "$ITEM_USER" /bin/launchctl unload -w "$STR_FILE_PATH"
			/usr/bin/sudo -u "$ITEM_USER" /bin/launchctl bootout -w "$STR_FILE_PATH"
			/usr/bin/sudo -u "$ITEM_USER" /bin/rm "$STR_FILE_PATH"
		fi
	done
done
############################################################
##ユーザー環境リセット
for ITEM_USER in "${LIST_USER[@]}"; do
	/bin/echo "ITEM_USER:ユーザー環境削除:" "$ITEM_USER"
	function DO_MOVE_TO_TRASH_USER() {
		if [ -e "$1" ]; then
			TRASH_DIR=$(/usr/bin/sudo -u "$ITEM_USER" /usr/bin/mktemp -d)
			/usr/bin/sudo -u "$ITEM_USER" /bin/chmod 777 "$TRASH_DIR"
			/usr/bin/sudo -u "$ITEM_USER" /bin/mv "$1" "$TRASH_DIR"
			##削除
			/usr/bin/sudo -u "$ITEM_USER" /usr/bin/find "$TRASH_DIR" -mindepth 1 -delete
		fi
	}
	for ITEM_UTI in "${LIST_UTI[@]}"; do
		DO_MOVE_TO_TRASH_USER "/Users/$ITEM_USER/Library/Application Scripts/EG27766DY7.$ITEM_UTI"
		DO_MOVE_TO_TRASH_USER "/Users/$ITEM_USER/Library/Application Scripts/$ITEM_UTI"
		DO_MOVE_TO_TRASH_USER "/Users/$ITEM_USER/Library/Caches/$ITEM_UTI"
		DO_MOVE_TO_TRASH_USER "/Users/$ITEM_USER/Library/WebKit/$ITEM_UTI"
		DO_MOVE_TO_TRASH_USER "/Users/$ITEM_USER/Library/Saved Application State/$ITEM_UTI.savedState"
		DO_MOVE_TO_TRASH_USER "/Users/$ITEM_USER/Library/HTTPStorages/$ITEM_UTI"
		DO_MOVE_TO_TRASH_USER "/Users/$ITEM_USER/Library/Containers/$ITEM_UTI"

		DO_MOVE_TO_TRASH_USER "/Users/$ITEM_USER/Library/Group Containers/group.EG27766DY7.$ITEM_UTI"
		DO_MOVE_TO_TRASH_USER "/Users/$ITEM_USER/Library/Group Containers/EG27766DY7.$ITEM_UTI"
		DO_MOVE_TO_TRASH_USER "/Users/$ITEM_USER/Library/Group Containers/$ITEM_UTI"
	done

done

############################################################
## TCCリセット
for ITEM_USER in "${LIST_USER[@]}"; do
	/bin/echo "ITEM_USER:TCCリセット:" "$ITEM_USER"
	for ITEM_UTI in "${LIST_UTI[@]}"; do
		/usr/bin/sudo -u "$ITEM_USER" /usr/bin/tccutil reset "$ITEM_UTI"
	done
done
exit 0
