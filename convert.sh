#!/bin/bash

rois=`jq -r '.rois' config.json`
lgn=`jq -r '.lgn' config.json`
prf=`jq -r '.prf' config.json`
v1=`jq -r '.v1' config.json`
freesurfer=`jq -r '.freesurfer' config.json`
dtiinit=`jq -r '.dtiinit' config.json`
hemis="left right"

mkdir tmpSubj tmpSubj/dtiinit
cp -R ${dtiinit}/* ./tmpSubj/dtiinit
cp -R ${prf}/eccentricity.nii.gz ./eccentricity.nii.gz

# reslice eccentricity
# mri_vol2vol --mov ./eccentricity.nii.gz --targ ./tmpSubj/dtiinit/dwi_aligned*.nii.gz --regheader --interp nearest --o ./eccentricity.nii.gz

# convert hemispheric ribbons
for hemi in ${hemis}
do
  if [[ ${hemi} == 'left' ]]; then
    hem="lh"
  else
    hem="rh"
  fi
  mri_convert $freesurfer/mri/${hem}.ribbon.mgz ./${hem}.ribbon.nii.gz

  # reslice
  # mri_vol2vol --mov ./${hem}.ribbon.nii.gz --targ ./tmpSubj/dtiinit/dwi_aligned*.nii.gz --regheader --interp nearest --o ./${hem}.ribbon.nii.gz

  # copy over lgn and v1
  cp -R ${rois}/*${hem}.${lgn}.nii.gz ./ROI${hem}.lgn.nii.gz
  cp -R ${rois}/*${hem}.${v1}.nii.gz ./ROI${hem}.v1.nii.gz
  [ -f ${rois}/*${hem}.exclusion.nii.gz ] && cp -R ${rois}/*${hem}.exclusion.nii.gz ./ROI${hem}.exclusion.nii.gz
done

# convert ribbon
mri_convert $freesurfer/mri/ribbon.mgz ribbon.nii.gz

# reslice ribbon
# mri_vol2vol --mov ./ribbon.nii.gz --targ ./tmpSubj/dtiinit/dwi_aligned*.nii.gz --regheader --interp nearest --o ./ribbon.nii.gz

# reslice csf
# mri_vol2vol --mov ./csf.nii.gz --targ ./tmpSubj/dtiinit/dwi_aligned*.nii.gz --regheader --interp nearest --o ./csf.nii.gz
