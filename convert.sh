#!/bin/bash

rois=`jq -r '.rois' config.json`
start_roi=`jq -r '.start_roi' config.json`
eccentricity=`jq -r '.eccentricity' config.json`
term_roi=`jq -r '.term_roi' config.json`
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

  # copy over start and term rois
  cp -R ${rois}/*${hem}.${start_roi}.nii.gz ./tmp.ROI${hem}.${start_roi}.nii.gz && mri_vol2vol --mov ./tmp.ROI${hem}.${start_roi}.nii.gz --targ ${anat} --regheader --interp nearest --o ./ROI${hem}.${start_roi}.nii.gz
  cp -R ${rois}/*${hem}.${term_roi}.nii.gz ./tmp.ROI${hem}.${term_roi}.nii.gz && mri_vol2vol --mov ./tmp.ROI${hem}.${term_roi}.nii.gz --targ ${anat} --regheader --interp nearest --o ./ROI${hem}.${term_roi}.nii.gz
  [ -f ${rois}/*${hem}.exclusion.nii.gz ] && cp -R ${rois}/*${hem}.exclusion.nii.gz ./tmp.ROI${hem}.exclusion.nii.gz  && mri_vol2vol --mov ./tmp.ROI${hem}.exclusion.nii.gz --targ ${anat} --regheader --interp nearest --o ./ROI${hem}.exclusion.nii.gz
done

# convert ribbon
mri_convert $freesurfer/mri/ribbon.mgz tmp.ribbon.nii.gz && mri_vol2vol --mov ./tmp.ribbon.nii.gz --targ ${anat} --regheader --interp nearest --o ./ribbon.nii.gz

mri_vol2vol --mov ./tmp.csf.nii.gz --targ ${anat} --regheader --interp neareast --o ./csf.nii.gz
