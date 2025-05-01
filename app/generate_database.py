"""
generate_database.py
カード、質問、回答のデータベースを作成するプログラム
以下の3つのテーブルを作成し、カード、質問、回答を追加、削除できるようにする
cardsテーブル
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    card_id INTEGER NOT NULL UNIQUE, -- card_id
    name TEXT NOT NULL  -- カード名
questionsテーブル
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    text TEXT NOT NULL UNIQUE,   -- 質問文
    catagory INTEGER NOT NULL   -- scriptかcards.cdbからなのか
answersテーブル
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    card_id INTEGER NOT NULL,   -- card_id
    question_id INTEGER NOT NULL,   -- 質問id
    answer INTEGER CHECK(answer IN (1, -1)) NOT NULL, -- 回答
    FOREIGN KEY (card_id) REFERENCES cards(card_id), -- cardsテーブルにあるcard_idしか使わない
    FOREIGN KEY (question_id) REFERENCES questions(id), -- questionsテーブルにあるidしか使わない
    UNIQUE(card_id, question_id)  -- 同じカードに同じ質問を複数登録しないよう制限
"""

#sqlを使いたいのでインポート
import sqlite3
#正規表現を使いたいのでインポート
import re
#enumを使いたいのでインポート
from enum import Enum
#dbを同じディレクトリにしたいのでインポート
import os
#jsonを扱うのでインポート
import json

class QuestionCatagory(Enum):
    #何から回答を判断するかどうか
    #スクリプトから(例:破壊効果を持ちますか？)
    SCRIPT = 0
    #cards.cdbから(例:モンスターですか？)
    DATABASE = 1

    
class AnswerValue(Enum):
    #回答がYES,NOのときの値
    YES = 1
    NO = -1


#データベースの名前
CARD_QUESTION_ANSWER_DB_NAME = "CQA.db"
#元からあるカードデータベース
CARD_DATABASE = "cards.cdb"
#質問と判断材料のjson
SCRIPT_TO_QUESTION_JSON = "script_to_question.json"
DATABASE_TO_QUESTION_JSON = "database_to_question.json"

class CardDb:
    def __init__(self,
                db_name = CARD_QUESTION_ANSWER_DB_NAME,
                carddb_name = CARD_DATABASE,
                script_json_name = SCRIPT_TO_QUESTION_JSON, 
                db_json_name = DATABASE_TO_QUESTION_JSON):
        #同じディレクトリになるようにpathを設定
        current_dir = os.path.dirname(os.path.abspath(__file__))
        db_path = os.path.join(current_dir, db_name)
        carddb_path = os.path.join(current_dir, carddb_name)
        script_json_path = os.path.join(current_dir, script_json_name)
        db_json_path = os.path.join(current_dir, db_json_name)
        
        #質問とluascriptのセットの読み込み
        self.script_json = self.read_json(script_json_path)
        
        #質問とcards.cdbのセットの読み込み
        self.db_json = self.read_json(db_json_path)
        
        #生成するsqliteの初期設定
        self.conn = sqlite3.connect(db_path)
        self.cursor = self.conn.cursor()
        self.create_tables()
        
        #元からあるデータベースの読み込みsqliteの初期設定
        self.cdbconn = sqlite3.connect(carddb_path)
        self.cdbcursor = self.conn.cursor()
        
    def read_json(filepath):
        #jsonの読み込み
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def create_tables(self):
        #cards,questions,answersテーブル作成
        self.cursor.execute("""
            CREATE TABLE IF NOT EXISTS cards (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                card_id INTEGER NOT NULL UNIQUE, --元々のcard_id
                card_name TEXT NOT NULL  --カード名
            )
        """)
        self.cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS questions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                question_text TEXT NOT NULL UNIQUE,   -- 質問文
                catagory INTEGER CHECK(catagory IN ({QuestionCatagory.SCRIPT.value}, {QuestionCatagory.DATABASE.value})) NOT NULL   -- 0-script,1-cards.cdb
            )
        """)
        self.cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS answers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                card_id INTEGER NOT NULL,   --元々もcard_id
                question_id INTEGER NOT NULL,   --questionテーブルのid
                answer INTEGER CHECK(answer IN ({AnswerValue.YES.value}, {AnswerValue.NO.value})) NOT NULL,  -質問の回答
                FOREIGN KEY (card_id) REFERENCES cards(id),
                FOREIGN KEY (question_id) REFERENCES questions(id),
                UNIQUE(card_id, question_id)  -- 同じカードに同じ質問を複数登録しないよう制限
            )
        """)
        self.conn.commit()

    def add_card(self,card_id,card_name):
        try:
            #cardsテーブルにカードの追加、answersテーブルにカード、質問、回答を追加
            self.cursor.execute("SELECT 1 FROM cards WHERE card_id = ?", (card_id,))
            result = self.cursor.fetchone()
            if not result:
                #cardsテーブルになければ追加
                self.cursor.execute("INSERT INTO cards (card_id,card_name) VALUES (?,?)", (card_id,card_name))        
            
            for question_id,question_text,catagory in self.get_all_question():
                #questionsテーブルからquestionを取り出し、answersテーブルにカード、質問、回答を追加
                self.cursor.execute("SELECT 1 FROM answers WHERE card_id = ? AND question_id = ?", (card_id,question_id))
                result = self.cursor.fetchone()
                if not result:
                    #answersテーブルにカード、質問、回答のセットがなければ追加
                    self.add_answer(card_id,question_id,self.get_answer(card_id,question_text,catagory))
            
            self.conn.commit()
            
        except Exception as e:
            #エラー発生時はロールバック
            self.conn.rollback()
            print(f"カード追加時にエラーが発生しました: {e}")
            
    def add_question(self,question_text,catagory):
        try:
            #cardsテーブルにカードの追加、answersテーブルにカード、質問、回答を追加
            self.cursor.execute("SELECT 1 FROM questions WHERE question_text = ?", (question_text,))
            result = self.cursor.fetchone()
            if not result:
                #questionsテーブルになければ追加
                self.cursor.execute("INSERT INTO questions (question_text,catagory) VALUES (?,?)", (question_text,catagory))        
            
            self.cursor.execute("SELECT id FROM questions WHERE question_text = ?", (question_text,))
            result = self.cursor.fetchone()[0]
            if result:
                #question_idの取得
                question_id = result[0]
            else:
                raise ValueError("question_idが取得できませんでした")
            
            for id,card_id,card_name in self.get_all_cards():
                #questionsテーブルからquestionを取り出し、answersテーブルにカード、質問、回答を追加
                self.cursor.execute("SELECT 1 FROM answers WHERE card_id = ? AND question_id = ?", (card_id,question_id))
                result = self.cursor.fetchone()
                if not result:
                    #answersテーブルにカード、質問、回答のセットがなければ追加
                    self.add_answer(card_id,question_id,self.get_answer(card_id,question_text,catagory))
            
            self.conn.commit()
            
        except Exception as e:
            #エラー発生時はロールバック
            self.conn.rollback()
            print(f"質問追加時にエラーが発生しました: {e}")
    
    def add_answer(self,card_id,question_id,answer):
        #answersテーブルにカード、質問、回答を追加
        self.cursor.execute("INSERT INTO answers (card_id,question_id,answer) VALUES (?,?,?)", (card_id,question_id,answer))
        self.conn.commit()
        
    def get_answer(self,card_id,question_text,catagory):
        #質問文から回答を返す
        if catagory == QuestionCatagory.SCRIPT.value:
            #scriptから質問の回答を判断
            with open("c"+card_id+".lua", "r", encoding="utf-8") as file:
                lua_text = file.read()
                for script_text in self.script_json[question_text]:
                    #質問文から特定のscriptの取り出し
                    if re.search[script_text,lua_text]:
                        #scriptに特定の文字列が含まれているかどうか
                        return True
                #含まれていないのでFalse
                return False
                    
        elif catagory == QuestionCatagory.DATABASE.value:
            #databaseから質問の回答を判断
            b = 1
            #self.cdbcursor.execute("SELECT 1 FROM datas WHERE id = ? AND ? = ?", (card_id,self.db_json[question_text][""],question_id))
        
    def get_all_question(self):
        #quesionsテーブルにあるすべての質問を返す
        self.cursor.execute("SELECT * FROM questions")
        return self.cursor.fetchall()
    
    def get_all_cards(self):
        #cardsテーブルにあるすべてのカードを返す
        self.cursor.execute("SELECT * FROM cards")
        return self.cursor.fetchall()

    def close(self):
        #閉じる
        self.conn.close()