# 1. Pythonのベースイメージ
FROM python:latest

# 2. 作業ディレクトリを設定
WORKDIR /app

# 3. requirements をコピーしてインストール
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# 4. アプリ本体をコピー
COPY . /app/

# 5. ポートを公開（Render向け）
EXPOSE 5000

# 6. gunicornでFlaskアプリを起動
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "run:app"]
