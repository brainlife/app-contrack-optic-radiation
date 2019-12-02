function [] = generateMatRois(config,seedroi)

roisDir = config.rois;
if seedroi == '008109'
	hemi = 'left';
else
	hemi = 'right';
end
lgn = niftiRead(fullfile(roisDir,sprintf('ROI%s.nii.gz',seedroi)));

% set local rois directory to save .mat files
rois = fullfile('tmpSubj','dtiinit','ROIs/');
if ~exist(rois)
    mkdir(rois);
end

%% lgn ROIs
% need to remove hard coding of ROI names for lgn in case someone uses
% something other than freesurfer thalamic nuclei segmentation. basically
% just require users to input the roi numbers of their lgns and parse that
% as a configurable input
niiName =  [lgn.fname];
roiLgn = dtiRoiFromNifti(niiName,0,fullfile(rois,sprintf('lgn_%s.mat',hemi)),...
                     'mat',true,true);                 
% inflation? TO DO LATER

%% visual area ROIs
v1 = niftiRead(sprintf('v1_%s.nii.gz',hemi));

%% save the ROI
% mat
tmp = v1;
matName =  [rois,extractBefore(tmp.fname,'.nii.gz'),'.mat'];
binary = false; save = true;
dtiRoiFromNifti(tmp.fname,0,matName,'mat',binary,save);
clear tmp niiName matName binary
