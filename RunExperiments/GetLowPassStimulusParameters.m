function [lowPassImGroup] = GetLowPassStimulusParameters(texFam, lpEdgeList, imagePath)

if ~exist('imagePath')
    imagePath = '/v/analysis/justin/images/NatSens/RescaledImages/';
end


genPixSize      = 320;
STD_IMG_DIST    = 1.42;
STD_PIX_PER_DEG = 80;
imContrast      = 0.2*100;
imageZoomFactor = 1; 
filterType      = 'LowPass';

degSize         = genPixSize/STD_PIX_PER_DEG;

nFilters        = length(lpEdgeList);

lowPassImGroup = cell(nFilters,1);



for filtInd = 1:nFilters

    filtEdge = lpEdgeList(filtInd);    
    fileSearchName = sprintf('TexFam(%i)-GenPixSize(%i)-ZoomFactor(%0.2f)-FiltType(%s)-FiltEdge(%0.2f)-Seed(*)-Coh(*).png', ...
        texFam,genPixSize,imageZoomFactor,filterType,filtEdge);

    [filenames, cohList, seedList] = GetFilenameMatrix(imagePath, fileSearchName);

    lowPassImGroup{filtInd}.filenames      = filenames;
    lowPassImGroup{filtInd}.cohList        = cohList;
    lowPassImGroup{filtInd}.seedList       = seedList;
    lowPassImGroup{filtInd}.texFam         = texFam;
    lowPassImGroup{filtInd}.filterType     = filterType;
    lowPassImGroup{filtInd}.filterEdge     = filtEdge;
    lowPassImGroup{filtInd}.viewDist       = STD_IMG_DIST;
    lowPassImGroup{filtInd}.imageZoomFactor    = imageZoomFactor;
    lowPassImGroup{filtInd}.eyeZoomFactor      = imageZoomFactor;
    lowPassImGroup{filtInd}.imageDegSize   = degSize;
    lowPassImGroup{filtInd}.eyeDegSize     = degSize;
    lowPassImGroup{filtInd}.contrast       = imContrast;
    lowPassImGroup{filtInd}.filePath       = imagePath;
    lowPassImGroup{filtInd}.writeStimParam = sprintf('TexFam%i-%s-FilterEdge%0.1f', texFam,filterType,filtEdge);
end
