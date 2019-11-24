function [classification,mergedFG] = cleanFibers(seedroi)

% variables
orFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','OR','*.pdb'));

if seedroi == '008109'
	hemi = 'left';
else
	hemi = 'right';
end

%% Generate NOT ROIs
% CSF ROI
csfROI = bsc_loadAndParseROI('csf_bin.nii.gz');

% Planar ROI
% load reference nifti for planar ROI
if strcmp(hemi,'left')
    hemisphereROI = bsc_loadAndParseROI('rh.ribbon.nii.gz');
else
    hemisphereROI = bsc_loadAndParseROI('lh.ribbon.nii.gz');
end

% create not ROI
Not = bsc_mergeROIs(hemisphereROI,csfROI);

%% Load Optic radiations and clip for cleaning
% load and clip optic radiations
fgPath = {fullfile(orFibersDir(1).folder,orFibersDir(1).name)};

% need specific modification to how pdb fgs are loaded
[mergedFG,classification] = bsc_mergeFGandClass(fgPath);

classification.names = {sprintf('%s-optic-radiation',hemi)};

mergedFG.name = sprintf('%s_optic_radiation',hemi);
% find better way to index this
mergedFG.params = {};
mergedFG.params{1} = 'mrtrix_header';
mergedFG.params{2}{1} = 'mrtrix tracks    ';
mergedFG.params{2}{2} = 'mrtrix_version: 3.0_RC3';
mergedFG.params{2}{3} = 'timestamp: 1573277529.4060957432';
mergedFG.params{2}{4} = 'datatype: Float32LE';
mergedFG.params{2}{5} = 'file: . 160';
mergedFG.params{2}{6} = sprintf('count: %s',num2str(length(mergedFG.fibers)));
mergedFG.params{2}{7} = sprintf('total_count: %s',num2str(length(mergedFG.fibers)));


% save tck
dtiExportFibersMrtrix_tracks(mergedFG,'track.tck');

% create not ROI
Not = bsc_mergeROIs(hemisphereROI,csfROI);

% clip hemispheres and CSF for OR
for ifg = 1:length(classification)
    tractFG.name = classification.names{ifg};
    tractFG.colorRgb = mergedFG.colorRgb;
    display(sprintf('%s',tractFG.name))
    indexes = find(classification.index == ifg);
    tractFG.fibers = mergedFG.fibers(indexes);
    if strcmp(extractBefore(tractFG.name,'-'),'left')
        [~,~,keep,~] = dtiIntersectFibersWithRoi([],'not',[],Not,tractFG);
    else
        [~,~,keep,~] = dtiIntersectFibersWithRoi([],'not',[],Not,tractFG);
    end
    % set indices of streamlines that intersect the not ROI to 0 as if they
    % have never been classified
    classification.index(indexes(~keep)) = 0;
end
