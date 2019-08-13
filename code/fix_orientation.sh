funcs=$(ls ../sub-????/func/*.nii.gz)
for func in ${funcs}; do
  echo "Fixing ${func} ..."
  fslorient -copyqform2sform $func
done

anats=$(ls ../sub-????/anat/*.nii.gz)
for anat in ${anats}; do
  echo "Fixing ${anat} ..."
  fslorient -copysform2qform $anat
  fslorient -copyqform2sform $anat
done

dwis=$(ls ../sub-????/dwi/*.nii.gz)
for dwi in ${dwis}; do
  echo "Fixing ${dwi} ..."
  fslorient -copysform2qform $anat
done
