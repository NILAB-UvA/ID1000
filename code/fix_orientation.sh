#funcs=$(ls ../sub-????/func/*.nii.gz)
i=0
for func in ${funcs}; do
  echo "Fixing ${func} ..."
  fslorient -copyqform2sform $func &
  i=$(($i + 1))
  if [ $(($i % 8)) = 0 ]; then
    wait
  fi
done
wait

function fix_anat {
  echo "Fixing $1 ..."
  fslorient -copysform2qform $1
  fslorient -copyqform2sform $1
}

i=0
anats=$(ls ../sub-????/anat/*.nii.gz)
for anat in ${anats}; do
  fix_anat $anat &
  i=$(($1 + 1))
  if [ $(($i % 8)) = 0 ]; then
    wait
  fi
done

#dwis=$(ls ../sub-????/dwi/*.nii.gz)
#for dwi in ${dwis}; do
#  echo "Fixing ${dwi} ..."
#  fslorient -copysform2qform $anat
#done
