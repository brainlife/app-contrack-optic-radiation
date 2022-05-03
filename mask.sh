#!/bin/bash

hemis="left right"

for hemi in $hemis
do
  if [[ ${hemi} == 'left' ]]; then
    hem="lh"
  else
    hem="rh"
  fi
  # make hemispheric eccentricity data by hemisphere
  fslmaths ./eccentricity.nii.gz -mul ${hem}.ribbon.nii.gz ./eccentricity_${hemi}.nii.gz

  # mask by v1
  fslmaths ./eccentricity_${hemi}.nii.gz -mas ./ROI${hem}.v1.nii.gz ./eccentricity_${hemi}.nii.gz

  # threshold left and right ribbons
  fslmaths ribbon.nii.gz -thr 40 -bin ./ribbon_${hemi}.nii.gz
done

# binarize csf
fslmaths csf.nii.gz -bin csf_bin.nii.gz
