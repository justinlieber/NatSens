


function CreateFilterApertureImages(stimParamStruct)


readPath            = stimParamStruct.readPath;
writePath           = stimParamStruct.writePath;
texFamList          = stimParamStruct.texFamList;
genPixSizeList      = stimParamStruct.genPixSizeList;
imageContrastList   = stimParamStruct.imageContrastList;
apertureSizeList    = stimParamStruct.apertureSizeList;
zoomList            = stimParamStruct.zoomList;

nSeeds              = stimParamStruct.nSeeds; 

% Make filter bank
if ~isfield(stimParamStruct, 'filterBanks') || isempty(stimParamStruct.filterBanks)
    filterName = 'None';
    filterBanks = cell(size(genPixSizeList));
    for fInd =1:length(filterBanks)
        filterBanks{fInd} = ones(genPixSizeList(fInd));
    end
    nFilt = 1;
elseif isfield(stimParamStruct,'filterBanks')
    filterName          = stimParamStruct.filterName;
    filterBanks         = stimParamStruct.filterBanks;
    nFilt               = size(filterBanks{1},3); 
else
    filterBanks         = cell(size(genPixSizeList));
    nFilt               = 1;
end

if isfield(stimParamStruct, 'normalizeBand')
    normalizeBand = stimParamStruct.normalizeBand;
else
    normalizeBand = false;
end

if ~isfolder(writePath)
    mkdir(writePath);
end

% Make aperture bank
apBank          = {1,length(zoomList),1};
cutIndList      = {1,length(zoomList),1};
for zInd = 1:length(zoomList)
    zoomImageSize                   = ceil(genPixSizeList.*zoomList(zInd));
    [thisApBank, thisCutIndList]    = MakeApertureBank(zoomImageSize, apertureSizeList.*zoomList(zInd));
    apBank(:,zInd,:)                = thisApBank;
    cutIndList(:,zInd,:)            = thisCutIndList;
end

for texInd = 1:length(texFamList)
for sizeInd = 1:length(genPixSizeList)
for seedInd = 1:nSeeds
    
    texFam      = texFamList(texInd);
    inputPixSize   = genPixSizeList(sizeInd);
    
    allCohSearchString      = sprintf('TexFam%i-SizePix%i-Seed%i-Coh*.png',texFam,inputPixSize, seedInd);
    
    findSignalFiles = dir([readPath allCohSearchString]);
    nFiles          = length(findSignalFiles);
    
    for fInd = 1:nFiles
        propStruct              = ParseImageFilename(findSignalFiles(fInd).name);
        
        cohVal = propStruct.Coh;
        
        [texFam inputPixSize seedInd cohVal]

        baseIm          = double(imread([findSignalFiles(fInd).folder '/' findSignalFiles(fInd).name]));
        normSignalIm    = (baseIm - nanmean(baseIm(:)))./nanstd(baseIm(:));
        
        

        for filtInd = 1:nFilt

            if isempty(filterBanks{sizeInd})
                error('need a filter');
            else
                signalFft       = fftshift(fft2(normSignalIm));
                filtIm          = real(ifft2(ifftshift(signalFft.*filterBanks{sizeInd}(:,:,filtInd))));
                
                if isfield(stimParamStruct,'filterEdge')
                    propStruct.filterEdge = stimParamStruct.filterEdge(filtInd);
                end
                if isfield(stimParamStruct,'filterCenter')
                    propStruct.filterCenter = stimParamStruct.filterCenter(filtInd);
                end
                if isfield(stimParamStruct,'filterWidth')
                    propStruct.filterWidth = stimParamStruct.filterWidth(filtInd);
                end
                
                if normalizeBand
                    filtIm = filtIm./nanstd(filtIm(:));
                end
            end   

            for apInd = 1:length(apertureSizeList)
                apertureSize = apertureSizeList(apInd);
                for zoomInd = 1:length(zoomList)   

                    thisZoom    = zoomList(zoomInd);

                    cutInd      = cutIndList{apInd,zoomInd,sizeInd};

                    nTargetPix  = size(apBank{apInd,zoomInd,sizeInd},1);
                    resizeIm    = imresize(filtIm, [1 1]*nTargetPix);
                    apIm        = resizeIm.*apBank{apInd,zoomInd,sizeInd};


                    for contrastInd = 1:length(imageContrastList)
                        thisContrast    = imageContrastList(contrastInd);

                        thisIm          = uint8(128+(thisContrast.*apIm).*256);

                        thisIm          = thisIm(cutInd,cutInd);

                        filename        = stimParamStruct.filenameFunc(propStruct,apertureSize,thisZoom,filterName);

                        imwrite(thisIm, [writePath filename]);
                    end
                end
            end
        end
    end
end
end
end

'done'