""" Example usage of Python interface of scanphyslog2bids.
This shows how to set up a parallelized conversion workflow. """

import numpy as np
import os.path as op
import nibabel as nib
from glob import glob
from scanphyslog2bids import PhilipsPhysioLog
from joblib import Parallel, delayed


def _run_parallel(log):
    """ Function for Parallel call """

    TRIGGER_METHOD = 'interpolate'
    sub = op.basename(log).split('_')[0]
    nii = log.replace('_recording-respcardiac_physio.log', '_bold.nii.gz')
    vols = nib.load(nii).shape[-1]
    tr = np.round(nib.load(nii).header['pixdim'][4], 3)
    print(f'\nProcessing {log}: dyns={vols}, TR={tr:.3f}, method={TRIGGER_METHOD}')

    phlog = PhilipsPhysioLog(f=log, tr=tr, n_dyns=vols, sf=496, manually_stopped=False)  # init
    phlog.load()
    phlog.align(trigger_method=TRIGGER_METHOD)  # load and find vol triggers
    out_dir = op.join(f'../../derivatives/physiology/{sub}/figures')
    phlog.plot_alignment(out_dir=out_dir)  # plots alignment with gradient
    phlog.to_bids()  # writes out .tsv.gz and .json files
    phlog.plot_traces(out_dir=out_dir)
    phlog.plot_alignment(out_dir=out_dir)


logs = sorted(glob('../../sub-*/func/*_physio.log'))
Parallel(n_jobs=5)(delayed(_run_parallel)(log) for log in logs)
