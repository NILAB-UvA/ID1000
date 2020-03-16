import shutil
import os.path as op
import numpy as np
import nibabel as nib
from glob import glob
from scipy.stats import pearsonr

subs = sorted(glob('sub-*'))
for sub in subs:
    dwis = sorted(glob(sub + '/dwi/*.nii.gz'))
    n_z = np.array([nib.load(d).header['dim'][3] for d in dwis])
    if not all(n_z == n_z[0]):
        min_z = n_z.min()
        d_ref = nib.load(dwis[n_z.argmin()]).get_fdata()[:, :, :, 0]
        for d in dwis:
            d_img = nib.load(d)
            z = d_img.header['dim'][3]
            if z != min_z:
                diff = z - min_z
                d_check = d_img.get_fdata()[:, :, :, 0]
                best = 0
                for i in range(0, diff + 1): # remove from top
                    for ii in range(0, diff + 1):  # remove from bottom
                        if i + ii != diff:
                            continue

                        d_fix = d_check[:, :, i:(z-ii)]
                        corr = pearsonr(d_fix.flatten(), d_ref.flatten())[0]
                        if corr > best:
                            best = corr
                            best_idx = (i, ii)

                print(f"Fixing {d} because z = {z}, but min_z = {min_z}")
                print(f"Best corr = {best}, index = {best_idx}\n")

                shutil.copyfile(d, op.join('..', '..', '..' 'dwi_backup', op.basename(d)))   
                d_data = d_img.get_fdata()
                d_data = d_data[:, :, best_idx[0]:(z-best_idx[1])]
                d_img = nib.Nifti1Image(d_data, affine=d_img.affine)
                d_img.header['dim'][3] = d_img.shape[2]
                #f_out = d.replace('.nii.gz', '_fixed.nii.gz')
                d_img.to_filename(d)
