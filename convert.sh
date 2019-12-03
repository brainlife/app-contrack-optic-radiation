#!/bin/bash

freesurfer=`jq -r '.freesurfer' config.json`
dtiinit=`jq -r '.dtiinit' config.json`
eccentricity=`jq -r '.eccentricity' config.json`

mkdir tmpSubj tmpSubj/dtiinit
cp -R ${dtiinit} ./tmpSubj/dtiinit

mri_vol2vol --mov csf_pre.nii.gz --targ ./tmpSubj/dtiinit/dwi_aligned_trilin_noMEC.nii.gz --regheader --o csf.nii.gz

mri_vol2vol --mov ${freesurfer}/mri/lh.ribbon.mgz --targ ./tmpSubj/dtiinit/dwi_aligned_trilin_noMEC.nii.gz --regheader --o lh.ribbon.nii.gz

mri_vol2vol --mov ${freesurfer}/mri/rh.ribbon.mgz --targ ./tmpSubj/dtiinit/dwi_aligned_trilin_noMEC.nii.gz --regheader --o rh.ribbon.nii.gz

mri_vol2vol --mov ${freesurfer}/mri/ribbon.mgz --targ ./tmpSubj/dtiinit/dwi_aligned_trilin_noMEC.nii.gz --regheader --o ribbon.nii.gz

mri_vol2vol --mov ${freesurfer}/mri/aparc.a2009s+aseg.mgz --targ ./tmpSubj/dtiinit/dwi_aligned_trilin_noMEC.nii.gz --regheader --o aparc.a2009s.aseg.nii.gz

mri_vol2vol --mov ${eccentricity} --targ ./tmpSubj/dtiinit/dwi_aligned_trilin_noMEC.nii.gz --regheader --o eccentricity.nii.gz
