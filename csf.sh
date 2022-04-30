#!/bin/bash

mask=`jq -r '.mask' config.json`
anat=`jq -r '.t1' config.json`
NCORE=8

# convert anatomical t1 to mrtrix format
[ ! -f anat.mif ] && mrconvert ${anat} anat.mif -nthreads $NCORE

# generate 5-tissue-type (5TT) tracking mask
if [ ! -f csf.nii.gz ]; then
        if [[ ${mask} == 'null' ]]; then
                [ ! -f 5tt.mif ] && 5ttgen fsl anat.mif 5tt.mif -nocrop -sgm_amyg_hipp -tempdir ./tmp -force -nthreads $NCORE
        else
                echo "input 5tt mask exists. converting to mrtrix format"
                mrconvert ${mask} -stride 1,2,3,4 5tt.mif -force -nthreads $NCORE
        fi

        # generate csf mask
        [ ! -f csf.mif ] && mrconvert -coord 3 3 5tt.mif csf.mif -force -nthreads $NCORE
        [ ! -f csf.nii.gz ] && mrconvert csf.mif -stride 1,2,3,4 csf.nii.gz -force -nthreads $NCORE
else
        echo "csf mask already exits. skipping"
fi
