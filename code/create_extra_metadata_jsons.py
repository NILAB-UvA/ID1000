import numpy as np 
import nibabel as nib
import json

N_SLICES = 42
TR = 2
slicetimes = np.linspace(0, TR - TR / N_SLICES, N_SLICES).round(4).tolist()

wfs_hz =  434.214
wfs_ppm = 12.482
sense_acc = 1
npe = 64

ees = wfs_ppm / (wfs_hz * (npe / sense_acc))
trt = ees * (npe / sense_acc - 1)

info = dict(
    RepetitionTime=2.2,
    EchoTime=0.028,
    TaskName='moviewatching',
    PhaseEncodingDirection='j',
    SliceEncodingDirection='i-',
    ParallelReductionFactorInPlane=0,
    FlipAngle=90,
    WaterFatShift=wfs_ppm,
    PulseSequenceType="gradient echo EPI",
    NumberOfVolumesDiscardedByScanner=1,
    EffectiveEchoSpacing=ees,
    TotalReadoutTime=trt,
    SliceTiming=slicetimes
)

f_out = f'../task-moviewatching_bold.json'
with open(f_out, 'w') as f:
    json.dump(info, f, indent=4)

# dwi stuff
npe = 112
wfs_ppm = 12.861
sense_acc = 3
ees = wfs_ppm / (wfs_hz * (npe / sense_acc))
trt = ees * (npe / sense_acc - 1)

info = dict(
    RepetitionTime=6.353,
    EchoTime=0.075,
    PhaseEncodingDirection='j',
    SliceEncodingDirection='k',
    ParallelAcquisitionTechnique='SENSE',
    ParallelReductionFactorInPlane=3,
    FlipAngle=90,
    WaterFatShift=wfs_ppm,
    PulseSequenceType='spin echo EPI',
    EffectiveEchoSpacing=ees,
    TotalReadoutTime=trt
)

f_out = f'../dwi.json'
with open(f_out, 'w') as f:
    json.dump(info, f, indent=4)

info = dict(
    RepetitionTime=0.081,
    EchoTime=0.037,
    PhaseEncodingDirection=['i-', 'j-'],
    ParallelAcquisitionTechnique='SENSE',
    ParallelReductionFactorInPlan=[1, 1.5],
    FlipAngle=8,
    WaterFatShift=2.268,
    PulseSequenceType='3D fast-field echo'
)

f_out = '../T1w.json'
with open(f_out, 'w') as f:
    json.dump(info, f, indent=4)

