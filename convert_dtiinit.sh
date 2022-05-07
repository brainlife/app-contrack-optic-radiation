#!/bin/bash

anat=`jq -r '.t1' config.json`

# remove all scripts and derivatives generated from prep step. just needed that for pdf file
rm -rf ./tmpSubj/dtiinit/dti/fibers/conTrack/OR/* ./tmpSubj/ConTrack/OR/shellScripts/* ./tmpSubj/ConTrack/OR/logs/* ./tmpSubj/dtiinit/dti/bin/lgn* ./tmpSubj/dtiinit/ROIs/*

# move b0,wm,and pddDispersion to ribbon ROI space in order to avoid tesselation of ROIs during contrack
files=(`ls ./tmpSubj/dtiinit/dti/bin/`)
for fls in ${files[*]}
do
	cp ./tmpSubj/dtiinit/dti/bin/${fls} ./tmpSubj/dtiinit/dti/bin/${fls#%.nii.gz*}_dtiinit.nii.gz && mri_vol2vol --mov ./tmpSubj/dtiinit/dti/bin/${fls} --targ ${anat} --regheader --interp nearest --o ./tmpSubj/dtiinit/dti/bin/${fls}
done
