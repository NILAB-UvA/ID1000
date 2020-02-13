dwis=$(ls ../sub-????/dwi/*.nii.gz)
i=0

function fix_dwi {
  fslorient -copysform2qform $1
  fslorient -copyqform2sform $1
}

for dwi in ${dwis}; do
  echo "Fixing ${dwi} ..."
  fix_dwi $dwi &
  i=$(($i + 1))
  if [ $(($i % 9)) = 0 ]; then
    wait
  fi
done

