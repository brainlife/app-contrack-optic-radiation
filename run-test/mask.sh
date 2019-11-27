#!/bin/bash

rois=`jq -r '.rois' config.json`
roi1=`jq -r '.seed_roi' config.json`
eccentricity=`jq -r '.eccentricity' config.json`

# make left hemisphere eccentricity
fslmaths $eccentricity -mul lh.ribbon.nii.gz eccentricity_left.nii.gz
# make right hemisphere eccentricity
fslmaths $eccentricity -mul rh.ribbon.nii.gz eccentricity_right.nii.gz

fslmaths csf.nii.gz -bin csf_bin.nii.gz

fslmaths ribbon.nii.gz -thr 40 -bin ribbon_right.nii.gz
fslmaths ribbon.nii.gz -uthr 10 -bin ribbon_left.nii.gz
