function [] = opticRadiationContrack()

%% load packages
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
    addpath(genpath('/usr/local/AFQ'))
end

%% config and top variables
% load config.json
config = loadjson('config.json');

hemi = {'left','right'};

topDir = pwd;
baseDir = fullfile(pwd,'tmpSubj');
% tractNames = split(config.track_names);
MinDegree = str2num(config.minDegree);
MaxDegree = str2num(config.maxDegree);

%% generate .mat rois
generateMatRois(config,MinDegree,MaxDegree);

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
j=1;
for h = 1:length(hemi)
    for i = 1:length(MinDegree)
        ctrParams.roi1{j} = sprintf('lgn_%s',hemi{h});
        ctrParams.roi2{j} = sprintf('Ecc%sto%s_%s',num2str(MinDegree(i)),num2str(MaxDegree(i)),hemi{h});
        j=j+1;
    end
end

ctrParams.nSamples = config.nSamples;
ctrParams.maxNodes = config.maxNodes;
ctrParams.minNodes = config.minNodes; % defalt: 10
ctrParams.stepSize = config.stepSize; % default: 1
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

% fix script for missing path to contrack c code: NEED TO POTENTIALLY DEBUG
scriptPath = dir(fullfile(topDir,'/tmpSubj/dtiinit/dti/fibers/conTrack/OR/*.sh'));
contrackPath = [sprintf('%s/contrack_gen.glxa64',topDir) ' '];
for ifg = 1:length(scriptPath)
	fid = fopen(fullfile(scriptPath(ifg).folder,scriptPath(ifg).name));
	text = textscan(fid,'%s','delimiter','\n');
	text{1}{2} = strcat(extractBefore(text{1}{2},' -i'),contrackPath,' -i',extractAfter(text{1}{2},' -i'));
	fclose(fid);
	fid = fopen(fullfile(scriptPath(ifg).folder,scriptPath(ifg).name),'w');
	fprintf(fid,'%s\n',text{:}{:});
	fclose(fid);
	clear text;
end

%% run scripts
system(cmd);

cd(topDir);
%% clip fibers and create classification structure
[classification,mergedFG] = cleanFibers(topDir,config.contrackThreshold);

%% make fg classified structure for eccentricity classification
fg_classified = bsc_makeFGsFromClassification_v4(classification,mergedFG);

%% Save output
save('output.mat','classification');

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
