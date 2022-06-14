function [] = visualWhiteMatterContrackPrep()

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
ctrParams.projectName = 'visual-white-matter';
ctrParams.logName = 'visual-white-matter';
ctrParams.baseDir = baseDir;
ctrParams.dtDir = 'dti';
ctrParams.roiDir = 'ROIs';

% pick up subjects
ctrParams.subs = {'dtiinit'};

% set rois and parameters
j=1;
for h = 1:length(hemi)
    for i = 1:length(MinDegree)
        ctrParams.roi1{j} = sprintf('%s_%s_%s',,config.start_roi,hemi{h},num2str(config.inflate_start_roi));
        ctrParams.roi2{j} = sprintf('Ecc%sto%s_%s_%s',num2str(MinDegree(i)),num2str(MaxDegree(i)),hemi{h},num2str(config.inflate_term_roi));
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
% make contrack scripts. run this first to generate the pdf file. then need to reslice to anat, then rerun
[cmd, ~] = ctrInitBatchTrack(ctrParams);

exit;
end
