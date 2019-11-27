#!/bin/bash

eccentricity=`jq -r '.eccentricity' config.json`
freesurfer=`jq -r '.freesurfer' config.json`
dtiinit=`jq -r '.dtiinit' config.json`

mkdir tmpSubj tmpSubj/dtiinit
cp -R ${dtiinit} ./tmpSubj/dtiinit

mri_convert $freesurfer/mri/lh.ribbon.mgz lh.ribbon.nii.gz
mri_convert $freesurfer/mri/rh.ribbon.mgz rh.ribbon.nii.gz
mri_convert $freesurfer/mri/ribbon.mgz ribbon.nii.gz
