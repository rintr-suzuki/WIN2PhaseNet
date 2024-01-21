# -*- coding: utf-8 -*-
import argparse

from master import Config, MasterProcess
from service import NpzConverter, NpzStationProcessor

def read_args():
   parser = argparse.ArgumentParser()

   # mode information
   parser.add_argument('--mode', choices=['cont', 'train', 'test'], required=True, help='See "README.md" for the detailed infomation.')
   
   # input information
   parser.add_argument('--list', help='[train, test] file path of pick list')
   parser.add_argument('--indir', default='data', help='path of input directory for WIN waveform files (default: data)')

   # output information
   parser.add_argument('--outdir', default='out', help='path of output directory (default: out)')
   parser.add_argument('--output_length', default=60, help='[cont] length of output npz waveform (unit: second, default: 60)')

   # station list for conversion
   parser.add_argument('--stnlst', default='etc/stn.lst', help='path of station list file (default: etc/stn.lst)')
   parser.add_argument('--tbl2lst', action='store_true', help='automatically set all the stations in the channel table as a station list')

   # channel table of station code
   parser.add_argument('--chtbl', default='etc/stn.tbl', help='path of channel table file (default: etc/stn.tbl)')

   # rotation process
   parser.add_argument('--rotation', action='store_true', help='add rotation process for S-net data')
   parser.add_argument('--rottbl', default='etc/ch_rot.takagi', help='path of rotation table file (default: etc/ch_rot.takagi)')

   # band-pass filter process
   parser.add_argument('--filter', action='store_true', help='add band-pass filter process')
   parser.add_argument('--filprm', default='etc/filter.prm', help='path of filter configuration file (default: etc/filter.prm)')

   # #number of thread
   # parser.add_argument('--pooln', type=int, default=20, help='number of thread: default=20, multi thread processing is not ready..')

   args = parser.parse_args()
   return args
   
def main(args):
      # initial settings
      ## master setting
      generalConfig = Config(args)
      masterProcess = MasterProcess(generalConfig)

      for fname in generalConfig.files:
         ## set config
         config = Config(args)
         config.set_fname(fname)
         config.set_stndir()
         config.set_outdir(False)

         ## save config
         masterProcess.set_config(config)

      # convert win format into npz format
      for fname in generalConfig.files:
         ## load config
         config = masterProcess.get_config(fname)

         ## run npzConverter
         npzConverter = NpzConverter(config)
         npzConverter.to_npz()

         ## save npzConverter
         masterProcess.set_npzConverter(npzConverter)

      # add itp and its info to npz & make cut npz according to itp and its
      for fname in generalConfig.files:
         ## load config
         config = masterProcess.get_config(fname)
         config.set_outdir(True)

         ## load npzConverter
         npzConverter = masterProcess.get_npzConverter(fname)

         ## run npzProcessor
         for filetime in npzConverter.filetimeList:
            npzProcessor = NpzStationProcessor(config, filetime)
            npzProcessor.set_npz(npzConverter)
            npzProcessor.set_time()
            npzProcessor.cut_wave()
            npzProcessor.to_npz()
            npzProcessor.make_list()

            ## save npzlist
            masterProcess.set_npzList(npzProcessor)
      
      # make data list
      masterProcess.to_csv()

      # remove tmp file
      masterProcess.rm_tmp()

if __name__ == '__main__':
   args = vars(read_args()) # convert to dict
   main(args)