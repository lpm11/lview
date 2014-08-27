# lview
Lightweight viewer for Limechat (Win).

## 使い方
### Limechat マクロの設定
「マクロの設定 → 新規」より新たにマクロを作成。右クリックでサーバごとの有効状態を切り替えておく。

- ユーザ: `%me|*`
- コマンド: `Privmsg|Notice`
- チャンネル: (空)
- メッセージ: `http*.jpg|http*.png|http*.gif`
- 動作: `Execute`
- 動作の情報: `"(UrlHandler.exe へのフルパス)" %m`

### メインアプリの設定
`Main.exe` を起動するとタスクトレイに駐在する。タスクトレイから `Config` を選択すると、画像を表示するためのホットキーを設定できる。また、`Width` と `Height` より表示する最大サイズを指定できる。

## TODO
- UrlHandler をもうちょっと賢くする (Python で実装？)
- 複数画像に対応する
