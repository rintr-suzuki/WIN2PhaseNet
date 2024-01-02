# WIN2PhaseNet

## Summary 
Program to make various data for PhaseNet (Zhu and Beroza, 2019) from WIN waveform file and pick list.

## What is the output?
### 1. **train** mode
* npz waveform files: `npz/[datetime]_[station].npz`
    * datetime: Date and time from win_name (format: yymmddhhmmss)

| Key | Description |
| --- | --- |
| `data` | - event waveform data of one event / one station <br> - dataShape: **(9000, 3)** # means 90 seconds (100Hz) / 3 compornent <br> - data starts **30 seconds** before of 'itp'|
| `itp` | file path of Pick list |
| `its` | directory path of output npz waveform files |
| `t0` | start time of waveform file |
| `sta_id` | station code |

* npz waveform list: `npz.csv`

### 2. **test** mode
* npz waveform files: `npz/[datetime]_[station].npz`
    * datetime: Date and time from win_name (format: yymmddhhmmss)

| Key | Description |
| --- | --- |
| `data` | - event waveform data of one event / one station <br> - dataShape: **(3000, 3)** # means 30 seconds (100Hz) / 3 compornent <br> - data starts **1 seconds** before of 'itp'|
| `itp` | file path of Pick list |
| `its` | directory path of output npz waveform files |
| `t0` | start time of waveform file |
| `sta_id` | station code |

* npz waveform list: `npz.csv`

### 3. **cont** mode
* npz waveform files: `npz/[datetime]_[station].npz`
    * datetime: Date and time from win_name (format: yymmddhhmmss)

| Key | Description |
| --- | --- |
| `data` | - continuous waveform data of one station <br> - dataShape: **(3000, 3)** # means 30 seconds (100 Hz) / 3 compornent |
| `t0` | start time of waveform file |
| `sta_id` | station code |

* npz waveform list: `npz.csv`

## How to use
### 1. Environment preparation
* OS: any OS on which docker runs
* docker
```
# Installation of docker (e.g. Ubuntu20.04)
$ sudo apt-get install
$ sudo apt-get install docker
$ sudo docker -v # Confirm installation
```
* This program: move to any directory (base directory) to clone WIN2PhaseNet
```
$ cd <base directory>
$ git clone https://github.com/rintr-suzuki/WIN2PhaseNet.git
$ cd WIN2PhaseNet
```

### 2. Input file preparation
#### 1. Common for all modes
* Channel table
    * format:
        * txt format
            * For the detailed information, see https://wwweic.eri.u-tokyo.ac.jp/WIN/man.ja/win.html (only in Japanese)

    * Put the files at `<base directory>/WIN2PhaseNet/etc/stn.tbl`

#### 2. Only for **train** and **test** mode
* Event WIN waveform files
    * format:
        * 'WIN' format
            * For the detailed information, see https://wwweic.eri.u-tokyo.ac.jp/WIN/man.en/winformat.html
        * **File name should be "Tyymmddhhmmss.dat" and "yymmddhhmmss" part should be the start time of each WIN waveform file**
            * e.g.'T170716192301.dat'
            * This is used for the name and 't0' of npz waveform file
        * **Only 100 Hz data is acceptable**

    * Make directry named `<base directory>/WIN2PhaseNet/data` and put the files there

* Pick list
    * format:
        * csv format

        | Column | Description |
        | --- | --- |
        | `win_name` | the file name of a WIN waveform file |
        | `station` | station code |
        | `itp` | the data point of **P phase** from the start of each WIN waveform file |
        | `its` | the data point of **S phase** from the start of each WIN waveform file |

        * Sample: `<base directory>/WIN2PhaseNet/picks.csv`
    * Put the file at `<base directory>/WIN2PhaseNet`
    * **Only data from the station with BOTH P phase and S phase is processed**

#### 3. Only for **cont** mode
* Continuous WIN waveform files
    * format:
        * 'WIN' format
            * For the detailed information, see https://wwweic.eri.u-tokyo.ac.jp/WIN/man.en/winformat.html
        * **File name should be "Tyymmddhhmmss.dat" and "yymmddhhmmss" part should be the start time of each WIN waveform file**
            * e.g.'T170716192301.dat'
            * This is used for the name and 't0' of npz waveform file
        * **Only 30 seconds and 100 Hz data is acceptable**

    * Make directry named `<base directory>/WIN2PhaseNet/data` and put the files there

### 3. Configuration of WIN2PhaseNet
* Set following option according to the situation

| Option | Description |
| --- | --- |
| `--mode {train,test,cont}` | specify the mode (see 'Output format' for the detailed infomation) |
| `--list LIST` | file path of Pick list (Required only for **train** and **test** mode) |
| `[--outdir OUTDIR]` | directory path of output files (default: `./out`) |
| `[--indir INDIR]` | directory path of WIN waveform files (default: `./data`) |
| `[--chtbl CHTBL]` | directory path of channel table file (default: `./etc/stn.tbl`) |

### 4. Execute WIN2PhaseNet
```
# pull docker image and run the 'win2npz' container
$ ./docker-run.bash

# run WIN2PhaseNet on the container environment
(container)$ python3 src/win2npz.py --mode {train,test,cont} --list LIST [--indir INDIR] [--outdir OUTDIR]
# e.g. 
# (container)$ python3 src/win2npz.py --mode train --list picks.csv
# (container)$ python3 src/win2npz.py --mode test --list picks.csv
# (container)$ python3 src/win2npz.py --mode cont

# Exit the container environment after execution is complete
(container)$ exit

# You can find the output of WIN2PhaseNet in '<base directory>/WIN2PhaseNet/<OUTDIR>' directory
```

### 5. Execute PhaseNet prediction
This program **NOT** contains PhaseNet but show how to use PhaseNet briefly<br>
Npz data made by **'cont' mode** of WIN2PhaseNet is required in advance

#### Download PhaseNet and model
```
$ cd <base directory> # return to base directory
$ git clone -b release https://github.com/AI4EPS/PhaseNet.git
$ cd PhaseNet
$ git checkout -b v1.2 f119e28
```

#### Execute prediction
```
# pull docker image and run the 'phasenet' container
$ cd <base directory>/WIN2PhaseNet # return to WIN2PhaseNet directory
$ ./docker-run.bash phasenet

# run PhaseNet on the container environment
(container)$ python phasenet/predict.py --model_dir=model/190703-214543 --data_dir=<npz waveform files path of WIN2PhaseNet> --data_list=<npz.csv path of WIN2PhaseNet> --amplitude
# e.g. 
# (container)$ python phasenet/predict.py --model_dir=model/190703-214543 --data_dir=../WIN2PhaseNet/out/npz --data_list=../WIN2PhaseNet/out/npz.csv --amplitude

# Exit the container environment after execution is complete
(container)$ exit

# You can find the output of PhaseNet in '<base directory>/PhaseNet/results' directory
```

## Notes
* Each docker image is built from the following Dockerfile
    * win2npz: dockerfiles/win2npz/Dockerfile
    * phasenet: dockerfiles/phasenet/Dockerfile

## Acknowledgements
A part of this program was created by Uchida, N and Matsuzawa, T.

## References
* 斎藤 正徳 (1978): 漸化式ディジタルフィルターの自動設計, 物理探鉱, 31, 240-263. (In Japanese)
* Takagi, R., Uchida, N., Nakayama, T., Azuma, R., Ishigami, A., Okada, T., Nakamura, T., & Shiomi, K. (2019), Estimation of the orientations of the S-net cabled ocean-bottom sensors. Seismological Research Letters, 90(6), 2175–2187. https://doi.org/10.1785/0220190093
* Zhu, W., & Beroza, G. C. (2019), PhaseNet: A deep-neural-network-based seismic arrival-time picking method. Geophysical Journal International, 216(1), 261–273. https://doi.org/10.1093/gji/ggy423