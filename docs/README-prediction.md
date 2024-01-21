# WIN2PhaseNet
# Detail usage for PhaseNet prediction

## What is the output?
### `cont` mode (For PhaseNet prediction)
* npz waveform files: `npz/[datetime]_[station].npz` *1

  | Key | Description |
  | --- | --- |
  | `data` | - continuous waveform data of one station <br> - dataShape: **(6000, 3)** # means 60 seconds (100 Hz) / 3 compornent *2 <br> - You can change data length with `--output_length` option. |
  | `t0` | start time of waveform file |
  | `sta_id` | station code |

* npz waveform list: `npz.csv`

## How to use
### 1. Input file preparation
* continuous WIN waveform files
  * format: WIN format <br>
    For the detailed information, see https://wwweic.eri.u-tokyo.ac.jp/WIN/man.en/winformat.html
  * **Only 100 Hz data is acceptable.**
  * NIED provides 60 seconds of WIN waveform files. <br>
    For the detailed information, see https://hinetwww11.bosai.go.jp/auth/download/cont/?LANG=en
  * Make directry named `<base directory>/WIN2PhaseNet/data` and put the files there. <br>
    You can change the path with `--indir` option.

* station list: a list of stations to process
  * format: txt format
  * **Only stations listed in the channel table are allowed to be listed in.** <br>
    You can automatically set all the stations in the channel table as a station list with `--tbl2lst` option, instead of preparing a txt file of station list.
  * Put the file as `<base directory>/WIN2PhaseNet/etc/stn.lst`. <br>
    You can change the path with `--stnlst` option.
  * sample: `<base directory>/WIN2PhaseNet/sample/etc/stn.lst`

* channel table: correspondence Table of stations and their code
  * format: txt format <br>
    For the detailed information, see https://wwweic.eri.u-tokyo.ac.jp/WIN/man.ja/win.html (only in Japanese).
  * NIED provides channel table at the same time when downloading WIN waveform files. <br>
    For the detailed information, see https://hinetwww11.bosai.go.jp/auth/download/cont/?LANG=en
  * Put the file as `<base directory>/WIN2PhaseNet/etc/stn.tbl`. <br>
    You can change the path with `--chtbl` option.

* (optional)rotation table: rotation coefficient table for S-net by Takagi et al. (2019).
  * format: txt format <br>
    Use `<base directory>/WIN2PhaseNet/etc/ch_rot.takagi`.
  * You can change the path with `--rottbl` option.

* (optional)filter configuration file: configuration file of band-pass filter by Saito (1974).
  * format: txt format
    | Row | Description |
    | --- | --- |
    | 1 | cut-off frequency (lower) |
    | 2 | cut-off frequency (higher) |
    | 3 | order of the filter |
  * Put the file as `<base directory>/WIN2PhaseNet/etc/filter.prm`. <br>
    You can change the path with `--filprm` option.
  * sample: `<base directory>/WIN2PhaseNet/sample/etc/filter.prm`

### 2. Configuration of WIN2PhaseNet
* Set the following options at least.

  | Option | Description |
  | --- | --- |
  | `--mode {cont,train,test}` | specify the mode (See 'What is the output?' for the detailed infomation.) |
  | `[--output_length OUTPUT_LENGTH]` | length of output npz waveform (unit: second, default: `60`, valid only for `cont` mode) |
  | `[--tbl2lst]` | automatically set all the stations in the channel table as a station list |
  | `[--rotation]` | add rotation process for S-net data |
  | `[--filter]` | add band-pass filter process |

* Use `-h` option for the detailed information of all other options.

### 3. Execute WIN2PhaseNet
```
# Pull docker image and run the 'win2npz' container. *3
$ ./docker-run.bash

# Run WIN2PhaseNet on the container environment.
(container)$ python3 src/win2npz.py --mode cont [--output_length OUTPUT_LENGTH] [--tbl2lst] [--rotation] [--filter]
# e.g. 
# (container)$ python3 src/win2npz.py --mode cont # with both 'stn.lst' and 'stn.tbl'
# (container)$ python3 src/win2npz.py --mode cont --tbl2lst # without 'stn.lst' (only 'stn.tbl')

# Exit the container environment after execution is complete.
(container)$ exit

# You can find the output of WIN2PhaseNet in '<base directory>/WIN2PhaseNet/<OUTDIR(default: 'out')>' directory.
```

### 4. Execute PhaseNet prediction
This program **NOT** contains PhaseNet but show how to use PhaseNet briefly. <br>
"npz waveform files" and "npz waveform list" made by `cont` mode of WIN2PhaseNet are required in advance.

#### Download PhaseNet
```
$ cd <base directory> # return to base directory
$ git clone https://github.com/AI4EPS/PhaseNet.git
$ cd PhaseNet
$ git checkout -b v1.2 f119e28
```

#### Execute prediction
```
# Pull docker image and run the 'phasenet' container. *3
$ cd <base directory>/WIN2PhaseNet # return to WIN2PhaseNet directory
$ ./docker-run.bash phasenet

# Run PhaseNet on the container environment.
(container)$ python phasenet/predict.py --model_dir=model/190703-214543 --data_dir=<"npz waveform files" directory path of WIN2PhaseNet> --data_list=<"npz waveform list" path of WIN2PhaseNet> --amplitude --plot_figure
# e.g. 
# (container)$ python phasenet/predict.py --model_dir=model/190703-214543 --data_dir=../WIN2PhaseNet/out/npz --data_list=../WIN2PhaseNet/out/npz.csv --amplitude --plot_figure

# Exit the container environment after execution is complete.
(container)$ exit

# You can find the output of PhaseNet in '<base directory>/PhaseNet/results' directory.
```

## Notes
* *1 **datetime**: same information as `t0` but format is "yymmddhhmmss" <br>
  **station**: same information as `sta_id`

* *2 The following data is filled with 0.
    * lack part when the data length of the input WIN waveform is **less than the specified length (`cont`: [OUTPUT_LENGTH (default: 60)] seconds, `train`, `test`: 180 seconds)**
    * remainder when the data length of the input WIN waveform is **not divisible by [OUTPUT_LENGTH (default: 60)] seconds** (only `cont` mode)

* *3 Each docker image is built from the following Dockerfile.
    * win2npz: dockerfiles/win2npz/Dockerfile
    * phasenet: dockerfiles/phasenet/Dockerfile