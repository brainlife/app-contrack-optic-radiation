#!/bin/bash
module load matlab/2017a

mkdir compiled

cat > build.m <<END
addpath(genpath('./vistasoft'))
addpath(genpath('/N/u/brlife/git/jsonlab'))
addpath(genpath('/N/u/brlife/git/encode'))
addpath(genpath('/N/u/brlife/git/spm'))
addpath(genpath('/N/u/brlife/git/wma_tools'))
mcc -m -R -nodisplay -d compiled opticRadiationContrack
exit
END
matlab -nodisplay -nosplash -r build
