import numpy as np
import os

from util import load_npz

class Wavedata(object):
    def __init__(self, fname):
        self._fname = fname
        self._baseFname = os.path.basename(fname)
        self._outFname = None

    @property
    def fname(self):
        return self._fname

    @property
    def baseFname(self):
        return self._baseFname

class WinWavedata(Wavedata):
    def __init__(self, fname):
        super().__init__(fname)

class NpzWavedata(Wavedata):
    def __init__(self, fname):
        super().__init__(fname)
        self._npzdata = {}
        self._outFname = {}
        self._itp = {}
        self._its = {}
        self._channel = "net"

    @property
    def npzdata(self):
        return self._npzdata
    
    @property
    def outFname(self):
        return self._outFname

    @property
    def itp(self):
        return self._itp
    
    @property
    def its(self):
        return self._its
    
    @property
    def channel(self):
        return self._channel

    @npzdata.setter
    def npzdata(self, npzdata):
        for key, value in npzdata.items():
            self._npzdata[key] = value

    @outFname.setter
    def outFname(self, outFname):
        for key, value in outFname.items():
            self._outFname[key] = value

    @itp.setter
    def itp(self, itp):
        for key, value in itp.items():
            if not np.isnan(value):
                value = np.array(value, dtype=np.int64)
            self._itp[key] = value

    @its.setter
    def its(self, its):
        for key, value in its.items():
            if not np.isnan(value):
                value = np.array(value, dtype=np.int64)
            self._its[key] = value

class NpzStationWavedata(NpzWavedata):
    def __init__(self, fname, npzinfo):
        super().__init__(fname)

        npzdict = {}
        stnlist = npzinfo['stnlist']
        npzdata = [load_npz(fname) for fname in npzinfo['npzlist']]
        for key, value in zip(stnlist, npzdata):
                npzdict[key] = value
        self._npzdata = npzdict

        self._processflag = {}
    
    @property
    def processflag(self):
        return self._processflag
    
    @processflag.setter
    def processflag(self, processflag):
        for key, value in processflag.items():
            self._processflag[key] = value

# 連続波形処理の場合は下記を実装する
# class NpzNetworkWavedata(NpzWavedata):