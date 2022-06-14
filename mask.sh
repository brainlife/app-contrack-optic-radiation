#!/bin/bash

start_roi=`jq -r '.start_roi' config.json`
term_roi=`jq -r '.term_roi' config.json`
ecc_start_roi=`jq -r '.ecc_start_roi' config.json`
hemis="left right"

# binarize csf
fslmaths csf.nii.gz -bin csf_bin.nii.gz

for hemi in $hemis
do
  if [[ ${hemi} == 'left' ]]; then
    hem="lh"
  else
    hem="rh"
  fi
  
  # make hemispheric eccentricity data by hemisphere
  fslmaths ./eccentricity.nii.gz -mul ${hem}.ribbon.nii.gz ./eccentricity_${hemi}.nii.gz

  # subtract termination ROI from eccentricity
  fslmaths ./eccentricity_${hemi}.nii.gz -mas ./ROI${hem}.${term_roi}.nii.gz ./eccentricity_${hemi}.nii.gz

  # threshold left and right ribbons
  fslmaths ribbon.nii.gz -thr 40 -bin ./ribbon_${hemi}.nii.gz

  # remove start and termination rois from exclusion
  fslmaths ./ROI${hem}.exclusion.nii.gz -sub ./ROI${hem}.${start_roi}.nii.gz -sub ./ROI${hem}.${term_roi}.nii.gz -bin ./ROI${hem}.exclusion.nii.gz

  # remove start and termination rois from csf
  fslmaths ./csf_bin.nii.gz -sub ./ROI${hem}.${start_roi}.nii.gz -sub ./ROI${hem}.${term_roi}.nii.gz -bin ./csf_bin.nii.gz
done