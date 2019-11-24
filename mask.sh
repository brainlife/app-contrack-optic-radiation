#!/bin/bash

rois=`jq -r '.rois' config.json`
roi1=`jq -r '.seed_roi' config.json`
varea=`jq -r '.varea' config.json`

fslmaths varea_whole.nii.gz -bin varea_bin.nii.gz
if [[ ${roi1} == 008109 ]]; then
	# make left hemisphere eccentricity
	fslmaths varea_bin.nii.gz -mul lh.ribbon.nii.gz varea.nii.gz
else
	# make right hemisphere eccentricity
	fslmaths varea_bin.nii.gz -mul rh.ribbon.nii.gz varea.nii.gz
fi

fslmaths csf.nii.gz csf_bin.nii.gz
