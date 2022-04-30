#!/bin/bash

rois=`jq -r '.rois' config.json`
lgn=`jq -r '.lgn' config.json`
eccentricity=`jq -r '.eccentricity' config.json`
v1=`jq -r '.v1' config.json`
freesurfer=`jq -r '.freesurfer' config.json`
dtiinit=`jq -r '.dtiinit' config.json`
hemis="left right"

mkdir tmpSubj tmpSubj/dtiinit
cp -R ${dtiinit}/* ./tmpSubj/dtiinit && chmod -R +w tmpSubj/*
cp -R ${eccentricity} ./eccentricity.nii.gz

# convert hemispheric ribbons
for hemi in ${hemis}
do
  if [[ ${hemi} == 'left' ]]; then
    hem="lh"
  else
    hem="rh"
  fi
  mri_convert $freesurfer/mri/${hem}.ribbon.mgz ./${hem}.ribbon.nii.gz

  # copy over lgn and v1
  cp -R ${rois}/*${hem}.${lgn}.nii.gz ./ROI${hem}.lgn.nii.gz
  cp -R ${rois}/*${hem}.${v1}.nii.gz ./ROI${hem}.v1.nii.gz
  [ -f ${rois}/*${hem}.exclusion.nii.gz ] && cp -R ${rois}/*${hem}.exclusion.nii.gz ./ROI${hem}.exclusion.nii.gz
done

# convert ribbon
mri_convert $freesurfer/mri/ribbon.mgz ribbon.nii.gz
