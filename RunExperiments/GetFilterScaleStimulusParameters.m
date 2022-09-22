function sizeImGroup = GetFilterScaleStimulusParameters(texFam, imageZoomList,viewDistList, lpFilterEdge, imagePath)

if ~exist('imagePath')
    imagePath = '/v/analysis/justin/images/NatSens/RescaledLowPassImages/';
end

genPixSize      = 320;
imContrast      = 0.2*100;
STD_IMG_DIST    = 1.42;
STD_PIX_PER_DEG = 80;

filtType        = 'LowPass';

distZoomRatio   = STD_IMG_DIST./viewDistList;
targetZoomList  = imageZoomList.*distZoomRatio;

nSize = length(imageZoomList);

sizeImGroup = cell(nSize,1);

for sizeInd = 1:nSize

    fileSearchName = sprintf('TexFam(%i)-GenPixSize(%i)-ZoomFactor(%0.2f)-FiltType(%s)-FiltEdge(%0.2f)-Seed(*)-Coh(*).png', ...
        texFam,genPixSize,imageZoomList(sizeInd),filtType,lpFilterEdge);

    [filenames, cohList, seedList] = GetFilenameMatrix(imagePath, fileSearchName);

    pixPerDeg   = STD_PIX_PER_DEG./(distZoomRatio(sizeInd));
    degSize     = (genPixSize/pixPerDeg).*imageZoomList(sizeInd);
    
    sizeImGroup{sizeInd}.filenames     = filenames;
    sizeImGroup{sizeInd}.cohList       = cohList;
    sizeImGroup{sizeInd}.seedList      = seedList;
    sizeImGroup{sizeInd}.texFam        = texFam;
    sizeImGroup{sizeInd}.viewDist      = viewDistList(sizeInd);
    sizeImGroup{sizeInd}.imageZoomFactor    = imageZoomList(sizeInd);
    sizeImGroup{sizeInd}.eyeZoomFactor      = targetZoomList(sizeInd);
    sizeImGroup{sizeInd}.imageDegSize  = degSize;
    sizeImGroup{sizeInd}.eyeDegSize    = degSize.*targetZoomList(sizeInd);
    sizeImGroup{sizeInd}.imContrast    = imContrast;
    sizeImGroup{sizeInd}.filtType      = filtType;
    sizeImGroup{sizeInd}.filtEdge      = lpFilterEdge;
    sizeImGroup{sizeInd}.filePath      = imagePath;
    sizeImGroup{sizeInd}.writeStimParam    = sprintf('TexFam%i-EyeDeg%0.2f-FiltEdge%0.1f', texFam,sizeImGroup{sizeInd}.eyeDegSize,lpFilterEdge);
end