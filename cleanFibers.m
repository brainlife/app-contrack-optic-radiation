function [classification,mergedFG] = cleanFibers(topDir,threshold,config,minDegree,maxDegree)

% variables
rois = fullfile('tmpSubj','dtiinit','ROIs/');
orFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','OR','fg_*.pdb'));
% 
%% Generate AND & NOT ROIs for fiber cleaning and selection
% hemisphere
hemi = {'left','right'};

for hh = 1:length(hemi)
	if strcmp(hemi{hh},'left')
		hemisphereROI.(hemi{hh}) = bsc_loadAndParseROI('ribbon_right.nii.gz');
        exclusionROI.(hemi{hh}) = bsc_loadAndParseROI('ROIlh.exclusion.nii.gz');
        lgnROI.(hemi{hh}) = bsc_loadAndParseROI([rois,sprintf('lgn_left_%s.nii.gz',num2str(config.inflate_lgn))]);
        referenceNifti.(hemi{hh}) = niftiRead([rois,sprintf('lgn_left_%s.nii.gz',num2str(config.inflate_lgn))]);
	else
		hemisphereROI.(hemi{hh}) = bsc_loadAndParseROI('ribbon_left.nii.gz');
        exclusionROI.(hemi{hh}) = bsc_loadAndParseROI('ROIrh.exclusion.nii.gz');
        lgnROI.(hemi{hh}) = bsc_loadAndParseROI([rois,sprintf('lgn_right_%s.nii.gz',num2str(config.inflate_lgn))]);
        referenceNifti.(hemi{hh}) = niftiRead([rois,sprintf('lgn_right_%s.nii.gz',num2str(config.inflate_lgn))]);
	end
end

% CSF ROI
csfROI = bsc_loadAndParseROI('csf_bin.nii.gz');

% % NOT ROIs
for hh = 1:length(hemi)
	Not.(hemi{hh}) = bsc_mergeROIs(exclusionROI.(hemi{hh}),csfROI);
    Not.(hemi{hh}) = bsc_mergeROIs(Not.(hemi{hh}),hemisphereROI.(hemi{hh}));
end

% planar rois
for hh = 1:length(hemi)
    posteriorThalLimit.(hemi{hh}) = bsc_planeFromROI_v2([lgnROI.(hemi{hh})],'posterior',referenceNifti.(hemi{hh}));
    anteriorThalLimit.(hemi{hh}) = bsc_planeFromROI_v2([lgnROI.(hemi{hh})],'anterior',referenceNifti.(hemi{hh}));
    
    midantcoords = anteriorThalLimit.(hemi{hh}).coords;
    midantcoords(:,2) = (midantcoords(:,2) - 20);
    posteriorThalLimitCropped.(hemi{hh}) = posteriorThalLimit.(hemi{hh});
    posteriorThalLimitCropped.(hemi{hh}).coords = midantcoords;
    
    lateralThalLimit.(hemi{hh}) = bsc_planeFromROI_v2([lgnROI.(hemi{hh})],'lateral',referenceNifti.(hemi{hh}));
    medialThalLimit.(hemi{hh}) = bsc_planeFromROI_v2([lgnROI.(hemi{hh})],'medial',referenceNifti.(hemi{hh}));

    posteriorThalLimitSub.(hemi{hh}) = posteriorThalLimit.(hemi{hh});
    posteriorThalLimitSub.(hemi{hh}).coords(:,3) = posteriorThalLimit.(hemi{hh}).coords(:,3) - 15;
    thalMedPostSub.(hemi{hh}) = bsc_modifyROI_v2(referenceNifti.(hemi{hh}),posteriorThalLimitSub.(hemi{hh}),lateralThalLimit.(hemi{hh}),'medial');

    thalLatPost.(hemi{hh}) = bsc_modifyROI_v2(referenceNifti.(hemi{hh}),lateralThalLimit.(hemi{hh}),posteriorThalLimitCropped.(hemi{hh}),'anterior');
    
    thalMedPost.(hemi{hh}) = bsc_modifyROI_v2(referenceNifti.(hemi{hh}),medialThalLimit.(hemi{hh}),posteriorThalLimit.(hemi{hh}),'anterior');
    
     [~,~] = dtiRoiNiftiFromMat(thalLatPost.(hemi{hh}),referenceNifti.(hemi{hh}),sprintf('thalLatPost_lgn_%s.nii.gz',hemi{hh}),true);
     [~,~] = dtiRoiNiftiFromMat(thalMedPost.(hemi{hh}),referenceNifti.(hemi{hh}),sprintf('thalMedPost_lgn_%s.nii.gz',hemi{hh}),true);
     [~,~] = dtiRoiNiftiFromMat(thalMedPostSub.(hemi{hh}),referenceNifti.(hemi{hh}),sprintf('thalMedPostSub_lgn_%s.nii.gz',hemi{hh}),true);
end

%% Score fibers to get best streamlines possible
textPaths = dir(fullfile(topDir,'/tmpSubj/dtiinit/dti/fibers/conTrack/OR/ctrSampler_OR*.txt'));
for i = 1:length(textPaths)
    % set up names and variables for score
    textPath = fullfile(sprintf('%s/%s',textPaths(i).folder,textPaths(i).name));
    track_pdb_name = extractBetween(textPaths(i).name,'OR_','.txt');
    pdbPath = fullfile(sprintf('%s/fg_OR_%s.pdb',textPaths(i).folder,track_pdb_name{1}));
    pdbOutPath = fullfile(sprintf('%s/contrack_pruned_fg_OR_%s.pdb',textPaths(i).folder,track_pdb_name{1}));

    % write command
    scoreCmd = sprintf('%s/contrack_score.glxa64 -i %s -p %s --thresh %s --sort %s',topDir,textPath,pdbOutPath,num2str(threshold),pdbPath)
    
    % run command
    system(scoreCmd)
end

%% grab fibers that cross specific boundaries
orFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','OR','contrack_pruned_*.pdb'));

for ifg = 1:length(orFibersDir)
	fgPath{ifg} = fgRead(fullfile(orFibersDir(ifg).folder,orFibersDir(ifg).name));
end

[mergedFG,classification] = bsc_mergeFGandClass([fgPath]);

for ifg = 1:length(fgPath)
    classification.names(ifg) = strcat(extractBefore(fgPath{ifg}.name,'_lgn'),'_',extractBetween(fgPath{ifg}.name,'fg_OR_','_20'));
end

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
dtiExportFibersMrtrix_tracks(mergedFG,'tmp.tck');


% for ifg = 1:length(orFibersDir)
%     fg = fgRead(sprintf('%s/%s',orFibersDir(ifg).folder,orFibersDir(ifg).name));
%     hem = extractBetween(orFibersDir(ifg).name,'lgn_',sprintf('_%s',num2str(config.inflate_lgn)));
    
%     [fg,~,keep1,~] = dtiIntersectFibersWithRoi([],'and',[],thalLatPost.(hem{1}),fg);
%     [fg,~,keep2,~] = dtiIntersectFibersWithRoi([],'not',[],thalMedPostSub.(hem{1}),fg);
% %     [fg,~,keep3,~] = dtiIntersectFibersWithRoi([],'not',[],anteriorThalLimit.(hem{1}),fg);

%     mtrExportFibers(fg,sprintf('%s/lgn_planes_pruned_contrack_pruned_%s',orFibersDir(ifg).folder,orFibersDir(ifg).name),[],[],[],3)
% end

% %% Load Optic radiations and clip for cleaning
% % load and clip optic radiations
% orFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','OR','lgn_planes_pruned_contrack_pruned_*.pdb'));

% for ifg = 1:length(orFibersDir)
% 	fgPath{ifg} = fgRead(fullfile(orFibersDir(ifg).folder,orFibersDir(ifg).name));
% end

% % clip by eccentricity ROIs
% counter=1;
% for ifg = 1:length(fgPath)
% 	fg = fgPath{ifg};
%     hem = extractBetween(fg.name,'fg_OR_lgn_',sprintf('_%s',num2str(config.inflate_lgn)));

% 	for idg = 1:length(minDegree)
% 		v1 = bsc_loadAndParseROI([rois,sprintf('Ecc%sto%s_%s_%s.nii.gz',num2str(minDegree(idg)),num2str(maxDegree(idg)),hem{1},num2str(config.inflate_v1))]);
% 		[fgPathsCleaned{counter},~,keep,~] = dtiIntersectFibersWithRoi([],'and',[],v1,fg);

% 	    mtrExportFibers(fgPathsCleaned{counter},sprintf('%s/Ecc%sto%s_%s',orFibersDir(ifg).folder,num2str(minDegree(idg)),num2str(maxDegree(idg)),fg.name),[],[],[],3)
% 		counter=counter+1
% 	end
% end

% % need specific modification to how pdb fgs are loaded
% orFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','OR','Ecc*.pdb'));
% for ifg = 1:length(orFibersDir)
% 	fgPaths{ifg} = fgRead(fullfile(orFibersDir(ifg).folder,orFibersDir(ifg).name));
% end

% [mergedFG,classification] = bsc_mergeFGandClass([fgPaths]);

% for ifg = 1:length(fgPaths)
%     classification.names(ifg) = strcat(extractBefore(fgPaths{ifg}.name,'_lgn'),'_',extractBetween(fgPaths{ifg}.name,'fg_OR_','_20'));
% end

% mergedFG.name = 'optic_radiation';

% % find better way to index this
% mergedFG.params = {};
% mergedFG.params{1} = 'mrtrix_header';
% mergedFG.params{2}{1} = 'mrtrix tracks    ';
% mergedFG.params{2}{2} = 'mrtrix_version: 3.0_RC3';
% mergedFG.params{2}{3} = 'timestamp: 1573277529.4060957432';
% mergedFG.params{2}{4} = 'datatype: Float32LE';
% mergedFG.params{2}{5} = 'file: . 160';
% mergedFG.params{2}{6} = sprintf('count: %s',num2str(length(mergedFG.fibers)));
% mergedFG.params{2}{7} = sprintf('total_count: %s',num2str(length(mergedFG.fibers)));

% % save tck
% dtiExportFibersMrtrix_tracks(mergedFG,'track.tck');

% % clip hemispheres and CSF for OR
% for ifg = 1:length(classification.names)
% 	tractFG.name = classification.names{ifg};
% 	tractFG.colorRgb = mergedFG.colorRgb;
% 	display(sprintf('%s',tractFG.name))
% 	indexes = find(classification.index == ifg);
% 	tractFG.fibers = mergedFG.fibers(indexes);
% 	if strcmp(extractBefore(tractFG.name,'_'),'left')
% 	    [keep] = dtiIntersectFibersWithRoi_bl([],'not',config.minDistanceClean,Not.left,tractFG);
% 	else
% 	    [keep] = dtiIntersectFibersWithRoi_bl([],'not',config.minDistanceClean,Not.right,tractFG);
% 	end

% 	% set indices of streamlines that intersect the not ROI to 0 as if they
% 	% have never been classified
% 	classification.index(indexes(~keep)) = 0;
% end
