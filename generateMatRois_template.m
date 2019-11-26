function [] = generateMatRois()

if ~isdeployed
    switch getenv('ENV')
    case 'IUHPC'
        disp('loading paths (HPC) - hayashis')
        addpath(genpath('/N/u/brlife/git/vistasoft'))
        addpath(genpath('/N/u/brlife/git/jsonlab'))
    case 'VM'
        disp('loading paths (VM)')
        addpath(genpath('/usr/local/vistasoft'))
        addpath(genpath('/usr/local/jsonlab'))
    end
end

% load my own config.json
config = loadjson('config.json')

% parse inputs
roisDir = fullfile(config.rois);

% set hemispheres
hemis = {'left','right'};

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
lgn.left = niftiRead(fullfile(roisDir,'ROI008109.nii.gz'));
lgn.right = niftiRead(fullfile(roisDir,'ROI008209.nii.gz'));

for hh = 1:length(hemis)
    niiName =  [lgn.(hemis{hh}).fname];
    roiLgn = dtiRoiFromNifti(niiName,0,fullfile(rois,sprintf('lgn_%s.mat',hemis{hh})),...
                         'mat',true,true);
    clear niiName roiLgn
                     
    % inflation? TO DO LATER
end

%% eccentricity ROIs
eccen.left = niftiRead('eccentricity_left.nii.gz');
eccen.right = niftiRead('eccentricity_right.nii.gz');

MinDegree = [0 5 15];
MaxDegree = [5 15 90];

% save rois based on eccentricity
for hh = 1:length(hemis)
    for ii = 1:length(MinDegree)
        % code from Yoshimine et al paper (MAKE SURE TO CITE IN REPO)
        tmp = eccen.(hemis{hh});
        tmp.data(eccen.(hemis{hh}).data(:,:,:) >= MaxDegree(ii))=0;
        tmp.data(eccen.(hemis{hh}).data(:,:,:) < MinDegree(ii))=0;
        tmp.data(tmp.data > 0) = 1;

        % ROI name
        tmp.fname = fullfile(sprintf('Ecc%dto%d',MinDegree(ii),MaxDegree(ii)));

        %% save the ROI
        % nii.gz
        niiName =  [rois,tmp.fname,sprintf('_%s.nii.gz',hemis{hh})];
        niftiWrite(tmp,niiName)

        % mat
        matName =  [rois,tmp.fname,sprintf('_%s.mat',hemis{hh})];
        binary = true; save = true;
        dtiRoiFromNifti(niiName,0,matName,'mat',binary,save);
        clear tmp niiName matName binary
    end
end

%% VOF ROIs (TODO LATER)