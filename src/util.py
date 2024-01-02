import numpy as np
import pandas as pd
import datetime

def count_non_nan(data):
    is_nan_data = np.array(list(map(np.isnan, data)))
    return is_nan_data.size - np.count_nonzero(is_nan_data)

def load_npz(fname):
    raw_npz = np.load(fname)
    file_key = raw_npz.files[0] #win2npzに並列処理を実装した関係でkeyが適当なので、呼び出して1つめの属性をloadする(本来は'data')
    array = raw_npz[file_key]
    return array

def load_csv(fname, header='infer'):
    df = pd.read_csv(fname, header=header)

    # win_nameをindexに設定
    if 'win_name' in df.columns:
        df = df.set_index('win_name', drop=False)

    # 同イベント・同観測点の行がある場合はエラー
    if ('win_name' in df.columns) and ('station' in df.columns):
        duplicated_flag = df.duplicated(subset=['win_name', 'station'])
        if duplicated_flag.sum() != 0:
            print("[Error: Duplicated row is not acceptable]:", fname)
            print(df[duplicated_flag])
            exit(1)
    
    # stnlistに入れていてもNpzConverterで無視されてしまう観測点が入っている場合は警告
    if 'station' in df.columns:
        for station in df['station'].values:
            if station in ["N.HD2H", "N.MORH", "N.TRUH"]:
                print("[Warn: NpzConverter ignores paticular stations]:", station, '(at least)')
                break

    return df

def read_wavename(baseFname, format):
    filetime = datetime.datetime.strptime(baseFname, format).strftime("%y%m%d%H%M%S")
    # print(baseFname, format, filetime)
    return filetime