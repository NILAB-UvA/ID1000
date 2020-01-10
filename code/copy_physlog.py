import shutil
import numpy as np
import os.path as op
from glob import glob

folders = sorted(glob('../../Heartrate-MR/ID????_HR'))
for folder in folders:
    print(folder)
    files = sorted(glob(folder + '/*.log'))
    sizes = np.array([op.getsize(f) for f in files])
    idx = np.where(sizes == np.max(sizes))[0]
    if sizes[idx] < 9000000:
        continue
    if len(idx) > 1:
        print("Too many!")
        continue

    print(sizes[idx[0]] / 1000000)
    f = files[idx[0]]
    sub_nr = op.basename(folder)[2:6]
    f_out = f'sub-{sub_nr}_task-moviewatching_recording-respcardiac_physio.log'
    dst_dir = f'../sub-{sub_nr}/func'
    if op.isdir(dst_dir):
        print(f_out)
        shutil.copyfile(f, op.join(dst_dir, f_out))
    
