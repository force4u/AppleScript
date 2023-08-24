#!/bin/bash
#クリエイティブクラウドアプリを３０秒だけ起動して『同期』後終了させる
########################
###コマンドパス
STR_COMMAND_TEXT="/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app/Contents/MacOS/Creative Cloud"
###コマンド実行　バックグラウンドでshowwindow　にfalseのオプション入れて
"$STR_COMMAND_TEXT" --showwindow=false &
###プロセスIDの初期化
COMMAND_PID=$!
/bin/echo "プロセスID: $COMMAND_PID でコマンド実行"
sleep 30
/bin/echo "タイムアウト"
	###終了
if /bin/ps -p $COMMAND_PID >/dev/null; then
	/bin/kill -9 $COMMAND_PID
else
	/usr/bin/killall "Creative Cloud"
fi
##強制終了したので
/usr/bin/killall "Adobe Crash Handler"
/bin/echo "処理終了"

exit 0
