"""
generate_database.py
カード、質問、回答のデータベースを作成するプログラム
以下の3つのテーブルを作成し、カード、質問、回答を追加、削除できるようにする
cardsテーブル
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    card_id INTEGER NOT NULL UNIQUE, -- card_id
    name TEXT NOT NULL  -- カード名
    reading TEXT -- カードの読み方
    desc TEXT NOT NULL -- テキスト
    setcode INTEGER NOT NULL -- テーマ指定
    type INTEGER NOT NULL -- カード種類
    atk INTEGER NOT NULL -- 攻撃力
    def INTEGER NOT NULL -- 守備力
    level INTEGER NOT NULL -- レベル
    race INTEGER NOT NULL -- 種族
    attribute INTEGER NOT NULL -- 属性
    
questionsテーブル
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    text TEXT NOT NULL UNIQUE,   -- 質問文
    category INTEGER NOT NULL   -- scriptかcardsテーブルからなのか
    query TEXT --  cardsテーブルから回答を判断するためのクエリ(scriptから判断する場合はNULL)
    unset_bit INTEGER NOT NULL DEFAULT 0,   -- ビットが立っていればこの質問はしない
    new_state INTEGER NOT NULL DEFAULT 0    -- 新しい状態にするためのビット
    
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

class QuestionCategory(Enum):
    #何から回答を判断するかどうか
    #スクリプトから(例:破壊効果を持ちますか？)
    SCRIPT = 0
    #cardsテーブルから判断(例:モンスターですか？)
    CARDS = 1

    
class AnswerValue(Enum):
    #回答がYES,NOのときの値
    YES = 1
    NO = -1
    PROBABLY = 0.5
    PROBABLY_NO = -0.5
    UNKNOWN = 0


#データベースの名前
CARD_QUESTION_ANSWER_DB_NAME = "CQA.db"
#元からあるカードデータベース
CARD_DATABASE = "cards.cdb"
#質問と判断材料のjson
SCRIPT_TO_QUESTION_JSON = "script_to_question.json"
CARDS_TO_QUESTION_JSON = "cards_to_question.json"
NAME_READING_JSON = "CardPool.json"

class CardDb:
    def __init__(self,
                db_name = CARD_QUESTION_ANSWER_DB_NAME,
                carddb_name = CARD_DATABASE,
                script_json_name = SCRIPT_TO_QUESTION_JSON, 
                cards_json_name = CARDS_TO_QUESTION_JSON,
                name_reading_json_name = NAME_READING_JSON):
        #同じディレクトリになるようにpathを設定
        current_dir = os.path.dirname(os.path.abspath(__file__))
        db_path = os.path.join(current_dir, db_name)
        carddb_path = os.path.join(current_dir, carddb_name)
        script_json_path = os.path.join(current_dir, 'json')
        cards_json_path = os.path.join(current_dir, 'json')
        name_reading_json_path = os.path.join(current_dir, 'json')
        script_json_path = os.path.join(script_json_path, script_json_name)
        cards_json_path = os.path.join(cards_json_path, cards_json_name)
        name_reading_json_path = os.path.join(name_reading_json_path, name_reading_json_name)
        
        #質問とluascriptのセットの読み込み
        self.script_json = self.read_json(script_json_path)
        
        #質問とdatasテーブルのセットの読み込み
        self.cards_json = self.read_json(cards_json_path)
        
        #カード名の読みの読み込み
        self.name_reading_json = self.read_json(name_reading_json_path)
        
        #生成するsqliteの初期設定
        self.conn = sqlite3.connect(db_path)
        self.cursor = self.conn.cursor()
        self.create_tables()
        
        #元からあるデータベースの読み込みsqliteの初期設定
        self.cdbconn = sqlite3.connect(carddb_path)
        self.cdbcursor = self.cdbconn.cursor()
        
    def read_json(self,filepath):
        try:
            #jsonの読み込み
            with open(filepath, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            #エラー発生時
            print(f"json読み込みエラー: {e}")
    
    def create_tables(self):
        try:
            #cards,questions,answersテーブル作成
            self.cursor.execute("""
                CREATE TABLE IF NOT EXISTS cards (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    card_id INTEGER NOT NULL UNIQUE,
                    name TEXT NOT NULL,
                    reading TEXT,
                    desc TEXT,
                    setcode INTEGER NOT NULL,
                    type INTEGER NOT NULL,
                    atk INTEGER NOT NULL,
                    def INTEGER NOT NULL,
                    level INTEGER NOT NULL,
                    race INTEGER NOT NULL,
                    attribute INTEGER NOT NULL
                )
            """)
            self.cursor.execute(f"""
                CREATE TABLE IF NOT EXISTS questions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    question_text TEXT NOT NULL UNIQUE,
                    category INTEGER CHECK(category IN ({QuestionCategory.SCRIPT.value}, {QuestionCategory.CARDS.value})) NOT NULL,
                    query TEXT,
                    unset_bit INTEGER NOT NULL DEFAULT 0,
                    new_state INTEGER NOT NULL DEFAULT 0
                )
            """)
            self.cursor.execute(f"""
                CREATE TABLE IF NOT EXISTS answers (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    card_id INTEGER NOT NULL,
                    question_id INTEGER NOT NULL,
                    answer INTEGER CHECK(answer IN ({AnswerValue.YES.value}, {AnswerValue.NO.value})) NOT NULL,
                    FOREIGN KEY (card_id) REFERENCES cards(id),
                    FOREIGN KEY (question_id) REFERENCES questions(id),
                    UNIQUE(card_id, question_id)
                )
            """)
            self.conn.commit()
        except Exception as e:
            #エラー発生時はロールバック
            self.conn.rollback()
            print(f"データベース生成時にエラーが発生しました: {e}")

    def add_card(self,card_id,card_name,card_reading,card_desc,card_setcode,card_type,card_atk,card_def,card_level,card_race,card_attribute):
        try:
            #cardsテーブルにカードの追加、answersテーブルにカード、質問、回答を追加
            self.cursor.execute("SELECT 1 FROM cards WHERE card_id = ?;", (card_id,))
            result = self.cursor.fetchone()
            if not result:
                #cardsテーブルになければ追加
                self.cursor.execute("INSERT INTO cards (card_id,name,reading,desc,setcode,type,atk,def,level,race,attribute) VALUES (?,?,?,?,?,?,?,?,?,?,?);", (card_id,card_name,card_reading,card_desc,card_setcode,card_type,card_atk,card_def,card_level,card_race,card_attribute))        
            
            for question_id,question_text in self.get_all_question_script():
                #questionsテーブルからquestionを取り出し、answersテーブルにカード、質問、回答を追加
                self.cursor.execute("SELECT 1 FROM answers WHERE card_id = ? AND question_id = ?;", (card_id,question_id))
                result = self.cursor.fetchone()
                if not result and self.get_script_answer(card_id,question_text) == AnswerValue.YES.value:
                    #answersテーブルにカード、質問、回答のセットがなければ追加
                    self.add_answer(card_id,question_id,AnswerValue.YES.value)
            
            self.conn.commit()
            
        except Exception as e:
            #エラー発生時はロールバック
            self.conn.rollback()
            print(f"カード追加時にエラーが発生しました: {e}")
            print(card_id,card_name)
            
    def add_question(self,question_text,category,query = None,unset_bit = 0,new_state = 0):
        try:
            #cardsテーブルにカードの追加、answersテーブルにカード、質問、回答を追加
            self.cursor.execute("SELECT 1 FROM questions WHERE question_text = ?;", (question_text,))
            result = self.cursor.fetchone()
            if not result:
                #questionsテーブルになければ追加
                self.cursor.execute("INSERT INTO questions (question_text,category,query,unset_bit,new_state) VALUES (?,?,?,?,?);", (question_text,category,query,unset_bit,new_state))        
            
            self.cursor.execute("SELECT id FROM questions WHERE question_text = ?;", (question_text,))
            result = self.cursor.fetchone()
            if result:
                #question_idの取得
                question_id = result[0]
            else:
                raise ValueError("question_idが取得できませんでした")
            
            if category == QuestionCategory.SCRIPT.value:   
                for card_id in self.get_all_cards_id():
                    #questionsテーブルからquestionを取り出し、answersテーブルにカード、質問、回答を追加
                    self.cursor.execute("SELECT 1 FROM answers WHERE card_id = ? AND question_id = ?;", (card_id,question_id))
                    result = self.cursor.fetchone()
                    if not result and self.get_script_answer(card_id,question_text) == AnswerValue.YES.value:
                        #answersテーブルにカード、質問、回答のセットがなければ追加
                        self.add_answer(card_id,question_id,AnswerValue.YES.value)
            
            self.conn.commit()
            
        except Exception as e:
            #エラー発生時はロールバック
            self.conn.rollback()
            print(f"質問追加時にエラーが発生しました: {e}")
            print(question_id,question_text,category,unset_bit,new_state)
    
    def add_answer(self,card_id,question_id,answer):
        try:
            #answersテーブルにカード、質問、回答を追加
            self.cursor.execute("INSERT INTO answers (card_id,question_id,answer) VALUES (?,?,?);", (card_id,question_id,answer))
        except Exception as e:
            #エラー発生時はロールバック
            self.conn.rollback()
            print(f"回答追加時にエラーが発生しました: {e}")
            print(card_id,question_id,answer)
        
    def get_script_answer(self,card_id,question_text):
        try:
            #scriptのパスの生成
            current_dir = os.path.dirname(os.path.abspath(__file__))
            script_path = os.path.join(current_dir, "script")
            script_path = os.path.join(script_path, f"c{card_id}.lua")
            if not os.path.isfile(script_path):
                #通常モンスターとかでスクリプトがない場合
                return AnswerValue.NO.value
            #scriptから質問の回答を判断
            with open(script_path, "r", encoding="utf-8") as file:
                lua_text = file.read()
                for script_text in self.script_json[question_text]:
                    #質問文から特定のscriptの取り出し
                    if re.search(script_text,lua_text):
                        #scriptに特定の文字列が含まれているかどうか
                        return AnswerValue.YES.value
                #含まれていないのでFalse
                return AnswerValue.NO.value
            
        except Exception as e:
            print(f"get_answer関数 エラー: {e}")
            print(card_id,question_text)
            return None
            
    def get_all_question_script(self):
        try:
            #quesionsテーブルにあるSCRIPTの質問を返す
            self.cursor.execute("SELECT id,question_text FROM questions WHERE category = ?;",(QuestionCategory.SCRIPT.value,))
            return self.cursor.fetchall()
        except Exception as e:
            print(f"{CARD_QUESTION_ANSWER_DB_NAME} 読み込みエラー: {e}")
            
    def get_all_cards_id(self):
        try:
            #cardsテーブルにあるcard_id,nameを返す
            self.cursor.execute("SELECT card_id FROM cards;")
            return [id[0] for id in self.cursor.fetchall()]
        except Exception as e:
            print(f"{CARD_QUESTION_ANSWER_DB_NAME} 読み込みエラー: {e}")
                
    def delete_card(self,card_id):
        try:
            #card_idの削除
            self.cursor.execute(f'DELETE FROM cards WHERE card_id = ?;',(card_id,))
            self.cursor.execute(f'DELETE FROM answers WHERE card_id = ?;',(card_id,))
        except Exception as e:
            print(f"delete_cardエラー: {e}")
            print(card_id)
            
    def delete_question(self,question_id):
        try:
            #question_idの削除
            self.cursor.execute(f'DELETE FROM questions WHERE card_id = ?;',(question_id,))
            self.cursor.execute(f'DELETE FROM answers WHERE question_id = ?;',(question_id,))
        except Exception as e:
            print(f"delete_cardエラー: {e}")
            print(question_id)
                
    def populate_from_sources(self):
        try:

            #名前と読みの辞書を作成
            name_to_reading = {}
            for card in self.name_reading_json["cards"]:
                if "name" not in card or "ruby" not in card :
                    continue
                name_to_reading[card["name"]] = card["ruby"]
            
            # cards.cdb からすべてのカードを読み込む処理
            self.cdbcursor.execute("SELECT id, name,desc FROM texts;")
            for card_id, card_name, card_desc in self.cdbcursor.fetchall():
                self.cdbcursor.execute("SELECT setcode, type, atk, def, level, race, attribute FROM datas WHERE id = ?;",(card_id,))
                card_data = self.cdbcursor.fetchone()
                #読みを取得
                if card_name in name_to_reading:
                    reading = name_to_reading[card_name]
                else:
                    #ないならNone
                    reading = None
                self.add_card(card_id, card_name,reading,card_desc,card_data[0],card_data[1],card_data[2],card_data[3],card_data[4],card_data[5],card_data[6])

            # script_to_question.json から質問を追加
            for question_text in self.script_json:
                self.add_question(question_text, QuestionCategory.SCRIPT.value)
            
            # database_to_question.json から質問を追加
            for question_text in self.cards_json:
                if isinstance(self.cards_json[question_text],dict):
                    self.add_question(question_text, QuestionCategory.CARDS.value,self.cards_json[question_text]["query"],self.cards_json[question_text]["unset_bit"],self.cards_json[question_text]["new_state"])
                else:
                    self.add_question(question_text, QuestionCategory.CARDS.value,self.cards_json[question_text])

        except Exception as e:
            print(f"cards.cdb 読み込みエラー: {e}")

    def close(self):
        self.conn.commit()
        self.cdbconn.commit()
        #閉じる
        self.cursor.close()
        self.conn.close()
        self.cdbcursor.close()
        self.cdbconn.close()


if __name__ == "__main__":
    #データベースの生成
    card_db = CardDb()
    #cards.cdbからデータを読み込む
    card_db.populate_from_sources()
    #閉じる
    card_db.close()