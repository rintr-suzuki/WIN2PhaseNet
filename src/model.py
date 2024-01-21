import numpy as np
import os
import datetime

from util import load_npz

class Wavedata(object):
    def __init__(self, fname):
        self.fname = fname
        self.baseFname = os.path.basename(fname)
        self.outFname = None

class WinWavedata(Wavedata):
    def __init__(self, fname):
        super().__init__(fname)

class NpzWavedata(Wavedata):
    def __init__(self, fname, filetime):
        super().__init__(fname)
        self.npzdata = {}
        self.outFname = {}
        self.__itp = {}
        self.__its = {}
        self.channel = "net"

        self.filetime = filetime
        self.__t0_dt = datetime.datetime.strptime(self.filetime, "%y%m%d%H%M%S")
        self.t0 = self.__t0_dt.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3]

    @property
    def itp(self):
        return self.__itp
    
    @property
    def its(self):
        return self.__its

    @property
    def t0_dt(self):
        return self.__t0_dt

    @itp.setter
    def itp(self, itp):
        for key, value in itp.items():
            if not np.isnan(value):
                value = np.array(value, dtype=np.int64)
            self.__itp[key] = value

    @its.setter
    def its(self, its):
        for key, value in its.items():
            if not np.isnan(value):
                value = np.array(value, dtype=np.int64)
            self.__its[key] = value

    @t0_dt.setter
    def t0_dt(self, t0_dt):
        self.__t0_dt = t0_dt
        self.t0 = self.__t0_dt.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3]

class NpzStationWavedata(NpzWavedata):
    def __init__(self, fname, npzConverter, filetime):
        super().__init__(fname, filetime)

        npzdict = {}
        stnlist = npzConverter.stations[filetime]
        npzdata = []
        for fname in npzConverter.outfiles[filetime]:
            meta = load_npz(fname)
            if np.all(meta[-100:, :] == 0):
                print("[NpzStationWavedata.__init__]:[WARN] some data filled with 0. file =", fname)
            npzdata.append(meta)
        for key, value in zip(stnlist, npzdata):
                npzdict[key] = value
        self.npzdata = npzdict

        self.processflag = {}

# 連続波形処理の場合は下記を実装する
# class NpzNetworkWavedata(NpzWavedata):