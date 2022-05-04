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
    addpath(genpath('/N/u/brlife/git/afq'))

    %for old VM
    addpath(genpath('/usr/local/vistasoft'))
    addpath(genpath('/usr/local/encode'))
    addpath(genpath('/usr/local/jsonlab'))
    addpath(genpath('/usr/local/spm'))
    addpath(genpath('/usr/local/wma_tools'))
    addpath(genpath('/usr/local/afq'))
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
for h = 1:length(hemi)
    ctrParams.roi1{h} = sprintf('lgn_%s_%s',hemi{h},num2str(config.inflate_lgn));
    ctrParams.roi2{h} = sprintf('v1_%s_%s',hemi{h},num2str(config.inflate_v1));
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
[classification,mergedFG] = cleanFibers(topDir,config.contrackThreshold,config,MinDegree,MaxDegree);

exit;
end