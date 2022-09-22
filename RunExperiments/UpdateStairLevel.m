

function staircaseStruct = UpdateStairLevel(staircaseStruct,lastTrialNum,response)

stairInd = staircaseStruct.whichStairInd(lastTrialNum);
staircaseStruct.stairCounter(stairInd,response+1) = staircaseStruct.stairCounter(stairInd,response+1)+1;

if staircaseStruct.stairCounter(stairInd,response+1)>=staircaseStruct.upDownList(stairInd,response+1)
    newStairLevel   = staircaseStruct.nextStairLevel(stairInd) + (0.5-response)*2; % +/-1
    newStairLevel   = min(staircaseStruct.maxLevels,max(1,newStairLevel)); % keep bounded
    
    staircaseStruct.nextStairLevel(stairInd) = newStairLevel;
    staircaseStruct.stairCounter(stairInd,:) = 0; % reset staircase
end

