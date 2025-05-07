#sqlを使いたいのでインポート
import sqlite3
#dbをディレクトリを指定したいのでインポート
import os
#numpyを使いたいのでインポート
import numpy as np
#質問の形式を得るためにインポート
from app.database.generate_database import QuestionCategory, AnswerValue

class Akinator:
    #アキネータークラス
    def __init__(self,questions : list[str] = None, answers : list[int] = None):
        
        current_dir = os.path.dirname(os.path.abspath(__file__))
        db_path = os.path.join(current_dir, 'database', 'CQA.db')
        #生成するsqliteの初期設定
        self.conn = sqlite3.connect(db_path)
        self.cursor = self.conn.cursor()
        
        self.beta = 12
        self.percent = 0.99
        self.A = [-1, -0.5, 0, 0.5, 1]
        #回答した質問の種類を記録する変数
        
        self.questions = questions
        if questions is None:
            #質問を初期化する
            self.questions = []   
            
        self.answers = answers
        if answers is None:
            #回答を初期化する
            self.answers = []
        
        self.state = 0
        if (not questions is None) and (not answers is None):
            self.update_state()
            
        #id_indexとindex_idを初期化する
        self.id_index = {}
        self.index_id = {}
        self.cursor.execute("SELECT card_id FROM cards;")
        index = 0
        for card_id in self.cursor.fetchall():
            self.id_index[card_id[0]] = index
            self.index_id[index] = card_id[0]
            index += 1
        
        self.card_count = len(self.index_id)
        
        self.H_i_n = np.zeros(self.card_count, dtype=np.float32)
        self.prev_H_i_n = np.zeros(self.card_count, dtype=np.float32)
        
        for i in range(len(self.questions)):
            self.update_H_i_n(self.questions[i],self.answers[i])
            if i == len(self.questions)-2:
                self.prev_H_i_n += self.H_i_n
            
        self.prev_H_i_n_sorted_index = np.argsort(self.prev_H_i_n)
    
    def update_H_i_n(self,question,player_answer):
        # question_idを取得
        self.cursor.execute("SELECT id, category, query FROM questions WHERE question_text = ?;", (question,))
        result = self.cursor.fetchone()
        if result is None:
            raise ValueError("Invalid question text.")

        question_id, category, query = result

        # YESとなるカードIDを取得し、set化（高速なO(1)参照のため）
        if category == QuestionCategory.SCRIPT.value:
            self.cursor.execute("SELECT card_id FROM answers WHERE question_id = ?;", (question_id,))
            yes_set = set(self.id_index[card_id[0]] for card_id in self.cursor.fetchall())
        elif category == QuestionCategory.CARDS.value:
            self.cursor.execute(f"SELECT card_id FROM cards WHERE {query};")
            yes_set = set(self.id_index[card_id[0]] for card_id in self.cursor.fetchall())

        # NumPy化された index_id を作成
        index_ids = np.array(list(self.index_id))

        # yes_set に含まれるかどうかのマスクを作成
        yes_mask = np.isin(index_ids, list(yes_set))

        # YES/NOの値をベクトルとして作成
        answers = np.where(yes_mask, AnswerValue.YES.value, AnswerValue.NO.value).astype(np.float32)
        
        player_answers = np.full(self.card_count,player_answer).astype(np.float32)
        
        # H_i_nをベクトル演算で更新
        self.H_i_n += (player_answers - answers) ** 2
            
    def update_state(self):
        for i in range(len(self.answers)):
            #stateを更新する関数
            if self.answers[i] == AnswerValue.YES.value or self.answers[i] == AnswerValue.PROBABLY.value:
                self.cursor.execute("SELECT new_state FROM questions WHERE question_text = ?;", (self.questions[i],))
                new_state = self.cursor.fetchone()
                if new_state:
                    self.state |= new_state[0]
            
    def get_card(self):
        #カードの確率を計算
        exp_values = np.exp(-self.beta * self.H_i_n)
        denominator = np.sum(exp_values)
            
        max_index = np.argmax(exp_values)
        max_p = exp_values[max_index] / denominator
        
        if max_p > self.percent:
            self.cursor.execute("SELECT name FROM cards WHERE card_id = ?;", (self.index_id[max_index],))
            card_name = self.cursor.fetchone()
            if card_name:
                return card_name[0]
            else:
                return None
        else:
            return None
    
    def get_question(self):
        #質問を取得する関数
        
        #質問を取り出す
        select_question_count = 100
        self.cursor.execute("SELECT id,question_text,category,query,unset_bit FROM questions;")
        questions = {id: [question_text,category,query, unset_bit] for id, question_text, category, query, unset_bit in self.cursor.fetchall()}
        if not self.questions is None:
            #厳選
            question_ids = [id for id in questions if (not questions[id][0] in self.questions) and (self.state & questions[id][3] == 0)]
        else:
            #厳選
            question_ids = [id for id in questions if self.state & questions[id][3] == 0]
        #ランダムに取り出す
        question_ids = np.random.choice(question_ids, size=select_question_count, replace=False)
        
        #絶対に含める質問
        must_question_ids = [66,67,68]
        
        if self.state & 7 == 0:
            #絶対にする質問を追加(モンスター、魔法、罠の特定)
            for question_id in must_question_ids:
                if (not question_id in question_ids) and (not questions[question_id][0] in self.questions):
                    question_ids = np.append(question_ids,question_id)
        
        #相互情報量が多い質問を選ぶ
        max_question_id = -1
        max_entropy = float('-inf')
        for question_id in question_ids:        
            # YESとなるカードIDを取得し、set化（高速なO(1)参照のため）
            if questions[question_id][1] == QuestionCategory.SCRIPT.value:
                self.cursor.execute("SELECT card_id FROM answers WHERE question_id = ?;", (question_id,))
                yes_set = set(self.id_index[card_id[0]] for card_id in self.cursor.fetchall())
            elif questions[question_id][1] == QuestionCategory.CARDS.value:
                self.cursor.execute(f"SELECT card_id FROM cards WHERE {questions[question_id][2]};")
                yes_set = set(self.id_index[card_id[0]] for card_id in self.cursor.fetchall())
                
            p = np.zeros(len(self.A), dtype=np.float32)
            for i in range(len(self.A)):
                p[i] = self.calculate_expression(self.A[i],question_id,questions[question_id][1],questions[question_id][2],yes_set = yes_set)
            entropy = self.shannon_entropy(p)
            
            if max_entropy < entropy:
                max_entropy = entropy
                max_question_id = question_id
        
        #質問を返す
        return questions[max_question_id][0]
    
    def calculate_expression(self,answer,question_id,category,query = None,yes_set = None):
        #sum_i\exp\{-\beta(a-\alpha_{q,i})^2-\beta \mathcal{H}_{i,{n-1}}\}の計算
        #すべてのカードは重いので、上位1000件を選ぶ
        top_n = 1000
        top_index = self.prev_H_i_n_sorted_index[:top_n]
        
        if yes_set is None:
            # YESとなるカードIDを取得し、set化（高速なO(1)参照のため）
            if category == QuestionCategory.SCRIPT.value:
                self.cursor.execute("SELECT card_id FROM answers WHERE question_id = ?;", (question_id,))
                yes_set = set(self.id_index[card_id[0]] for card_id in self.cursor.fetchall())
            elif category == QuestionCategory.CARDS.value:
                self.cursor.execute(f"SELECT card_id FROM cards WHERE {query};")
                yes_set = set(self.id_index[card_id[0]] for card_id in self.cursor.fetchall())
        
        alpha_values = np.array([AnswerValue.YES.value if cid in yes_set else AnswerValue.NO.value for cid in top_index], dtype=np.float32)
        
        # H_i_{n-1} を取得（top_indices に対応する H の値）
        H_values = self.prev_H_i_n[top_index]

        # 数式を NumPy ブロードキャストで計算
        diffs = answer - alpha_values
        exponent = -self.beta * (diffs ** 2 + H_values)
        result = np.exp(exponent)

        return np.sum(result)
        
    def shannon_entropy(self,P):
        #Shannonエントロピーを計算する関数  
        P = P[P > 0]
        return -np.sum(P * np.log2(P))

    def get_H_i_n(self):
        #H_i_nを取得する関数
        return self.H_i_n.tolist()
    
    def get_id_index(self):
        #id_indexを取得する関数
        return self.id_index

    def get_index_id(self):
        #index_idを取得する関数
        return self.index_id
    
    def get_state(self):
        #stateを取得する関数
        return self.state
    
    def get_prev_H_i_n(self):
        #prev_H_i_nを取得する関数
        return self.prev_H_i_n.tolist()

if __name__ == "__main__":
    akinator = Akinator()
    question = akinator.get_question()
    print(question)

    while True:
        akinator.questions.append(question)
        answer = int(input("answer: "))
        akinator.answers.append(answer)
        
        questions = akinator.questions
        answers = akinator.answers
        
        akinator = Akinator(questions,answers)
        card = akinator.get_card()
        if card is not None:
            print(card)
            break
        question = akinator.get_question()
        print(question)

        