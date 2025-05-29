# YugiohAkinator

YugiohAkinatorは、遊戯王カードを題材にしたWebアプリケーションです。  
ユーザーがいくつかの質問に答えていくことで、思い浮かべた遊戯王カードを推測します。

## 特徴

- 遊戯王カード版「アキネーター」  
- 質問に「はい」「たぶんそう」「わからない」「たぶん違う」「いいえ」などで答えていくと、カードを推測  
- データベースにはADSのカード情報・スクリプトを利用  
- アキネーターのロジックは[こちらのQiita記事](https://qiita.com/tsukemono/items/2a18e5d307a978e8ab09)を参考に実装


## 使用技術

- **言語**: Python, HTML, Lua
- **フレームワーク**: Flask, Bootstrap, Jinja2
- **データベース**: SQLite
- **インフラ**: Docker, Render(デプロイ)

## 公開URL

[https://yu-gi-ohakinator.onrender.com/](https://yu-gi-ohakinator.onrender.com/)

## ライセンス

- データベース、scriptはADS（Automatic Dueling System）のものを使用
- このソフトウェアは [GNU Affero General Public License v3.0](./COPYING.txt) のもとで公開されています