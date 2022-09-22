

function staircaseStruct = MakeStaircaseStructure(upDownList,maxLevels,nTrials,initialLevels)

%nLevels             = 17;
%initialLevels         = [14 14];
%upDownList          = [1 2; 1 3]; % up/down staircases


nStairs             = size(upDownList,1);
nTrialsPerStair     = ceil(nTrials/nStairs);
nTrials             = nTrialsPerStair.*nStairs;

randTrials          = reshape(randperm(nTrials),[nStairs nTrialsPerStair]);
whichStairInd       = [];
for i=1:nStairs
    whichStairInd(randTrials(i,:)) = i;
end

staircaseStruct.upDownList      = upDownList;
staircaseStruct.maxLevels       = maxLevels;
staircaseStruct.nextStairLevel  = initialLevels;
staircaseStruct.stairCounter    = zeros(size(upDownList));
staircaseStruct.nStairs         = 1;
staircaseStruct.whichStairInd   = whichStairInd;

staircaseStruct.GetNextLevel    = @(s,trialNum)(s.nextStairLevel(s.whichStairInd(trialNum)));
