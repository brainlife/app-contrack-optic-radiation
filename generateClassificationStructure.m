function [] = generateClassificationStructure()

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

%% grab Eccentricity bundles
orFibersDir = dir(fullfile(pwd,'tmpSubj','dtiinit','dti','fibers','conTrack','OR','Ecc*.tck'));

for ifg = 1:length(orFibersDir)
	fgPath{ifg} = fgRead(fullfile(orFibersDir(ifg).folder,orFibersDir(ifg).name));
end

% merge together into classification and fg structure
[mergedFG,classification] = bsc_mergeFGandClass([fgPath]);

% update classification names
for ifg = 1:length(fgPath)
    classification.names(ifg) = strcat(extractBefore(fgPath{ifg}.name,'_lgn'),'_',extractBetween(fgPath{ifg}.name,'fg_OR_','_20'));
end

% generate tck header for outputting track
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
