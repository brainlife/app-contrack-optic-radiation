#!/bin/bash

rois=`jq -r '.rois' config.json`
start_roi=`jq -r '.start_roi' config.json`
start_roi=(`echo ${start_roi}`)
term_roi=`jq -r '.term_roi' config.json`
term_roi=(`echo ${term_roi}`)
exclusion_roi=`jq -r '.exclusion_roi' config.json`
exclusion_roi=(`echo ${exclusion_roi}`)
eccentricity=`jq -r '.eccentricity' config.json`
freesurfer=`jq -r '.freesurfer' config.json`
dtiinit=`jq -r '.dtiinit' config.json`
anat=`jq -r '.t1' config.json`
hemis="left right"

mkdir tmpSubj tmpSubj/dtiinit
cp -R ${dtiinit}/* ./tmpSubj/dtiinit && chmod -R +w tmpSubj/*
cp -R ${eccentricity} ./tmp.eccentricity.nii.gz && mri_vol2vol --mov ./tmp.eccentricity.nii.gz --targ ${anat} --regheader --interp nearest --o ./eccentricity.nii.gz

# convert hemispheric ribbons
for hemi in ${hemis}
do
  if [[ ${hemi} == 'left' ]]; then
    hem="lh"
  else
    hem="rh"
  fi
  mri_convert $freesurfer/mri/${hem}.ribbon.mgz ./tmp.${hem}.ribbon.nii.gz && mri_vol2vol --mov ./tmp.${hem}.ribbon.nii.gz --targ ${anat} --regheader --interp nearest --o ./${hem}.ribbon.nii.gz
done

for (( h=0; h<${#start_roi[*]}; h++ ))
do
  # copy over start and term rois
  cp -R ${rois}/*${start_roi[$h]}.nii.gz ./tmp.ROI.${start_roi[$h]}.nii.gz && mri_vol2vol --mov ./tmp.ROI.${start_roi[$h]}.nii.gz --targ ${anat} --regheader --interp nearest --o ./ROI.${start_roi[$h]}.nii.gz
  cp -R ${rois}/*${term_roi[$h]}.nii.gz ./tmp.ROI.${term_roi[$h]}.nii.gz && mri_vol2vol --mov ./tmp.ROI.${term_roi[$h]}.nii.gz --targ ${anat} --regheader --interp nearest --o ./ROI.${term_roi[$h]}.nii.gz
  cp -R ${rois}/*${exclusion_roi[$h]}.nii.gz ./tmp.ROI.${exclusion_roi[$h]}.nii.gz  && mri_vol2vol --mov ./tmp.ROI$.${exclusion_roi[$h]}.nii.gz --targ ${anat} --regheader --interp nearest --o ./ROI.${exclusion_roi[$h]}.nii.gz
done

# convert ribbon
mri_convert $freesurfer/mri/ribbon.mgz tmp.ribbon.nii.gz && mri_vol2vol --mov ./tmp.ribbon.nii.gz --targ ${anat} --regheader --interp nearest --o ./ribbon.nii.gz

mri_vol2vol --mov ./tmp.csf.nii.gz --targ ${anat} --regheader --interp neareast --o ./csf.nii.gz
