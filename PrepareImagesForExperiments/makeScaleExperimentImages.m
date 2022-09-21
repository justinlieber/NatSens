


%% Make rescaled images

writePath   = '~/GitHub/data/NatSens/RescaledImages/';

texFamList          = [18 30 60 99 336];
genPixSizeList      = 448; % 5.6 degrees @ 142 cm viewing distnace
targetContrastList  = 0.2;
apertureSizeList    = 320; % 4 degrees @ 142 cm viewing distance
zoomList            = 2.^[-3:0.5:2];

stimParamStruct = MakeStimulusParametersStruct(readPath,writePath,texFamList,genPixSizeList,targetContrastList,apertureSizeList,zoomList,[],[]);
stimParamStruct.nSeeds          = 15; 
stimParamStruct.filenameFunc        = @(propStruct,genPixSizeList,thisZoom,filterName)(...
    sprintf('TexFam(%i)-GenPixSize(%i)-ZoomFactor(%0.2f)-FiltType(%s)-Seed(%i)-Coh(%0.1f).png', ...
                    propStruct.TexFam,genPixSizeList,thisZoom,filterName,propStruct.Seed,propStruct.Coh));

CreateFilterApertureImages(stimParamStruct);


%% Make low-pass images

writePath   = '~/GitHub/data/NatSens/LowPassImages/';

texFamList          = [18 30 60 99 336];
genPixSizeList      = 448; % 5.6 degrees @ 142 cm viewing distnace
targetContrastList  = 0.2;
apertureSizeList    = 320;
zoomList            = 1;
filterEdgeList      = 4.*(2.^[-1:0.5:6]); % cycles/image
filterEdgeWidth     = 0.25;

stimParamStruct = MakeStimulusParametersStruct(readPath,writePath,texFamList,genPixSizeList,targetContrastList,apertureSizeList,zoomList,[],[]);
stimParamStruct.nSeeds          = 15; 
stimParamStruct.filenameFunc        = @(propStruct,genPixSizeList,thisZoom,filterName)(...
    sprintf('TexFam(%i)-GenPixSize(%i)-ZoomFactor(%0.2f)-FiltType(%s)-FiltEdge(%0.2f)-Seed(%i)-Coh(%0.1f).png', ...
                    propStruct.TexFam,genPixSizeList,thisZoom,filterName,propStruct.filterEdge,propStruct.Seed,propStruct.Coh));

% Make lowpass filter bank
nyqFreq             = apertureSizeList/2;
lpFilterBanks       = MakeLowHighFilterBank(genPixSizeList, filterEdgeList,filterEdgeWidth,nyqFreq);

filtFamInd = 2; % 2 = low pass index
stimParamStruct.filterName          = 'LowPass';
stimParamStruct.filterBanks         = lpFilterBanks(filtFamInd);
stimParamStruct.filterEdge          = filterEdgeList;

CreateFilterApertureImages(stimParamStruct);


%% Make rescaled low-pass images


writePath   = '~/GitHub/data/NatSens/RescaledLowPassImages/';

texFamList          = [18 30 60 99 336];
genPixSizeList      = 448; % 5.6 degrees @ 142 cm viewing distnace
targetContrastList  = 0.2;
apertureSizeList    = 320;
zoomList            = 2.^[-3:0.5:2];
filterEdgeList      = 2.^4.5; % cycles/image
filterEdgeWidth     = 0.25;

stimParamStruct = MakeStimulusParametersStruct(readPath,writePath,texFamList,genPixSizeList,targetContrastList,apertureSizeList,zoomList,[],[]);
stimParamStruct.nSeeds          = 15; 
stimParamStruct.filenameFunc        = @(propStruct,genPixSizeList,thisZoom,filterName)(...
    sprintf('TexFam(%i)-GenPixSize(%i)-ZoomFactor(%0.2f)-FiltType(%s)-FiltEdge(%0.2f)-Seed(%i)-Coh(%0.1f).png', ...
                    propStruct.TexFam,genPixSizeList,thisZoom,filterName,propStruct.filterEdge,propStruct.Seed,propStruct.Coh));

% Make lowpass filter bank
nyqFreq             = apertureSizeList/2;
lpFilterBanks       = MakeLowHighFilterBank(genPixSizeList, filterEdgeList,filterEdgeWidth,nyqFreq);

filtFamInd = 2; % 2 = low pass index
stimParamStruct.filterName          = 'LowPass';
stimParamStruct.filterBanks         = lpFilterBanks(filtFamInd);
stimParamStruct.filterEdge          = filterEdgeList;

CreateFilterApertureImages(stimParamStruct);

