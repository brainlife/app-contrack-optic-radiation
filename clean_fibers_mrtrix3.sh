#!/bin/bash

minDegree=(`jq -r '.minDegree' config.json`)
maxDegree=(`jq -r '.maxDegree' config.json`)
inflate_lgn=`jq -r '.inflate_lgn' config.json`
inflate_v1=`jq -r '.inflate_v1' config.json`

rois_dir="./tmpSubj/dtiinit/ROIs"
track_dir="./tmpSubj/dtiinit/dti/fibers/conTrack/OR/"
track="tmp.tck"

hemispheres="left right"

for hemi in ${hemispheres}
do
  if [[ ${hemi} == "left" ]]; then
    hem="lh"
  else
    hem="rh"
  fi

  # grab streamlines that pass through thalLatPost planar ROI, and do not pass through either thalMedPost planar ROI or the exclusion ROIs
  tckedit ${track} -include ./thalLatPost_lgn_${hemi}.nii.gz -exclude ./thalMedPost_lgn_${hemi}.nii.gz -exclude ./tmp.ROI${hem}.exclusion.nii.gz ./${hemi}.tck -force -nthreads 8 -quiet

  for (( i=0; i<${#minDegree[*]}; i++ ))
  do
    tckedit ${hemi}.tck -include ${rois_dir}/Ecc${minDegree[$i]}to${maxDegree[$i]}_${hemi}.nii.gz ${track_dir}/Ecc${minDegree[$i]}to${maxDegree[$i]}_${hemi}.tck
  done
done
