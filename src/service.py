import os
import glob
import numpy as np
import pandas as pd
import subprocess as sp
import datetime

from util import count_non_nan, load_csv
from model import WinWavedata, NpzStationWavedata

class Converter(object):
    def __init__(self, fname, indir, outdir, params=None):
        self._indir = indir
        self._fname = os.path.join(self._indir, fname)
        self._outdir = outdir
        os.makedirs(self._outdir, exist_ok=True)
    
    @property
    def outdir(self):
        return self._outdir

# 1 winfile -> n npzfile (n=station)
# win2npz.fを実行するクラス
class NpzConverter(Converter):
    def __init__(self, fname, indir, outdir, stndir, listname, params):
        super().__init__(fname, indir, outdir, params)
        self._wavedata = WinWavedata(fname)
        
        # make station list for each event
        fname = self._wavedata.fname; baseFname = self._wavedata.baseFname; stnlst = params['stnlst']
        os.makedirs(stndir, exist_ok=True)
        if listname is not None:
            df = load_csv(listname)
        stn_df = load_csv(stnlst, header=None)

        each_stnlst_list = []
        each_stnlst = os.path.join(stndir, "stn_%s.lst" % baseFname)
        with open(each_stnlst, 'w'):
            pass
        with open(each_stnlst, 'a') as f:
            for stn_value in stn_df[0]:
                if stn_value not in ["N.HD2H", "N.MORH", "N.TRUH"]: #3成分そろっていない等で使えない観測点は除く
                    if listname is not None:
                        if len(df[(df['win_name'] == baseFname) & (df['station'] == stn_value)]) == 0:
                            # To save time, only convert paticular station with picks if there is pick listpython
                            continue
                    f.write(stn_value)
                    f.write("\n")
                    each_stnlst_list.append(stn_value)
    
        self._stnlst = each_stnlst
        self._stations = each_stnlst_list
        self._chtbl = params['chtbl']
        self._length = params['length']

        self._rotation = params['rotation']
        self._filter = params['filter']
        self._rottbl = params['rottbl']
        self._filprm = params['filprm']

        self._outdir = os.path.join(self._outdir, baseFname)
        os.makedirs(self._outdir, exist_ok=True)

        self._outfiles = None

        print("[NpzConverter.__init__]:", baseFname)

    @property
    def outfiles(self):
        return self._outfiles

    @property
    def stations(self):
        return self._stations

    def to_npz(self):
        # win2npz
        com = "./win2npz.x" \
            + ' -w %s' % self._wavedata.fname \
            + ' -s %s' % self._stnlst \
            + ' -k %s' % self._chtbl \
            + ' -d %s' % self._outdir \
            + ' -t %s' % self._length
        if self._rotation:
            com = com + ' -r %s' % self._rottbl
        if self._filter:
            com = com + ' -f %s' % self._filprm
        print("[NpzConverter.to_npz]:", com)

        filetime = self._wavedata.filetime

        ## needs fortran ##
        proc = sp.run(com, shell=True, stdout = sp.PIPE, stderr = sp.STDOUT) #be careful for shell injection!!
        out = proc.stdout.decode("utf8")
        outfilesOrgNames = glob.glob(os.path.join(self._outdir, '*' + '.npz'))
        # ファイル名がwin2npz.xで変わってしまうので、修正する
        for outfilesOrgName in outfilesOrgNames:
            outfilesDir = os.path.dirname(outfilesOrgName)
            outfilesBase = filetime + '_' + os.path.basename(outfilesOrgName).rstrip('.npz').split('_')[1] + '.npz'
            outfilesName = os.path.join(outfilesDir, outfilesBase)
            os.rename(outfilesOrgName, outfilesName)
        print("[NpzConverter.to_npz]: win2npz.x", out)
        ##############

        # ## for test ##
        # for filestn in self._stations:
        #     out = filetime + "_" + filestn
        #     outfile = out + ".npz"
        #     array = np.random.rand(18000, 3)
        #     np.savez(os.path.join(self._outdir, outfile), data=array)
        #     print("[NpzConverter.to_npz]:", out)
        # ##############

        self._outfiles = glob.glob(os.path.join(self._outdir, filetime + '*' + '.npz'))
        self._stations = [os.path.basename(fname).rstrip('.npz').split('_')[1] for fname in self._outfiles]

# npzファイルのおさまったディレクトリを受け取ってフォーマットの修正を行うクラス
class NpzProcessor(Converter):
    def __init__(self, fname, indir, outdir, params):
        super().__init__(fname, indir, outdir, params)

# n npzfile -> n npzfile
class NpzStationProcessor(NpzProcessor):
    def __init__(self, fname, indir, outdir, params, npzinfo):
        super().__init__(fname, indir, outdir, params)
        self._wavedata = NpzStationWavedata(fname, npzinfo) #stations, outfiles->npzdataとして格納

        print("[NpzProcessor.__init__]:", self._wavedata.baseFname, "stations:", len(self._wavedata.npzdata.keys()))

    def set_time(self, listname):
        # 検測値リスト読み込み・処理するイベントに対応する部分だけ抜粋
        fname = self._wavedata.baseFname
        df = load_csv(listname).loc[[fname]]

        # stationをkeyとするdictに変換
        itdict = df.set_index('station', drop=False).to_dict()

        self._wavedata.itp = itdict['itp']
        self._wavedata.its = itdict['its']
        print("[NpzProcessor.set_time]:", self._wavedata.baseFname, "itp:", count_non_nan(self._wavedata.itp.values()), "its:", count_non_nan(self._wavedata.its.values()))
    
    def cut_wave(self, mode):
        npzdata = self._wavedata.npzdata
        stnlist = npzdata.keys()

        t0_dt = self._wavedata.t0_dt
        itp = self._wavedata.itp
        its = self._wavedata.its

        # calc cut point and revise itp and its
        #波形を切り出した場合、t0, itp, itsの時間がずれるので、startの時間に併せて補正
        if mode == "test":
            bf_p = 100; length = 3000
        elif mode == "train":
            bf_p = 3000; length = 9000
        else:
            print("[Error: mode is invalid]:", mode, "mode should be 'train' or 'test'")
        # t0
        self._wavedata.t0_dt = t0_dt - datetime.timedelta(milliseconds=bf_p)

        # itp, its
        flag = {}; skip = {}; start = {}; end = {}; itp1 = {}; its1 = {}
        for stn in stnlist:
            skip[stn] = []
            if not pd.isna(itp.get(stn)) and not pd.isna(its.get(stn)):
                start[stn] = itp[stn] - bf_p; end[stn] = start[stn] + length
                itp1[stn] = bf_p; its1[stn] = its[stn] - start[stn]
                if (start[stn] >= 0) and (its1[stn] <= length) and (end[stn] <= npzdata[stn].shape[0]):
                    flag[stn] = True
                    skip[stn].append(0)
                else:
                    flag[stn] = False
                    # 3. itpが波形の開始時刻に近すぎて、startが波形データの存在しない範囲になる場合
                    if not (start[stn] >= 0):
                        skip[stn].append(3)
                    # 4. itsが波形の終了時刻に近すぎて、itsが波形データの存在しない範囲になる場合
                    if not (its1[stn] <= length):
                        skip[stn].append(4)
                    # 5. 波形データが短すぎて、endが波形データの存在しない範囲になる場合
                    if not (end[stn] <= npzdata[stn].shape[0]):
                        skip[stn].append(5)
            else:
                flag[stn] = False
                # 1. 検測値リストにその観測点の行は存在するが、itpまたはits(または両方)が欠落している(itpまたはitsがnp.nan)
                if np.isnan(itp.get(stn)) or np.isnan(itp.get(stn)):
                    skip[stn].append(1)
                # 2. 検測値リストにその観測点の行が存在しない
                else:
                    skip[stn].append(2)

        # cut wave and set adjusted itp and its
        for stn in stnlist:
            self._wavedata.processflag[stn] = flag[stn]
            if flag[stn]:
                self._wavedata.npzdata[stn] = npzdata[stn][start[stn]:end[stn], :]
                self._wavedata.itp[stn] = itp1[stn]
                self._wavedata.its[stn] = its1[stn]
                print("[NpzProcessor.cut_wave]:", self._wavedata.baseFname, stn, "processed.")
            else:
                #skipした場合は原因のコードを出力する、詳細は"calc cut point and revise itp and its"内コメント参照
                print("[NpzProcessor.cut_wave]:", self._wavedata.baseFname, stn, "skipped. code:", skip[stn])

    def to_npz(self, mode):
        npzdata = self._wavedata.npzdata
        stnlist = npzdata.keys()

        filetime = self._wavedata.filetime
        t0 = self._wavedata.t0

        if mode == 'cont':
            # train, test モードではprocessflag=Trueのものだけ変換する
            # cont モードでは全て変換する
            for stn in stnlist:
                self._wavedata.processflag[stn] = True        
        flag = self._wavedata.processflag

        for stn in stnlist:
            if flag[stn]:      
                out = filetime + "_" + stn
                outfile = out + ".npz"
                out_fname = os.path.join(self._outdir, outfile)
                self._wavedata.outFname[stn] = out_fname

                if (mode == 'train') or (mode == 'test'):
                    np.savez(out_fname, data=self._wavedata.npzdata[stn], itp=self._wavedata.itp[stn], its=self._wavedata.its[stn], channels=self._wavedata.channel, sta_id=stn, t0=t0)

                elif mode == 'cont':
                    np.savez(out_fname, data=self._wavedata.npzdata[stn], sta_id=stn, t0=t0)

                print("[NpzProcessor.to_npz]:", out_fname)

    def make_list(self, listname, mode):
        fname = self._wavedata.baseFname

        # npzProcessor.to_npz()された観測点の一覧
        flag = self._wavedata.processflag

        if (mode == 'train') or (mode == 'test'):
            # 検測値リスト読み込み・処理するイベントに対応する部分だけ抜粋
            df = load_csv(listname).loc[[fname]]

            # stationをkeyとするdictに変換
            itdict = df.set_index('station', drop=False).to_dict()
            
            # fname列を作成
            stncoldict = {}
            for key in itdict['win_name'].keys():
                if key in flag.keys():
                    if flag[key]:
                        value = os.path.basename(self._wavedata.outFname[key])
                    else:
                        value = 'skipped' # npzは存在するが、学習データとして使えずto_npzでskipされたもの
                else:
                    value = 'nodata' # pick listに入っているがnpzが存在しないもの=NpzConverter.to_npzされておらず、npzが存在しないもの(stnlistに入れていない or win2npzが失敗している)
                stncoldict[key] = value

            # fname列を追加・リストに追加
            itdict['fname'] = stncoldict
            df = pd.DataFrame.from_dict(itdict)
            df = df[df['fname'].str.endswith('.npz')] # npzが存在する行だけ抜き出す

        elif mode == 'cont':
            itdict = {}
            itdict['win_name'] = {key: fname for key in flag.keys()}
            itdict['station'] = {key: key for key in flag.keys()}
            itdict['fname'] = self._wavedata.outFname
            df = pd.DataFrame.from_dict(itdict)
            df['fname'] = df['fname'].apply(os.path.basename)

        return df
        
# 連続波形処理の場合は下記を実装する
# 共通のものはNpzStationProcessorからNpzProcessorに移動
# class NpzNetworkProcessor(NpzProcessor):