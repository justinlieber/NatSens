

function [apBank, cutIndList] = MakeApertureBank(genPixSizeList, aperturePixSizeList)

apBank      = cell(1);
cutIndList  = cell(1);
for inputSizeInd = 1:length(genPixSizeList)
    inputPix       = genPixSizeList(inputSizeInd);
    
    for apInd = 1:length(aperturePixSizeList)
        
        apertureEdgeSize    = 0.05*inputPix;
        apertureTargetSize  = aperturePixSizeList(apInd);
        
        apertureBaseWindow  = MakeCosineWindow(inputPix, apertureTargetSize, apertureEdgeSize);
        apBank{apInd,inputSizeInd}     = apertureBaseWindow;

        scalePixSize    = linspace(-inputPix/2,inputPix/2,inputPix);
        [X,Y]           = meshgrid(scalePixSize, scalePixSize);
        R               = sqrt(X.^2+Y.^2);
        maxRPos         = ceil(max(R(apertureBaseWindow~=0)));
        
        cutIndList{apInd,inputSizeInd} = find(abs(scalePixSize) < maxRPos);
    end
end