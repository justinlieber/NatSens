

function currentViewDist = CheckUpdateViewDistance(targetViewDist, currentViewDist)

while targetViewDist ~= currentViewDist
    warning('Current view distance is %0.2f\n', currentViewDist);    
    warning('Set view distance to %0.2f\n', targetViewDist);
    beep();
    
    dialogMsg = sprintf('Set view distance to %0.2f. What is new view distance?',targetViewDist);
    currentViewDist = inputdlg(dialogMsg);
    currentViewDist = str2num(currentViewDist{1});
end
