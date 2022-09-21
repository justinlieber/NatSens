function stimParamStruct = MakeStimulusParametersStruct(readPath,writePath,texFamList,genPixSizeList,imageContrastList,apertureSizeList,zoomList,filterCenterList,filterWidthList)

stimParamStruct                     = [];
stimParamStruct.readPath            = readPath;
stimParamStruct.writePath           = writePath;
stimParamStruct.texFamList          = texFamList;
stimParamStruct.genPixSizeList      = genPixSizeList;
stimParamStruct.imageContrastList   = imageContrastList;
stimParamStruct.apertureSizeList    = apertureSizeList;
stimParamStruct.zoomList            = zoomList;
stimParamStruct.filterCenterList    = filterCenterList;
stimParamStruct.filterWidthList     = filterWidthList;

if ~isempty(filterCenterList)
    stimParamStruct.filenameFunc        = @(propStruct,thisContrast,apertureTargetSize,thisZoom,filterCenter,filterWidth)(...
        sprintf('TexFam%i-DegSize%0.1f-Contrast%0.2f-ZoomFactor%0.2f-FiltCenter%0.1f-FiltWidth%0.1f-Seed%i-Coh%0.1f.png', ...
                        propStruct.TexFam,apertureTargetSize,thisContrast*100,thisZoom,filterCenter,filterWidth,propStruct.Seed,propStruct.Coh));
else
    stimParamStruct.filenameFunc        = @(propStruct,thisContrast,apertureTargetSize,thisZoom,filterCenter,filterWidth)(...
        sprintf('TexFam%i-DegSize%0.1f-Contrast%0.2f-ZoomFactor%0.2f-Seed%i-Coh%0.1f.png', ...
                        propStruct.TexFam,apertureTargetSize,thisContrast*100,thisZoom,propStruct.Seed,propStruct.Coh));
end