# 1. ベースイメージを指定（ここではPython 3.9のスリムなイメージ）
FROM python:latest

# 2. 作業ディレクトリを作成し、そのディレクトリを指定
WORKDIR /app

# 3. requirements.txtをコンテナ内にコピーして、依存関係をインストール
COPY requirements.txt /app/

# 4. Flaskアプリケーションの依存ライブラリをインストール
RUN pip install --no-cache-dir -r requirements.txt

# 5. アプリケーションのソースコードをコンテナ内にコピー
COPY . /app/

# 6. コンテナのポート5000番を公開（Flaskのデフォルトポート）
EXPOSE 5000

# 7. アプリケーションを起動（Flaskの場合）
CMD ["python", "run.py"]