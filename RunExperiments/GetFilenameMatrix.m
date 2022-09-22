

function [filenameMatrix, levelList, seedList]  = GetFilenameMatrix(filePath, fileSearchName,levelStructName)

if ~exist('levelStructName') || isempty(levelStructName)
    levelStructName = 'Coh';
end

fullSearchPath = [filePath fileSearchName];
files = dir(fullSearchPath);

if isempty(files)
    warning('warning, no files found: %s\n',fullSearchPath);
end

fullSeedList    = [];
fullLevelList     = [];

for fileInd = 1:length(files)
    imParam = ParseImageFilename( files(fileInd).name, '.png' );

    fullSeedList(fileInd)   =  imParam.Seed;
    fullLevelList(fileInd)    =  getfield(imParam,levelStructName);
end

seedList    = unique(fullSeedList);
levelList     = unique(fullLevelList);

nLevel = length(levelList);
nSeeds = length(seedList);
filenameMatrix = cell(nLevel,nSeeds);
for levelInd = 1:nLevel
    for seedInd = 1:nSeeds
        fileInd = find(fullLevelList==levelList(levelInd) & fullSeedList == seedList(seedInd));
        filenameMatrix{levelInd,seedInd} = [filePath files(fileInd).name];
    end
end

