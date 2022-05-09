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
    %Not.(hemi{hh}) = bsc_mergeROIs(Not.(hemi{hh}),hemisphereROI.(hemi{hh}));
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
%     [~,~] = dtiRoiNiftiFromMat(thalMedPostSub.(hemi{hh}),referenceNifti.(hemi{hh}),sprintf('thalMedPostSub_lgn_%s.nii.gz',hemi{hh}),true);
end

%% Score fibers to get best streamlines possible. THIS DOESNT SEEM TO DO WELL IN OR TRACKING. skipping
%textPaths = dir(fullfile(topDir,'/tmpSubj/dtiinit/dti/fibers/conTrack/OR/ctrSampler_OR*.txt'));
%for i = 1:length(textPaths)
%    % set up names and variables for score
%    textPath = fullfile(sprintf('%s/%s',textPaths(i).folder,textPaths(i).name));
%    track_pdb_name = extractBetween(textPaths(i).name,'OR_','.txt');
%    pdbPath = fullfile(sprintf('%s/fg_OR_%s.pdb',textPaths(i).folder,track_pdb_name{1}));
%    pdbOutPath = fullfile(sprintf('%s/contrack_pruned_fg_OR_%s.pdb',textPaths(i).folder,track_pdb_name{1}));
%
%    % write command
%    scoreCmd = sprintf('%s/contrack_score.glxa64 -i %s -p %s --thresh %s --sort %s',topDir,textPath,pdbOutPath,num2str(threshold),pdbPath)
%    
%    % run command
%    system(scoreCmd)
%end

%% flip, add 180, and identify tracts
%orFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','OR','contrack_pruned_*.pdb'));

orFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','OR','fg_OR_lgn_*.pdb'));

for ifg = 1:length(orFibersDir)
    fg = fgRead(sprintf('%s/%s',orFibersDir(ifg).folder,orFibersDir(ifg).name));
    hem = extractBetween(fg.name,'fg_OR_lgn_',sprintf('_%s',num2str(config.inflate_lgn)));
    
    % no idea as to why need to do this, or why 180, or why it works, but it seems to work so idk. figure out later
    for dfg = 1:length(fg.fibers)
        fg.fibers{dfg}(1,:) = -(fg.fibers{dfg}(1,:)) + 180;
    end
    hem = extractBetween(orFibersDir(ifg).name,'lgn_',sprintf('_%s',num2str(config.inflate_lgn)));
    
    for idg = 1:length(minDegree)
        outname = sprintf('%s/Ecc%sto%s_lgn_%s_%s_v1_%s_%s.pdb',orFibersDir(ifg).folder,num2str(minDegree(idg)),num2str(maxDegree(idg)),hem{1},num2str(config.inflate_lgn),hem{1},num2str(config.inflate_v1))
        v1 = bsc_loadAndParseROI([rois,sprintf('Ecc%sto%s_%s_%s.mat',num2str(minDegree(idg)),num2str(maxDegree(idg)),hem{1},num2str(config.inflate_v1))]);
        [fgOut,keepFG] = wma_SegmentFascicleFromConnectome_Bl(fg,referenceNifti.(hemi{hh}).pixdim(1),{thalLatPost.(hem{1}),v1},{'and','endpoints'},outname);
        [fgOut,keepFG] = wma_SegmentFascicleFromConnectome_Bl(fgOut,0.5,{exclusionROI.(hem{1})},{'not'},outname);
        mtrExportFibers(fgOut,outname,[],[],[],3)
    end
end

% %% Load Optic radiations and clip for cleaning
orFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','OR','Ecc*.pdb'));
counter=1;
for ifg = 1:length(orFibersDir)
	tmp = fgRead(fullfile(orFibersDir(ifg).folder,orFibersDir(ifg).name));
    if length(tmp.fibers) > 0
        fgPaths{counter} = tmp;
        counter=counter+1;
    end
end

[mergedFG,classification] = bsc_mergeFGandClass([fgPaths]);

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
