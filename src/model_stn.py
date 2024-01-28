import os
import pandas as pd

class StationTable(object):
    def __init__(self):
        self.stnlst = None
        self.chtbl = None

    def tbl2lst(self, outdir):
        # read
        df = pd.read_csv(self.chtbl, header=None)
        df = df[~df.iloc[:, 0].str.startswith('#')] # delete comment line
        df = df[0].str.split(expand=True)
        stn_list = list(set(df[3].values))

        # write
        self.stnlst = os.path.join(outdir, "stn.lst")
        stnlst = self.stnlst
        with open(stnlst, 'w') as f:
            f.write('\n'.join(sorted(stn_list)))
            f.write('\n')    

class ChannelTable(object):
    def __init__(self):
        self.chtbl0 = None
        self.chtbl = None
    
    def screening(self, outdir):
        # read
        # print(self.chtbl0)
        df = pd.read_csv(self.chtbl0, header=None)
        df = df[~df.iloc[:, 0].str.startswith('#')] # delete comment line
        df = df[0].str.split(expand=True)
        df = df[~df.duplicated(subset=[3, 4])] # delete same stn and comp code
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
        diff_df = pd.concat([df1, df2])
        if len(diff_df.index) != 0:
            print("[Warn: NpzConverter ignores paticular stations]: \n", diff_df)

        # write
        self.chtbl = os.path.join(outdir, "stn.tbl")
        df.to_csv(self.chtbl, sep=" ", header=None, index=None)