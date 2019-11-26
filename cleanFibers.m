function [classification,mergedFG] = cleanFibers()

% variables
orFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','OR','*.pdb'));

%% Generate NOT ROIs
% CSF ROI
csfROI = bsc_loadAndParseROI('csf_bin.nii.gz');

%% Load Optic radiations and clip for cleaning
% load and clip optic radiations
for ifg = 1:length(orFibersDir)
	fgPath{ifg} = fullfile(orFibersDir(ifg).folder,orFibersDir(ifg).name);
end

% need specific modification to how pdb fgs are loaded
[mergedFG,classification] = bsc_mergeFGandClass_pdb(fgPath);

classification.names = {'left-macular-or','left-periphery-or','left-farperiphery-or','right-macular-or','right-periphery-or','right-farperiphry-or'};

mergedFG.name = 'optic_radiation';
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

% clip hemispheres and CSF for OR
for ifg = 1:length(classification.names)
	tractFG.name = classification.names{ifg};
	tractFG.colorRgb = mergedFG.colorRgb;
	display(sprintf('%s',tractFG.name))
	indexes = find(classification.index == ifg);
	tractFG.fibers = mergedFG.fibers(indexes);
	[keep] = dtiIntersectFibersWithRoi_bl([],'not',[],csfROI,tractFG);
	% set indices of streamlines that intersect the not ROI to 0 as if they
	% have never been classified
	classification.index(indexes(~keep)) = 0;
end
