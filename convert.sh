#!/bin/bash

freesurfer=`jq -r '.freesurfer' config.json`
dtiinit=`jq -r '.dtiinit' config.json`
eccentricity=`jq -r '.eccentricity' config.json`
input_nii_gz=$dtiinit/`jq -r '.files.alignedDwRaw' $dtiinit/dt6.json`


mkdir tmpSubj tmpSubj/dtiinit
cp -R ${dtiinit} ./tmpSubj/dtiinit

mri_vol2vol --mov csf_pre.nii.gz --targ ${input_nii_gz} --regheader --o csf.nii.gz

mri_vol2vol --mov ${freesurfer}/mri/lh.ribbon.mgz --targ ${input_nii_gz} --regheader --o lh.ribbon.nii.gz

mri_vol2vol --mov ${freesurfer}/mri/rh.ribbon.mgz --targ ${input_nii_gz} --regheader --o rh.ribbon.nii.gz

mri_vol2vol --mov ${freesurfer}/mri/ribbon.mgz --targ ${input_nii_gz} --regheader --o ribbon.nii.gz

mri_vol2vol --mov ${freesurfer}/mri/aparc.a2009s+aseg.mgz --targ ${input_nii_gz} --regheader --o aparc.a2009s.aseg.nii.gz

mri_vol2vol --mov ${eccentricity} --targ ${input_nii_gz} --regheader --o eccentricity.nii.gz
