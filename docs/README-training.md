# WIN2PhaseNet
Detailed usage for PhaseNet training

## Brief usage
### WIN2PhaseNet
```
$ ./docker-run.bash
(container)$ ./WIN2PhaseNet.bash -m train -l picks.csv
(container)$ exit
# See 'out' directory for the result.
```

## What is the output?
### 1. `train` mode (For PhaseNet training and validation)
* npz waveform files: `npz/[datetime]_[station].npz` *1

  | Key | Description |
  | --- | --- |
  | `data` | - event waveform data of one event / one station <br> - dataShape: **(9000, 3)** # means 90 seconds (100Hz) / 3 compornent *2 <br> - Data starts **30 seconds** before of `itp`. |
  | `itp` | the data point of **P phase** from the start of each npz waveform file |
  | `its` | the data point of **S phase** from the start of each npz waveform file |
  | `t0` | start time of waveform file |
  | `sta_id` | station code |

* npz waveform list: `npz.csv`

### 2. `test` mode (For PhaseNet test after training)
* npz waveform files: `npz/[datetime]_[station].npz` *1

  | Key | Description |
  | --- | --- |
  | `data` | - event waveform data of one event / one station <br> - dataShape: **(3000, 3)** # means 30 seconds (100Hz) / 3 compornent *2 <br> - Data starts **1 seconds** before of `itp`. |
  | `itp` | the data point of **P phase** from the start of each npz waveform file |
  | `its` | the data point of **S phase** from the start of each npz waveform file |
  | `t0` | start time of waveform file |
  | `sta_id` | station code |

* npz waveform list: `npz.csv`

## How to use
### 1. Input file preparation
* event WIN waveform files
  * format: WIN format <br>
    For the detailed information, see https://wwweic.eri.u-tokyo.ac.jp/WIN/man.en/winformat.html
  * **Only 100 Hz data is acceptable.**
  * **Recommend >=180 seconds of data. Otherwise part of data will be filled with 0.** *2
  * Make directry named `<base directory>/WIN2PhaseNet/data` and put the files there. <br>
    You can change the path with `--indir` option.

* pick list: a list of P or S phase for each "event WIN waveform file"
  * format: csv format

    | Column | Description |
    | --- | --- |
    | `win_name` | the file name of a WIN waveform file |
    | `station` | station code |
    | `itp` | the data point of **P phase** from the start of each WIN waveform file |
    | `its` | the data point of **S phase** from the start of each WIN waveform file |

  * **Only data from the station with BOTH P phase and S phase is processed.**
  * Put the file at `<base directory>/WIN2PhaseNet`.
  * sample: `<base directory>/WIN2PhaseNet/sample/picks.csv`

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
  * **Only support the following "component code (column [5])"**. <br>
    -Vertical compornent: EW,E,X,VX <br>
    -Horizontal compornent 1: NS,N,Y,VY <br>
    -Horizontal compornent 2: UD,U,Z,VZ
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
  | `--list LIST` | file path of pick list (Only required for `train` and `test` mode) |
  | `[--tbl2lst]` | automatically set all the stations in the channel table as a station list |
  | `[--rotation]` | add rotation process for S-net data |
  | `[--filter]` | add band-pass filter process |

* Use `-h` option for the detailed information of all other options.

### 3. Execute WIN2PhaseNet
```
# Pull docker image and run the 'win2npz' container. *3
$ ./docker-run.bash

# Run WIN2PhaseNet on the container environment.
(container)$ ./WIN2PhaseNet.bash --mode {train,test} --list LIST [--output_length OUTPUT_LENGTH] [--tbl2lst] [--rotation] [--filter]
# e.g. 
# (container)$ ./WIN2PhaseNet.bash --mode train --list picks.csv
# (container)$ ./WIN2PhaseNet.bash --mode test --list picks.csv

# Exit the container environment after execution is complete.
(container)$ exit

# You can find the output of WIN2PhaseNet in '<base directory>/WIN2PhaseNet/<OUTDIR(default: 'out')>' directory.
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