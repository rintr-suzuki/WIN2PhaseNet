# -*- coding: utf-8 -*-
import argparse
from multiprocessing import Pool

from master import Config, MasterProcess
from service import NpzConverter, NpzStationProcessor

def read_args():
   parser = argparse.ArgumentParser()

   # mode information
   parser.add_argument('--mode', '-m', choices=['cont', 'train', 'test'], required=True, help='See "README.md" for the detailed infomation.')
   
   # input information
   parser.add_argument('--list', '-l', help='[train, test] file path of pick list')
   parser.add_argument('--indir', default='data', help='path of input directory for WIN waveform files (default: data)')
   parser.add_argument('--disable_winext', action='store_true', help='if set, do not check WIN waveform files (default: enable)')
   parser.add_argument('--winext', default='.cnt', help='extention of WIN waveform files (default: .cnt)')

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

   # multi-thread processing
   parser.add_argument('--thread', type=int, help='number of thread (default: multiprocessing.cpu_count()*0.6)')

   args = parser.parse_args()
   return args

def npzConverterMap(config):
   npzConverter = NpzConverter(config)
   npzConverter.to_npz()
   return npzConverter

def npzProcessorMap(npzConverter, filetime, config):
   config.set_outdir(True)
   npzProcessor = NpzStationProcessor(config, filetime)
   npzProcessor.set_npz(npzConverter)
   npzProcessor.set_time()
   npzProcessor.cut_wave()
   npzProcessor.to_npz()
   npzProcessor.make_list()
   return npzProcessor

def npzConverterMapWrapper(args):
   return npzConverterMap(args)

def npzProcessorMapWrapper(args):
   return npzProcessorMap(*args)
   
def main(params):
      # initial settings
      ## master setting
      generalConfig = Config(params)
      masterProcess = MasterProcess(generalConfig)

      p = Pool(generalConfig.thread)

      ## set config
      for fname in generalConfig.files:
         config = Config(params)
         config.set_fname(fname)
         config.set_stndir()
         config.set_outdir(False)
         masterProcess.set_config(config)

      # convert win format into npz format
      ## load config
      npzConverterMapInput = [masterProcess.get_config(fname) for fname in generalConfig.files]

      ## run npzConverter
      npzConverterMapOutput = p.map(npzConverterMapWrapper, npzConverterMapInput)

      ## save npzConverter
      for npzConverter in npzConverterMapOutput:
         masterProcess.set_npzConverter(npzConverter)

      # add itp and its info to npz & make cut npz according to itp and its
      ## load config and npzConverter
      npzProcessorMapInput = []
      for fname in generalConfig.files:
         npzConverter = masterProcess.get_npzConverter(fname)
         for filetime in npzConverter.filetimeList:
            npzProcessorMapInput.append([npzConverter, filetime, masterProcess.get_config(fname)])
      
      ## run npzProcessor
      npzProcessorMapOutput = p.map(npzProcessorMapWrapper, npzProcessorMapInput)

      ## save npzlist
      for npzProcessor in npzProcessorMapOutput:
         masterProcess.set_npzList(npzProcessor)
      
      # make data list
      masterProcess.to_csv()

      # remove tmp file
      masterProcess.rm_tmp()

if __name__ == '__main__':
   params = vars(read_args()) # convert to dict
   main(params)