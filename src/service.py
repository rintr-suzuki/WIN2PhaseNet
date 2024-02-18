import os
import glob
import numpy as np
import pandas as pd
import subprocess as sp
import datetime

from util import count_non_nan, load_csv
from model import WinWavedata, NpzStationWavedata

# 1 winfile -> n*(length/input_length) npzfile (n=station)
# win2npz.fを実行するクラス
class NpzConverter(object):
    def __init__(self, config):
        # super().__init__(fname, indir, outdir, params)
        self.indir = config.indir
        self.stndir = config.stndir
        self.outdir = config.outnpzdir

        self.fname = config.fname #os.path.join(self.indir, fname)
        self.wavedata = WinWavedata(self.fname)
        
        # make station list for each event
        self.baseFname = self.wavedata.baseFname
        baseFname = self.baseFname
        stnlst = config.stnlst; listname = config.list
        if listname is not None:
            df = load_csv(listname)
        stn_df = load_csv(stnlst, header=None)

        each_stnlst_list = []
        each_stnlst = os.path.join(self.stndir, "stn_%s.lst" % baseFname)
        with open(each_stnlst, 'w'):
            pass
        with open(each_stnlst, 'a') as f:
            for stn_value in stn_df[0]:
                if listname is not None:
                    if len(df[(df['win_name'] == baseFname) & (df['station'] == stn_value)]) == 0:
                        # To save time, only convert paticular station with picks if there is pick listpython
                        continue
                f.write(stn_value)
                f.write("\n")
                each_stnlst_list.append(stn_value)
    
        self.stnlst = each_stnlst
        self.stations = each_stnlst_list

        self.chtbl = config.chtbl
        self.input_length = config.input_length

        self.rotation = config.rotation
        self.filter = config.filter
        self.rottbl = config.rottbl
        self.filprm = config.filprm

        self.outfiles = None

        print("[NpzConverter.__init__]:", baseFname)

    def to_npz(self):
        # win2npz
        com = "win2npz.x" \
            + ' -w %s' % self.wavedata.fname \
            + ' -s %s' % self.stnlst \
            + ' -k %s' % self.chtbl \
            + ' -d %s' % self.outdir \
            + ' -t %s' % self.input_length
        if self.rotation:
            com = com + ' -r %s' % self.rottbl
        if self.filter:
            com = com + ' -f %s' % self.filprm
        print("[NpzConverter.to_npz]:", com)

        ## needs fortran ##
        proc = sp.run(com, shell=True, stdout = sp.PIPE, stderr = sp.STDOUT) #be careful for shell injection!!
        out = proc.stdout.decode("utf8")
        print("[NpzConverter.to_npz]: win2npz.x", out)
        ##############

        # ## for test ##
        # for filestn in self.stations:
        #     out = filetime + "_" + filestn
        #     outfile = out + ".npz"
        #     array = np.random.rand(18000, 3)
        #     np.savez(os.path.join(self.outdir, outfile), data=array)
        #     print("[NpzConverter.to_npz]:", out)
        # ##############

        filetime_list = sorted(list(set([os.path.basename(fname).rstrip('.npz').split('_')[0] for fname in glob.glob(os.path.join(self.outdir, '*' + '.npz'))])), key=int)      
        self.outfiles = {}; self.stations = {}
        for key in filetime_list:
            self.outfiles[key] = glob.glob(os.path.join(self.outdir, key + '*' + '.npz'))
            self.stations[key] = [os.path.basename(fname).rstrip('.npz').split('_')[1] for fname in self.outfiles[key]]
        
        self.filetimeList = [[i, filetime] for i, filetime in enumerate(filetime_list)]

# npzファイルのおさまったディレクトリを受け取ってフォーマットの修正を行うクラス
# n npzfile -> n npzfile (n=station)
# fnameはWINの波形ファイル名・filetimeはnpzの波形ファイル名の一部
class NpzStationProcessor(object):
    def __init__(self, config, filetime):
        self.indir = config.indir
        self.outdir = config.outnpzdir

        self.fname = config.fname #os.path.join(self.indir, fname)
        self.baseFname = config.baseFname
        self.ifiletime = filetime[0]
        self.filetime = filetime[1]

        self.mode = config.mode
        self.list = config.list

        self.chtbl_df = config.chtbl_df

        self.skip_flag = False
        if (self.mode == 'train') or (self.mode == 'test'):
            if self.ifiletime > 0:
                self.skip_flag = True
        print("[NpzProcessor.__init__]:", self.baseFname, self.filetime)
        
    def set_npz(self, npzConverter):
        mode = self.mode

        if not self.skip_flag:
            self.wavedata = NpzStationWavedata(self.fname, npzConverter, self.filetime, self.chtbl_df) #stations, outfiles->npzdataとして格納
            print("[NpzProcessor.set_npz]:", self.wavedata.baseFname, self.wavedata.filetime, "stations:", len(self.wavedata.npzdata.keys()))
        else:
            print("[NpzProcessor.set_npz]: skipped. mode =", mode)

    def set_time(self):
        mode = self.mode

        # skip if cont mode
        skip_flag = False
        if (mode != 'train') and (mode != 'test'):
            skip_flag = True

        # print(self.skip_flag, skip_flag); exit()
        if (not self.skip_flag) and (not skip_flag):
            listname = self.list
            # 検測値リスト読み込み・処理するイベントに対応する部分だけ抜粋
            fname = self.wavedata.baseFname
            df = load_csv(listname).loc[[fname]]

            # stationをkeyとするdictに変換
            itdict = df.set_index('station', drop=False).to_dict()

            self.wavedata.itp = itdict['itp']
            self.wavedata.its = itdict['its']
            print("[NpzProcessor.set_time]:", self.wavedata.baseFname, "itp:", count_non_nan(self.wavedata.itp.values()), "its:", count_non_nan(self.wavedata.its.values()))
        else:
            print("[NpzProcessor.set_time]: skipped. mode =", mode)
    
    def cut_wave(self):
        mode = self.mode

        # skip if cont mode
        skip_flag = False
        if (mode != 'train') and (mode != 'test'):
            skip_flag = True

        if (not self.skip_flag) and (not skip_flag):
            npzdata = self.wavedata.npzdata
            stnlist = npzdata.keys()

            t0_dt = self.wavedata.t0_dt
            itp = self.wavedata.itp
            its = self.wavedata.its

            # calc cut point and revise itp and its
            #波形を切り出した場合、t0, itp, itsの時間がずれるので、startの時間に併せて補正
            if mode == "test":
                bf_p = 100; length = 3000
            elif mode == "train":
                bf_p = 3000; length = 9000
            else:
                print("[Error: mode is invalid]:", mode, "mode should be 'train' or 'test'")
            # t0
            self.wavedata.t0_dt = t0_dt - datetime.timedelta(milliseconds=bf_p)

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
                self.wavedata.processflag[stn] = flag[stn]
                if flag[stn]:
                    self.wavedata.npzdata[stn] = npzdata[stn][start[stn]:end[stn], :]
                    self.wavedata.itp[stn] = itp1[stn]
                    self.wavedata.its[stn] = its1[stn]
                    print("[NpzProcessor.cut_wave]:", self.wavedata.baseFname, stn, "processed.")
                else:
                    #skipした場合は原因のコードを出力する、詳細は"calc cut point and revise itp and its"内コメント参照
                    print("[NpzProcessor.cut_wave]:", self.wavedata.baseFname, stn, "skipped. code:", skip[stn])
        else:
            print("[NpzProcessor.cut_wave]: skipped. mode =", mode)

    def to_npz(self):
        mode = self.mode

        if not self.skip_flag:
            npzdata = self.wavedata.npzdata
            stnlist = npzdata.keys()

            filetime = self.wavedata.filetime
            t0 = self.wavedata.t0

            if mode == 'cont':
                # train, test モードではprocessflag=Trueのものだけ変換する
                # cont モードでは全て変換する
                for stn in stnlist:
                    self.wavedata.processflag[stn] = True        
            flag = self.wavedata.processflag

            for stn in stnlist:
                if flag[stn]:      
                    out = filetime + "_" + stn
                    outfile = out + ".npz"
                    out_fname = os.path.join(self.outdir, outfile)
                    self.wavedata.outFname[stn] = out_fname

                    if (mode == 'train') or (mode == 'test'):
                        np.savez(out_fname, data=self.wavedata.npzdata[stn], itp=self.wavedata.itp[stn], its=self.wavedata.its[stn], channels=self.wavedata.channel, sta_id=stn, t0=t0)

                    elif mode == 'cont':
                        np.savez(out_fname, data=self.wavedata.npzdata[stn], sta_id=stn, t0=t0)

                    print("[NpzProcessor.to_npz]:", out_fname)
        else:
            print("[NpzProcessor.to_npz]: skipped. mode =", mode)

    def make_list(self):
        mode = self.mode
        
        if not self.skip_flag:
            listname = self.list
            fname = self.wavedata.baseFname

            # npzProcessor.to_npz()された観測点の一覧
            flag = self.wavedata.processflag

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
                            value = os.path.basename(self.wavedata.outFname[key])
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
                itdict['fname'] = self.wavedata.outFname
                df = pd.DataFrame.from_dict(itdict)
                df['fname'] = df['fname'].apply(os.path.basename)

            self.npzlist = df
            print("[NpzProcessor.make_list]:", fname)
        else:
            print("[NpzProcessor.make_list]: skipped. mode =", mode)
        
        
# 連続波形処理の場合は下記を実装する
# 共通のものはNpzStationProcessorからNpzProcessorに移動
# class NpzNetworkProcessor(NpzProcessor):