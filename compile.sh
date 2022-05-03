#!/bin/bash
module load matlab/2017a

log=compiled/commit_ids.txt
true > $log
echo "/N/u/brlife/git/vistasoft" >> $log
(cd /N/u/brlife/git/vistasoft && git log -1) >> $log
echo "/N/u/brlife/git/jsonlab" >> $log
(cd /N/u/brlife/git/jsonlab && git log -1) >> $log
echo "/N/u/brlife/git/wma_tools" >> $log
(cd /N/u/brlife/git/wma_tools && git log -1) >> $log
echo "/N/u/brlife/git/afq" >> $log
(cd /N/u/brlife/git/afq && git log -1) >> $log

cat > build.m <<END
addpath(genpath('/N/u/brlife/git/vistasoft'))
addpath(genpath('/N/u/brlife/git/jsonlab'))
addpath(genpath('/N/soft/mason/SPM/spm8'))
addpath(genpath('/N/u/brlife/git/wma_tools'))
addpath(genpath('/N/u/brlife/git/afq'))
mcc -m -R -nodisplay -d compiled opticRadiationContrack 
exit
END
matlab -nodisplay -nosplash -r build

