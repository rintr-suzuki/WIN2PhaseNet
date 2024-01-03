# -*- coding: utf-8 -*-
import os
import glob
import argparse
import pandas as pd

from util import load_csv
from service import NpzConverter, NpzStationProcessor

def read_args():
   parser = argparse.ArgumentParser()

   # mode information
   parser.add_argument('--mode', choices=['train', 'test', 'cont'], required=True)
   
   # input information
   parser.add_argument('--list')
   parser.add_argument('--indir', default='data')

   # output information
   parser.add_argument('--outdir', default='out')
   parser.add_argument('--output_length', default=30, help='[cont] length of output npz waveform')

   # station list for conversion
   parser.add_argument('--stnlst', default='etc/stn.lst', help='station list')

   # channel table of station code
   parser.add_argument('--chtbl', default='etc/stn.tbl', help='channel table')

   # Note that S-net station should be converted to adjust rotation
   parser.add_argument('--rotation', action='store_true', help='rotation for S-net data')
   parser.add_argument('--rottbl', default='etc/ch_rot.takagi', help='rotation table')

   # 
   parser.add_argument('--filter', action='store_true')
   parser.add_argument('--filprm', default='etc/filter.prm', help='filter information')

   # #number of thread: (max) fudai: 15, wdeep: 20
   # parser.add_argument('--pooln', type=int, default=20, help='number of thread: default=20, multi thread processing is not ready..')

   args = parser.parse_args()
   return args
   
def main(args):
      # common settings
      ## exit if there is pick list
      if (args['mode'] == 'train') or (args['mode'] == 'test'):
         if args['list'] is None:
            print("[Error: Pick list is missing]:", "Please specify pick list if mode is train or test, mode:", args['mode'])
            exit(1)

      ## set length
      if (args['mode'] == 'train') or (args['mode'] == 'test'):
         args['input_length'] = 180 # to contain pick data
      elif args['mode'] == 'cont':
         args['input_length'] = args['output_length']

      ## set input files
      indir = args['indir']
      files = glob.glob(indir + "/*")

      # convert win format into npz format
      stndir = os.path.join(".tmp", "stn")
      tmpoutdir = os.path.join(".tmp", args['outdir'])
      listname = args['list']

      outdict = {}
      for fname in files:
         npzConverter = NpzConverter(fname, indir, tmpoutdir, stndir, listname, args)
         npzConverter.to_npz()
         outdict[fname] = {'npzlist': npzConverter.outfiles, 'stnlist': npzConverter.stations}

      # add itp and its info to npz & make cut npz according to itp and its
      outdir = os.path.join(args['outdir'], "npz")
      
      outcsv_list = []
      for fname in files:
         for filetime in outdict[fname]['npzlist'].keys():
            oneoutdict = {}
            for key in ['npzlist', 'stnlist']:
               oneoutdict[key] = outdict[fname][key][filetime]

            npzProcessor = NpzStationProcessor(fname, indir, outdir, args, oneoutdict, filetime)
            if (args['mode'] == 'train') or (args['mode'] == 'test'):
               npzProcessor.set_time(args['list'])
               npzProcessor.cut_wave(args['mode'])
            npzProcessor.to_npz(args['mode'])
            df = npzProcessor.make_list(args['list'], args['mode'])
            outcsv_list.append(df)

            if (args['mode'] == 'train') or (args['mode'] == 'test'):
               break # only processing first unit
      
      # make data list
      df = pd.concat(outcsv_list)
      outcsv = os.path.join(args['outdir'], "npz.csv")
      df.to_csv(outcsv, index=None)

      # remove tmp file
      for file in glob.glob(stndir + "/*.lst"):
         os.remove(file)
      
      for dir in glob.glob(tmpoutdir + "/*"):
         for file in glob.glob(dir + "/*.npz"):
            os.remove(file)


if __name__ == '__main__':
   args = vars(read_args()) # convert to dict
   main(args)