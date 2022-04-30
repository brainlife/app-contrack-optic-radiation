function [fg] = SO_AlignFiberDirection(fg,direction)
% We have to correct the direction of each fg.fiber in your facicle before
% caliculate diffusivities along the tract
% dtiCleanFiber, dtiClipFiberGroupToROIs is also useful. 
% But these two function don't remain pathwayinfo field and remove the fiber dosent
% touch both ROI. 
%
% Input
% fg = fgRead(fgfile)
% direction = 'LR','AP', or 'SI' 
%
% Example 
% fg = fgRead(fgfile)
% direction = 'LR'
% [fg] = SO_AlignFiberDirection(fg,direction)
%
% SO@Vista lab 2013


%% Align fiber direction
switch direction
    case 'AP'
        for jj = 1:length(fg.fibers)
            if fg.fibers{jj}(2,1) < fg.fibers{jj}(2,end);
                fg.fibers{jj}= fliplr(fg.fibers{jj});
            end
        end
    case 'PA'
        for jj = 1:length(fg.fibers)
            if fg.fibers{jj}(2,1) > fg.fibers{jj}(2,end);
                fg.fibers{jj}= fliplr(fg.fibers{jj});
            end
        end        
    case 'LR'
        for jj = 1:length(fg.fibers)
            if fg.fibers{jj}(1,1) > fg.fibers{jj}(1,end);
                fg.fibers{jj}= fliplr(fg.fibers{jj});
            end
        end
    case 'SI'
        for jj = 1:length(fg.fibers)
            if fg.fibers{jj}(3,1) > fg.fibers{jj}(1,end);
                fg.fibers{jj}= fliplr(fg.fibers{jj});
            end
        end
end;