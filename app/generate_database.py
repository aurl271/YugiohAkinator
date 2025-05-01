import sqlite3

"""
cardid.db,question.db,answer.dbを作る
cardid.dbは
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cardid INTEGER NOT NULL UNIQUE, -- cardid
    name TEXT NOT NULL  -- カード名
question.db
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    text TEXT NOT NULL UNIQUE,   -- 質問文
    catagory INTEGER NOT NULL   -- scriptかcards.cdbからなのか
answer.db
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    card_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    answer INTEGER  CHECK(answer IN (1, -1)) NOT NULL,
    FOREIGN KEY (card_id) REFERENCES cards(id),
    FOREIGN KEY (question_id) REFERENCES questions(id),
    UNIQUE(card_id, question_id)  -- 同じカードに同じ質問を複数登録しないよう制限
"""
