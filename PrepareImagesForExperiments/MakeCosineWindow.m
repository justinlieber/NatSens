
function [maskWeight, maskInd] = MakeCosineWindow(nImagePix, pixWindowWidth, pixEdgeWidth)

rCosFunc = @(x,x0,width)(stepFunc(x-x0-width/2) + sin( -pi/4-(pi/2)*(x-x0)/width).^2.*(1-stepFunc(x-x0-width/2)).*(stepFunc(x-x0+width/2)));

if ~exist('pixWindowWidth')
    pixWindowWidth = nImagePix*(1/2);
end

if ~exist('pixEdgeWidth')
    pixEdgeWidth = nImagePix*(1/16);
end

edgeVal         = (nImagePix-1)/2;
edgeVec         = linspace(-edgeVal,edgeVal,nImagePix);
[gridX, gridY]  = meshgrid(edgeVec,edgeVec);

gridR           = sqrt(gridX.^2+gridY.^2);

maskWeight      = 1-rCosFunc(gridR,pixWindowWidth/2,pixEdgeWidth);

maskWeight(maskWeight < .01)    = 0;
maskInd                         = maskWeight > 0;
