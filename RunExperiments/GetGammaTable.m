
function gammaTable = GetGammaTable(delta)

if ~exist('delta')
    delta = 1;
    delta = 0.93; 
end

% 14-9-2021 - Justin & Gerick
% we manually tweaked delta to eliminate a luminance artifact present in a 
%   grating with a 5 pixel period. This seems to have resolved the issue.

gammaTable.EXP_R    = 1/(2.6064*delta); 
gammaTable.EXP_G    = 1/(2.7582*delta);
gammaTable.EXP_B    = 1/(2.6663*delta);
%gammaTable.EXP_R    = 1/1; 
%gammaTable.EXP_G    = 1/1;
%gammaTable.EXP_B    = 1/1;
gammaTable.redInd   = (0:1/255:1).^gammaTable.EXP_R;
gammaTable.greenInd = (0:1/255:1).^gammaTable.EXP_G;
gammaTable.blueInd  = (0:1/255:1).^gammaTable.EXP_B;


% measurements as of 2016-09-20
% gammaTable.EXP_R    = 1/2.3307; 
% gammaTable.EXP_G    = 1/2.3724;
% gammaTable.EXP_B    = 1/2.3787;
