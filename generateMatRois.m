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

%% start ROIs
% equire users to input the roi names of their start rois and parse that
% as a configurable input
startRoi.left = niftiRead(fullfile(sprintf('./ROIlh.%s.nii.gz',config.start_roi)));
startRoi.right = niftiRead(fullfile(sprintf('./ROIrh.%s.nii.gz',config.start_roi)));

for hh = 1:length(hemis)
    % load and inflate roi
    niiName =  [startRoi.(hemis{hh}).fname];
                         
    if isequal(config.inflate_start_roi,1)
        display('no start roi inflation')
    else
        display('inflating start roi inflation')
    end

    roiStart = bsc_roiFromAtlasNums(niiName,1,config.inflate_start_roi);
    
    %% save the ROI
    % nii.gz
    outNiiName =  [fullfile(rois,sprintf('%s_%s_%s.nii.gz',config.start_roi,hemis{hh},num2str(config.inflate_start_roi)))];
    [ni, roiName]=dtiRoiNiftiFromMat(roiStart,niiName,outNiiName,0);
    niftiWrite(ni,outNiiName)

    % mat
    matName =  [fullfile(rois,sprintf('%s_%s_%s.mat',config.start_roi,hemis{hh},num2str(config.inflate_start_roi)))];
    binary = true; save = true;
    dtiRoiFromNifti(outNiiName,0,matName,'mat',binary,save);
    clear ni niiName outNiiName matName binary
end

%% term ROIs
% just require users to input the roi names of their termination rois and parse that
% as a configurable input
termRoi.left = niftiRead(fullfile(sprintf('./ROIlh.%s.nii.gz',config.term_roi)));
termRoi.right = niftiRead(fullfile(sprintf('./ROIrh.%s.nii.gz',config.term_roi)));

for hh = 1:length(hemis)
    % load and inflate roi
    niiName =  [termRoi.(hemis{hh}).fname];
                         
    if isequal(config.inflate_term_roi,1)
        display('no termination roi inflation')
    else
        display('inflating termination roi')
    end

    roiTerm = bsc_roiFromAtlasNums(niiName,1,config.inflate_term_roi);
    
    %% save the ROI
    % nii.gz
    outNiiName =  [fullfile(rois,sprintf('%s_%s_%s.nii.gz',config.term_roi,hemis{hh},num2str(config.inflate_term_roi)))];
    [ni, roiName]=dtiRoiNiftiFromMat(roiTerm,niiName,outNiiName,0);
    niftiWrite(ni,outNiiName)

    % mat
    matName =  [fullfile(rois,sprintf('%s_%s_%s.mat',config.term_roi,hemis{hh},num2str(config.inflate_term_roi)))];
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
