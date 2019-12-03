function [] = opticRadiationContrack()

if ~isdeployed
    disp('loading path')

    %for IU HPC
    addpath(genpath('/N/u/brlife/git/encode'))
    addpath(genpath('/N/u/brlife/git/vistasoft'))
    addpath(genpath('/N/u/brlife/git/jsonlab'))
    addpath(genpath('/N/u/brlife/git/spm'))
    addpath(genpath('/N/u/brlife/git/wma_tools'))

    %for old VM
    addpath(genpath('/usr/local/vistasoft'))
    addpath(genpath('/usr/local/encode'))
    addpath(genpath('/usr/local/jsonlab'))
    addpath(genpath('/usr/local/spm'))
    addpath(genpath('/usr/local/wma_tools'))
end

% load my own config.json
config = loadjson('config.json');
seedroi = config.seed_roi;

if seedroi == '008109'
	hemi = 'left';
else
	hemi = 'right';
end

topDir = pwd;
baseDir = fullfile(pwd,'tmpSubj');


%% generate .mat rois
generateMatRois(config,seedroi);

%% generate batch parameters
% params
ctrParams.projectName = 'OR';
ctrParams.logName = 'opticRadiation';
ctrParams.baseDir = baseDir;
ctrParams.dtDir = 'dti';
ctrParams.roiDir = 'ROIs';

% pick up subjects
ctrParams.subs = {'dtiinit'};

% set rois and parameters
ctrParams.roi1 = {sprintf('lgn_%s',hemi)};
ctrParams.roi2 = {sprintf('v1_%s',hemi)};
ctrParams.nSamples = config.count;
ctrParams.maxNodes = config.maxnodes;
ctrParams.minNodes = config.minnodes; % defalt: 10
ctrParams.stepSize = config.stepsize; % default: 1
ctrParams.scrDir = fullfile(pwd,'bin');
mkdir(ctrParams.scrDir);
ctrParams.logDir = fullfile(pwd,'logs');
mkdir(ctrParams.logDir);
ctrParams.pddpdfFlag = 0;
ctrParams.wmFlag = 0;
ctrParams.roi1SeedFlag = 'true';
ctrParams.roi2SeedFlag = 'true';
ctrParams.multiThread = 0;
ctrParams.executeSh = 0;

%% Generate OR usinig Sherbondy's contrack
% make contrack scripts
[cmd, ~] = ctrInitBatchTrack(ctrParams);

% fix script for missing path to contrack c code
scriptPath = dir(fullfile(topDir,'/tmpSubj/dtiinit/dti/fibers/conTrack/OR/*.sh'));
contrackPath = [sprintf('%s/contrack_gen.glxa64',topDir) ' '];
fid = fopen(fullfile(scriptPath.folder,scriptPath.name));
text = textscan(fid,'%s','delimiter','\n');
text{1}{2} = strcat(extractBefore(text{1}{2},' -i'),contrackPath,' -i',extractAfter(text{1}{2},' -i'));
fclose(fid);
fid = fopen(fullfile(scriptPath.folder,scriptPath.name),'w');
fprintf(fid,'%s\n',text{:}{:});
fclose(fid);

%% run scripts
system(cmd);

cd(topDir);
%% clip fibers and create classification structure
orFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','OR','*.pdb'));

fgPath = {fullfile(orFibersDir(1).folder,orFibersDir(1).name)};

% need specific modification to how pdb fgs are loaded
[mergedFG,whole_classification] = bsc_mergeFGandClass_pdb(fgPath);

whole_classification.names = {sprintf('%s-optic-radiation',hemi)};

mergedFG.name = sprintf('%s_optic_radiation',hemi);
% find better way to index this
% fake mrtrix header
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

% make whole OR fg_classified for cleaning
whole_fg_classified = bsc_makeFGsFromClassification_v4(whole_classification,mergedFG);
[clean_classification] = cleanFibers(whole_classification,mergedFG,hemi);

%% Eccentricity classification
[fg_classified,classification] = eccentricityClassification(config,whole_fg_classified,mergedFG,clean_classification,hemi);

%% Save output
save('output.mat','classification','fg_classified','-v7.3');

%% create tracts for json structures for visualization
tracts = fg2Array(fg_classified);

mkdir('tracts');

% Make colors for the tracts
%cm = parula(length(tracts));
cm = distinguishable_colors(length(tracts));
for it = 1:length(tracts)
   tract.name   = strrep(tracts{it}.name, '_', ' ');
   all_tracts(it).name = strrep(tracts{it}.name, '_', ' ');
   all_tracts(it).color = cm(it,:);
   tract.color  = cm(it,:);

   %tract.coords = tracts(it).fibers;
   %pick randomly up to 1000 fibers (pick all if there are less than 1000)
   fiber_count = min(1000, numel(tracts{it}.fibers));
   tract.coords = tracts{it}.fibers(randperm(fiber_count));

   savejson('', tract, fullfile('tracts',sprintf('%i.json',it)));
   all_tracts(it).filename = sprintf('%i.json',it);
   clear tract
end

% Save json outputs
savejson('', all_tracts, fullfile('tracts/tracts.json'));

% Create and write output_fibercounts.txt file
for i = 1 : length(fg_classified)
    name = fg_classified{i}.name;
    num_fibers = length(fg_classified{i}.fibers);

    fibercounts(i) = num_fibers;
    tract_info{i,1} = name;
    tract_info{i,2} = num_fibers;
end

T = cell2table(tract_info);
T.Properties.VariableNames = {'Tracts', 'FiberCount'};

writetable(T, 'output_fibercounts.txt');

exit;
end

