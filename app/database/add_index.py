import sqlite3
import os
db_name = 'CQA.db'
current_dir = os.path.dirname(os.path.abspath(__file__))
db_path = os.path.join(current_dir, db_name)
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Create a new index on the 'cards' table
cursor.execute("CREATE INDEX index_card_id ON cards(card_id);")
cursor.execute("CREATE INDEX index_reading ON cards(reading);")
cursor.execute("CREATE INDEX index_setcode ON cards(setcode);")
cursor.execute("CREATE INDEX index_type ON cards(type);")
cursor.execute("CREATE INDEX index_atk ON cards(atk);")
cursor.execute("CREATE INDEX index_def ON cards(def);")
cursor.execute("CREATE INDEX index_level ON cards(level);")
cursor.execute("CREATE INDEX index_race ON cards(race);")
cursor.execute("CREATE INDEX index_attribute ON cards(attribute);")
cursor.execute("CREATE INDEX index_question_id ON answers(question_id);")