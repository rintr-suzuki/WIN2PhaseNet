import os
import pandas as pd

import codecs
## for test to print shift-jis ##
# import sys
# import io
# sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

class StationTable(object):
    def __init__(self, chtbl0, stnlst0):
        self.chtbl0 = chtbl0
        self.stnlst0 = stnlst0

        self.chtbl = chtbl0
        self.stnlst = stnlst0

        self.chtbl_df = None
        self.stnlst_l = None

        self.stnrealtbl = None

    def screeningTbl(self, outdir):
        # read
        # print(self.chtbl0)
        ## read file
        meta_list = []
        with codecs.open(self.chtbl0, 'r', 'utf-8', 'replace') as file:
            for raw in file:
                columns = raw.split()[:18]
                meta = " ".join(columns)
                if not meta.startswith('#'): # delete comment line
                    meta_list.append(meta)
        df = pd.DataFrame({0: meta_list})

        df = df[0].str.split(expand=True)
        df = df[~df.duplicated(subset=[3, 4])] # delete same stn and comp code

        # Delete stations without proper Voltage Amplification Ratio
        flag31 = ~df.isna()[11] # None
        flag32 = ~df[11].isin(["*"]) # *
        flag3 = flag31 & flag32
        df0 = df[flag3]
        df3 = df[~flag3]
        df = df0.copy()

        df[11] = df[11].map(lambda x: int(float(x))) # fix class to int
        # print(df)

        # Delete stations without support component codes
        l = ['EW', 'E', 'X', 'VX', 'NS', 'N', 'Y', 'VY', 'UD', 'U', 'Z', 'VZ']
        flag1 = df[4].isin(l)
        df0 = df[flag1]
        df1 = df[~flag1]
        df = df0.copy()
        # print(df)

        # Delete stations where the three components are not aligned
        flag2 = df.groupby(3)[3].transform('count') == 3
        df0 = df[flag2]
        df2 = df[~flag2]
        df = df0.copy()
        # print(df)

        # print diff
        diff_df = pd.concat([df3, df1, df2])
        if len(diff_df.index) != 0:
            print("[Warn: NpzConverter ignores paticular stations in chtbl]: \n", diff_df)

        # write
        self.chtbl_df = df
        # self.stnlst_l = None

        self.chtbl = os.path.join(outdir, "stn.tbl")
        df.to_csv(self.chtbl, sep=" ", header=None, index=None)

    def tbl2lst(self, outdir):
        # read
        df = pd.read_csv(self.chtbl, header=None)
        df = df[~df.iloc[:, 0].str.startswith('#')] # delete comment line
        df = df[0].str.split(expand=True)
        stn_list = list(set(df[3].values))

        # write
        self.stnlst_l = stn_list

        self.stnlst = os.path.join(outdir, "stn.lst")
        stnlst = self.stnlst
        with open(stnlst, 'w') as f:
            f.write('\n'.join(sorted(stn_list)))
            f.write('\n')

    def screeningLst(self, outdir):
        # read
        lst = pd.read_csv(self.stnlst0, header=None)
        lst = lst[~lst.iloc[:, 0].str.startswith('#')] # delete comment line

        tbl = pd.read_csv(self.chtbl, header=None)
        tbl = tbl[~tbl.iloc[:, 0].str.startswith('#')] # delete comment line
        tbl = tbl[0].str.split(expand=True)
        tblStnLst = list(set(tbl[3].values))

        # Delete stations which is not contained in chtbl
        flag = lst[0].isin(tblStnLst)
        lst0 = lst[flag]
        lst1 = lst[~flag]

        # print diff
        diff_df = lst1
        if len(diff_df.index) != 0:
            print("[Warn: NpzConverter ignores paticular stations in stnlst]: \n", list(diff_df[0].values))

        # write
        # self.stnlst_l = lst0[0].values[0]

        self.stnlst = os.path.join(outdir, "stn.lst")
        lst0.to_csv(self.stnlst, sep=" ", header=None, index=None)

    def add_corr(self, corr, outdir):
        pass
        # # func
        # def add_corr(stn, df):
        #     try:
        #         corr_p = df.at[stn, 'corr_p']
        #     except:
        #         corr_p = 0
        #     try:
        #         corr_s = df.at[stn, 'corr_s']
        #     except:
        #         corr_s = 0
        #     return (corr_p, corr_s)
        #         corr_col = ['lon', 'lat', 'height', 'stn', 'PS-P', 'std', 'th_sed', 'ttp_sed', 'corr_p', 'tts_sed', 'corr_s']
        # if corr is not None:
        #     # add sedimentary correction
        #     df_corr = pd.read_csv(corr, header=None)[0].str.split(expand=True)
        #     df_corr.columns = corr_col
        #     #['lon', 'lat', 'height', 'stn', 'PS-P', '読み取り標準偏差', '堆積層厚さ', '堆積層内P波走時', 'corr_p', '堆積層内S波走時', 'corr_s']
        #     df_corr = df_corr.set_index('stn')
        # else:
        #     df_corr = pd.DataFrame(index=[], columns=corr_col)
        
    def tbl2realtbl(self, outdir):
        # read
        df = pd.read_csv(self.chtbl, header=None)
        df = df[~df.iloc[:, 0].str.startswith('#')] # delete comment line
        df = df[0].str.split(expand=True)
        # stn_list = list(set(df[3].values))

        # select and add columns
        # lon, lat, net, id, unit, alt, corr_p, corr_s
        df = df[[3, 13, 14, 15]]
        df.columns = ['id', 'lat', 'lon', 'alt']

        df['net'] = 'net'
        df['unit'] = 'V'
        df['alt'] = df['alt'].map(lambda x: float(str(x))/1000)
        df['corr_p'] = 0
        df['corr_s'] = 0
        df = df.astype(str)

        df = df[['lon', 'lat', 'net', 'id', 'unit', 'alt', 'corr_p', 'corr_s']]

        df = df[~df.duplicated(subset='id')]

        # write
        self.stnrealtbl = os.path.join(outdir, "station.dat")
        df.to_csv(self.stnrealtbl, sep=" ", header=None, index=None)