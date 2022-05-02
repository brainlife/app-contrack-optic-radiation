function [] = generateMatRois(config,MinDegree,MaxDegree)

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
lgn.left = niftiRead(fullfile('./ROIlh.lgn.nii.gz'));
lgn.right = niftiRead(fullfile('./ROIrh.lgn.nii.gz'));

for hh = 1:length(hemis)
    % load and inflate roi
    niiName =  [lgn.(hemis{hh}).fname];
                         
    if isequal(config.inflate_lgn,1)
        display('no lgn inflation')
    else
        display('inflating lgn')
    end

    roiLgn = bsc_roiFromAtlasNums(niiName,1,config.inflate_lgn);
    
    %% save the ROI
    % nii.gz
    outNiiName =  [fullfile(rois,sprintf('lgn_%s_%s.nii.gz',hemis{hh},num2str(config.inflate_lgn)))];
    [ni, roiName]=dtiRoiNiftiFromMat(roiLgn,niiName,outNiiName,0);
    niftiWrite(ni,outNiiName)

    % mat
    matName =  [fullfile(rois,sprintf('lgn_%s_%s.mat',hemis{hh},num2str(config.inflate_lgn)))];
    binary = true; save = true;
    dtiRoiFromNifti(outNiiName,0,matName,'mat',binary,save);
    clear ni niiName outNiiName matName binary
end

%% eccentricity ROIs
for hh = 1:length(hemis)
	eccen.(hemis{hh}) = niftiRead(sprintf('eccentricity_%s.nii.gz',hemis{hh}));
end

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
        
        outv1name = [rois,tmp.fname,sprintf('_%s_%s.nii.gz',hemis{hh},num2str(config.inflate_v1))];
        v1 = bsc_roiFromAtlasNums(tmp,1,config.inflate_v1);

        [v1, v1Name]=dtiRoiNiftiFromMat(v1,niiName,outv1name,1);

        % mat
        matName =  [rois,tmp.fname,sprintf('_%s_%s.mat',hemis{hh},num2str(config.inflate_v1))];

        binary = true; save = true;
        dtiRoiFromNifti(niiName,0,matName,'mat',binary,save);
        clear tmp niiName matName binary
    end
end
