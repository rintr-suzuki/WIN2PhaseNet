#image指定
FROM centos:centos7

# fortran-9をインストールする
## パッケージのダウンロード
WORKDIR /usr/local/src/
RUN curl -LO http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-9.2.0/gcc-9.2.0.tar.gz
RUN curl -LO http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-9.2.0/sha512.sum
#RUN sha512sum --check sha512.sum
## インストール用の基礎アプリケーションインストール
RUN yum install -y make gcc gcc-c++ wget bzip2 zip
## パッケージの解凍
RUN tar xzfv gcc-9.2.0.tar.gz -C /usr/local/src
## コンパイルとインストール
WORKDIR /usr/local/src/gcc-9.2.0/
RUN ./contrib/download_prerequisites
RUN mkdir build
WORKDIR /usr/local/src/gcc-9.2.0/build
RUN /usr/local/src/gcc-9.2.0/configure --enable-languages=c,c++,fortran --prefix=/usr/local --disable-bootstrap --disable-multilib
RUN make && make install
## パスの設定
WORKDIR /etc/ld.so.conf.d
RUN echo /usr/local/lib64 > usr-local-lib64.conf
RUN ldconfig -v

# python3をインストールする
WORKDIR /usr/local/src/
RUN yum install -y python3
RUN pip3 install --upgrade pip
RUN pip3 install cython
RUN pip3 install numpy
RUN pip3 install pandas tqdm

# win2npzをインストールする
WORKDIR /usr/local/src/
COPY win2npz.tar.gz /usr/local/src/
RUN tar xzfv win2npz.tar.gz -C /usr/local/src
WORKDIR /usr/local/src/win2npz/
RUN make
ENV PATH $PATH:/usr/local/src/win2npz/

# ライセンスの添付
WORKDIR /data/win2npz
COPY LICENSE /

#cf. 
#https://www.server-memo.net/memo/gcc-install.html
#http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-9.2.0/