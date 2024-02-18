import copy
import glob
import os
import pandas as pd
from multiprocessing import cpu_count

from model_stn import StationTable

class Config(object):
    def __init__(self, args):
        # 複数回実行されても問題ないように実装する
        # set argsより下では初出のself変数のみ設定or初回のみif文がTrueになるようにする
        ## set args
        for key, value in args.items():
            setattr(self, key, value)

        ## exit if there is not pick list
        if (self.mode == 'train') or (self.mode == 'test'):
            if self.list is None:
                print("[Error: Pick list is missing]:", "Please specify pick list if mode is train or test, mode:", args['mode'])
                exit(1)

        ## init input_length
        if (self.mode == 'train') or (self.mode == 'test'):
            self.input_length = 180 # to contain pick data
        elif self.mode == 'cont':
            self.input_length = self.output_length

        ## init input files
        self.files = glob.glob(self.indir + "/*")

        ## set chlst
        stntbl = StationTable(self.chtbl, self.stnlst)
        stntbl.screeningTbl(".tmp")

        self.chtbl = stntbl.chtbl
        self.chtbl_df = stntbl.chtbl_df

        ## set stnlst
        if self.tbl2lst:
            stntbl.tbl2lst(".tmp")
        else:
            stntbl.screeningLst(".tmp")

        self.stnlst = stntbl.stnlst

        ## set tmpdir
        self.tmpdir = ".tmp"

        ## init thread
        if self.thread == None:
            self.thread = int(cpu_count()*0.6)
        if self.thread > cpu_count():
            self.thread = cpu_count()
        print("[multi thread]: %d / %d threads" % (self.thread, cpu_count()))

        ## keep outdir name
        self.outdir0 = copy.deepcopy(self.outdir)

    def set_fname(self, fname):
        self.fname = fname
        self.baseFname = os.path.basename(self.fname)

    def set_stndir(self):
        try:
            self.stndir = os.path.join(".tmp", self.baseFname, "stn")
            os.makedirs(self.stndir, exist_ok=True)
        except Exception as e:
            # if fname is not set yet
            print("[Error]:", e)           
    
    def set_outdir(self, flag=True):
        try:
            if flag:
                self.outdir = self.outdir0
            else:
                self.outdir = os.path.join(".tmp", self.baseFname, "out")
            self.outnpzdir = os.path.join(self.outdir, "npz")
            os.makedirs(self.outnpzdir, exist_ok=True)
        except Exception as e:
            # if flag is False and fname is not set yet
            print("[Error]:", e)

class MasterProcess(object):
    def __init__(self, config):
        self.config = config
        self.configDict = {}
        self.npzConverterDict = {}
        self.npzlistList = []

    def set_config(self, config):
        fname = config.baseFname
        self.configDict[fname] = config

    def get_config(self, fname):
        fname = os.path.basename(fname)
        return self.configDict[fname]

    def set_npzConverter(self, npzConverter):
        fname = npzConverter.baseFname
        self.npzConverterDict[fname] = npzConverter

    def get_npzConverter(self, fname):
        fname = os.path.basename(fname)
        return self.npzConverterDict[fname]

    def set_npzList(self, npzProcessor):
        self.npzlistList.append(npzProcessor.npzlist)

    def to_csv(self):
        if len(self.npzlistList) != 0:
            df = pd.concat(self.npzlistList)
            outcsv = os.path.join(self.config.outdir, "npz.csv")
            df.to_csv(outcsv, index=None)
        else:
            print("[Error]: There is no WIN waveform to output. Please check requirements.")
            exit()

    def rm_tmp(self):
        ext = ["lst", "tbl", "npz"]

        l = []
        for s in ext:
            l += glob.glob(self.config.tmpdir + "/**/*.%s" % s, recursive=True)
        for file in l:
            os.remove(file)
            # print(file)