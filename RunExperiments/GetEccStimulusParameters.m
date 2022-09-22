function [eccImGroup]        = GetEccStimulusParameters(texFam, fixLocationList, stimLocationList, imageZoomList, viewDistList, imagePath)

if ~exist('imagePath')
    imagePath = '/v/analysis/justin/images/NatSens/RescaledImages/';
end

genPixSize      = 320;
imContrast      = 0.2*100;
STD_IMG_DIST    = 1.42;
STD_PIX_PER_DEG = 80;

nEcc                  = length(fixLocationList);

eccImGroup      = cell(nEcc,2);

for eccInd = 1:nEcc
    thisZoom        = imageZoomList(eccInd);
    thisDist        = viewDistList(eccInd);
    
    distZoomRatio   = STD_IMG_DIST./thisDist;
    pixPerDeg   = STD_PIX_PER_DEG./(distZoomRatio);
    degSize     = (genPixSize/pixPerDeg).*thisZoom;

    fileSearchName = sprintf('TexFam(%i)-GenPixSize(%i)-ZoomFactor(%0.2f)-FiltType(None)-Seed(*)-Coh(*).png', ...
        texFam,genPixSize,thisZoom);

    [filenames, cohList, seedList] = GetFilenameMatrix(imagePath, fileSearchName);

    eccImGroup{eccInd}.filenames      = filenames;
    eccImGroup{eccInd}.cohList        = cohList;
    eccImGroup{eccInd}.seedList       = seedList;
    eccImGroup{eccInd}.texFam         = texFam;
    eccImGroup{eccInd}.fixLocation    = fixLocationList(eccInd); % degrees, in X
    eccImGroup{eccInd}.stimLocation   = stimLocationList(eccInd); % degrees, in X
    eccImGroup{eccInd}.eccentricity   = abs(eccImGroup{eccInd}.fixLocation - eccImGroup{eccInd}.stimLocation);
    eccImGroup{eccInd}.xFieldString   = 'Eccentricity';

    eccImGroup{eccInd}.viewDist       = thisDist;
    eccImGroup{eccInd}.imageZoomFactor    = thisZoom;
    eccImGroup{eccInd}.eyeDegSize     = degSize;
    eccImGroup{eccInd}.contrast       = imContrast;
    eccImGroup{eccInd}.filePath       = imagePath;
    eccImGroup{eccInd}.writeStimParam = sprintf('TexFam%i-Eccentricity%0.1f', texFam,eccImGroup{eccInd}.eccentricity);
end