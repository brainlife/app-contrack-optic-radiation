#!/bin/bash

start_roi=`jq -r '.start_roi' config.json`
start_roi=(`echo ${start_roi}`)
term_roi=`jq -r '.term_roi' config.json`
term_roi=(`echo ${term_roi}`)
exclusion_roi=`jq -r '.exclusion_roi' config.json`
exclusion_roi=(`echo ${exclusion_roi}`)
hemis="left right"

# binarize csf
fslmaths csf.nii.gz -bin csf_bin.nii.gz

for hemi in $hemis
do
  # threshold left and right ribbons
  fslmaths ribbon.nii.gz -thr 40 -bin ./ribbon_${hemi}.nii.gz
done


# remove start and termination rois from exclusion and csf
for (( i=0; i<${#start_roi[*]}; i++ ))
do
    fslmaths ./ROI.${exclusion_roi[$i]}.nii.gz -sub ./ROI.${start_roi[$i]}.nii.gz -sub ./ROI.${term_roi[$i]}.nii.gz -bin ./ROI.${exclusion_roi}.nii.gz
    fslmaths ./csf_bin.nii.gz -sub ./ROI.${start_roi[$i]}.nii.gz -sub ./ROI.${term_roi[$i]}.nii.gz -bin ./csf_bin_${start_roi[$i]}_${term_roi[$i]}.nii.gz
done