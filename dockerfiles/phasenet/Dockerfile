#image指定
FROM tensorflow/tensorflow

# pythonのライブラリをインストールする
RUN pip install tqdm obspy pandas 
RUN pip install uvicorn fastapi

# ライセンスの添付
WORKDIR /data/PhaseNet
COPY LICENSE /