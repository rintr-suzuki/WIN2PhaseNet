#image指定
FROM python:3.6

# pythonのライブラリをインストールする
WORKDIR /usr/local/src/
COPY requirements.txt /usr/local/src/
RUN pip install -r requirements.txt

WORKDIR /data/PhaseNet