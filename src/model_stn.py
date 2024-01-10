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