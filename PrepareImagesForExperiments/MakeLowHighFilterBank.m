

function filterBanks = MakeLowHighFilterBank(genPixSizeList, filterEdgeList,filterEdgeWidth,nyqFreq)

if ~exist('filterEdgeWidth') || isempty(filterEdgeWidth) 
    filterEdgeWidth = 0.5; % smooth the filter edge over half an octave
end

if ~exist('nyqFreq')
    nyqFreq         = 320/2; % pix/image. = (80 pix/degree * 4 degree image)/2
end

rCosFunc = @(x,x0,width)(stepFunc(x-x0-width/2) + sin( -pi/4-(pi/2)*(x-x0)/width).^2.*(1-stepFunc(x-x0-width/2)).*(stepFunc(x-x0+width/2)));




filterBanks = cell(1);
for sizeInd = 1:length(genPixSizeList)
    inputImPixSize        = genPixSizeList(sizeInd);
    
    fftList         = linspace(-nyqFreq,nyqFreq,inputImPixSize+1);
    if mod(inputImPixSize,2)==0
        fftList = fftList(1:end-1);
    end
    [fX, fY]        = meshgrid(fftList,fftList);
    fLogR           = log2(eps+sqrt(fX.^2+fY.^2));

    for filterInd = 1:length(filterEdgeList)
        filterEdge = filterEdgeList(filterInd);
        if filterEdge > nyqFreq*5
            filterEdge = nyqFreq*5;
        end
        filterBanks{sizeInd,1}(:,:,filterInd) = rCosFunc(fLogR,log2(filterEdge),filterEdgeWidth);
        filterBanks{sizeInd,2}(:,:,filterInd) = 1-rCosFunc(fLogR,log2(filterEdge),filterEdgeWidth);
    end
    
end


