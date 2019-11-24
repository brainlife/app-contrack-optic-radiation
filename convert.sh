#!/bin/bash

#dwi=$(jq -r .dwi config.json)
#bvecs=`jq -r '.bvecs' config.json`
#bvals=`jq -r '.bvals' config.json`
dtiinit=`jq -r '.dtiinit' config.json`
freesurfer=`jq -r '.freesurfer' config.json`
varea=`jq -r '.varea' config.json`
eccentricity=`jq -r '.eccentricity' config.json`
hemi="lh rh"

mkdir tmpSubj
cp -R ${dtiinit} ./tmpSubj/

if [[ ! ${dtiinit} == "null" ]]; then
        export dwi=$dtiinit/`jq -r '.files.alignedDwRaw' $dtiinit/dt6.json`
fi

for HEMI in $hemi
do

	mri_label2vol --seg $freesurfer/mri/${HEMI}.ribbon.mgz --temp ${dwi} --regheader $freesurfer/mri/${HEMI}.ribbon.mgz --o ${HEMI}.ribbon.nii.gz
done

mri_label2vol --seg ${varea} --temp ${dwi} --regheader ${varea} --o varea_whole.nii.gz

mri_label2vol --seg $freesurfer/mri/ribbon.mgz --temp ${dwi} --regheader $freesurfer/mri/ribbon.mgz --o ribbon.nii.gz
