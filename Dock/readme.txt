コマンドラインからDockに項目を追加できます
登録
DockTool.applescript add 3 /some/app/path/some\ appname.app
DockTool.applescript add 3 "/some/app/path/some appname.app"
削除
DockTool.applescript.applescript del 3 del

エラーについて
"must be either `missing value' or `reference'; assuming `missing value'. "
が出でますが戻り値は正常です

エラーについて
exec format error: /path/to/some.applescript
が出る場合はスクリプトの文字コードがUTF16かMacRomanになっています
Cotediter等でUTF８に保存してから実行してください

