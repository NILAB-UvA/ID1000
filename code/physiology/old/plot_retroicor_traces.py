import os.path as op
import pandas as pd
import matplotlib.pyplot as plt
from glob import glob
from tqdm import tqdm


def main(physio):
    sub = op.basename(physio).split('_')[0]
    print(f"Processing {op.basename(physio)} ...")

    df = pd.read_csv(physio, sep='\t')
    for col in df.columns:
        df[col] = (df[col] - df[col].mean()) / df[col].std()

    fig, axes = plt.subplots(figsize=(20, 20), nrows=df.shape[1], sharex=True, sharey=False)
    for i, ax in enumerate(axes):
        ax.plot(df.iloc[:, i], lw=1)
        ax.set_xlim(0, df.shape[0])
        ax.set_title(df.columns[i], fontsize=20)
        
        if i == (df.shape[1] - 1):
            ax.set_xlabel('Time (in samples)', fontsize=15)

        ax.grid()
    
    out_name = op.basename(physio).replace('.tsv', '.png')
    out_dir = f"../../derivatives/physiology/{sub}/figures/{out_name}"
    fig.tight_layout()
    fig.savefig(out_dir)
    plt.close()


if __name__ == '__main__':
    from joblib import Parallel, delayed
    physios = sorted(glob('../../derivatives/physiology/sub-*/physio/*.tsv'))
    Parallel(n_jobs=10)(delayed(main)(physio) for physio in physios)

