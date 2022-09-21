

%% Create the source images for the blur/scaling/eccentricity experiments

readPath    = '~/GitHub/NatSens/ImageSynthesis/TextureImages-20120323/';
writePath   = '~/GitHub/data/NatSens/BaseCoherenceSet/';

texList     = [18 30 60 336 459];
cohVals     = [0 2.^(linspace(log2(0.02), log2(1),17))];
nSeeds      = 15;
targetSizeList      = 320+64*2; % degrees
targetContrast      = 0.2; %RMS

GenerateNewTextureImages(readPath, writePath, texList, cohVals, nSeeds, targetSizeList, targetContrast);

%% Copy existing files over


inPath = '~/GitHub/data/SizeScaleTextures/BaseCoherenceSet/';
writePath   = '~/GitHub/data/NatSens/BaseCoherenceSet/';


inPath = '~/GitHub/data/SizeScaleTextures/DenseCoherenceSet/';
writePath   = '~/GitHub/data/NatSens/DenseCoherenceSet/';

fileList = dir([inPath 'TexFam*-Size5.60-Seed*-Coh*.png']);

for fInd = 1:length(fileList)
    
    thisName = fileList(fInd).name;
    sizeInd = strfind(thisName,'Size');
    dashInd = strfind(thisName,'-');
    
    newName = [thisName(1:sizeInd-1) sprintf('SizePix448') thisName(dashInd(2):end)];
    
    copyfile([fileList(fInd).folder '/' thisName],[writePath newName]);
end