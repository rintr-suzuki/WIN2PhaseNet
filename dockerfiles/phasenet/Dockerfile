#image指定
FROM python:3.11

# pythonのライブラリをインストールする
WORKDIR /usr/local/src/
COPY requirements.txt /usr/local/src/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# ライセンスの添付
WORKDIR /data/WIN2PhaseNet
COPY LICENSE /