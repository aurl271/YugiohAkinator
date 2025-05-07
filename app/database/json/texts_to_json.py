#cards.cdbのtextsの質問を生成
import sys
import io
import json
import os

#出力をutf-8に
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

#CardPool.jsonのパス
current_dir = os.path.dirname(os.path.abspath(__file__))
db_path = os.path.join(current_dir, "CardPool.json")
first = set()
last = set()
with open(db_path, 'r', encoding='utf-8') as f:
    #CardPool.jsonを開く
    j = json.load(f)
    for ruby in j["cards"]:
        #読みの頭文字と、末尾の文字を追加
        if "ruby" not in ruby:
            continue
        first.add(ruby['ruby'][0]) 
        last.add(ruby['ruby'][-1])
        
for char in first:
    #queryを出力
    print(f'    "カード名の【読み】が「{char}」で始まるカードですか？(公式データベースに準拠 大文字、小文字は区別するが全角、半角は区別しない 例:“罪宝狩りの悪魔“は「“」で始まる)":{{')
    print(f'        "query":"reading LIKE \'{char}%\'",')
    print(f'        "unset_bit":131072,')
    print(f'        "new_state":131072')
    print(f'    }},')


for char in last:
    #queryを出力
    print(f'    "カード名の【読み】が「{char}」で終わるカードですか？(公式データベースに準拠 大文字、小文字は区別するが全角、半角は区別しない 例:驚楽園の助手 ＜Delia＞は「＞」で終わる)":{{')
    print(f'        "query":"reading LIKE \'%{char}\'",')
    print(f'        "unset_bit":131072,')
    print(f'        "new_state":131072')
    print(f'    }},')

