#!/bin/bash

rois=`jq -r '.rois' config.json`
roi1=`jq -r '.seed_roi' config.json`
roi2=`jq -r '.term_roi' config.json`
eccentricity=`jq -r '.eccentricity' config.json`

if [[ ${roi1} == '008109' ]]; then
	# make left hemisphere eccentricity
	fslmaths ribbon.nii.gz -thr 40 -bin ribbon_right.nii.gz
	fslmaths ${roi2} -mul lh.ribbon.nii.gz v1_left.nii.gz
else
	# make right hemisphere eccentricity
	fslmaths ribbon.nii.gz -uthr 10 -bin ribbon_left.nii.gz
	fslmaths ${roi2} -mul rh.ribbon.nii.gz v1_right.nii.gz
fi

fslmaths csf.nii.gz -bin csf_bin.nii.gz
