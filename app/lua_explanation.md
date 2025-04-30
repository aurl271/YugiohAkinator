# scriptの解析
https://w.atwiki.jp/yamiorica/pages/635.html
- function c~~.initial_effect()で効果の宣言
- Effect.CreateEffect()で効果の作成
- RegisterEffect()は効果のセット
- GetHandler()はカードオブジェクトの取得?
# set～～関数
- SetDescription(aux.Stringid(id,0))でテキストのセット(第2引数が謎？)
- SetType()で誘発効果等の設定(https://w.atwiki.jp/yamiorica/pages/301.html)
- SetCode()で効果のトリガー(召喚時等)の設定(https://w.atwiki.jp/yamiorica/?cmd=word&word=EVENT_FREE_CHAIN&pageid=304)
- SetRange()で発動場所(手札等)の設定(https://w.atwiki.jp/yamiorica/?cmd=word&word=LOCATION_HAND&pageid=286)
- SetCountLimit()で発動回数の設定(第1引数で回数、第2引数でカードidで名称ターン1(②個目の効果とかはカードid+1の値を設定してる))
- SetCategory()で効果の大雑把種類分け(CATEGORY_DESTROYなら破壊)の設定(https://w.atwiki.jp/yamiorica/pages/305.html)
- SetProperty()で効果のオプション(タイミングを逃さない等)の設定(https://w.atwiki.jp/yamiorica/?cmd=word&word=EFFECT_FLAG_DELAY&pageid=302)
- SetCost()はコストの設定
- SetOperation()は効果の細かい設定
- SetCondition()は~~発動条件~~適用条件の設定
- SetTarget()は対象の設定
- SetReset()は効果のリセットタイミング(エンドフェイズ等)の設定(https://w.atwiki.jp/yamiorica/?cmd=word&word=RESET_PHASE&pageid=300)

# メモ
- EFFECT_SET_SUMMON_COUNT_LIMITは召喚権の増加(サモンチェーンとかのパターン)