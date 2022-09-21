

function GenerateNewTextureImages(readPath, writePath, texFamList, cohList, nSeeds, sizePixList, imageContrast)

% Parameters for texture analysis
nScales = 4;
nOri    = 4;
nA      = 7;
nIter   = 50; % this is a bit overkill, but that's OK


% We're generating the 0 coherence case, so make sure we write it
cohList = sort(cohList);
if ~any(ismember(cohList,0))
    cohList = [0 cohList];
end
nCoh = length(cohList);

for texListInd = 1:length(texFamList)
    
    texInd = texFamList(texListInd);
    
    % load images
    if ~isempty(strfind(readPath,'TextureImages'))
        readTexName     = sprintf('tex-%i/tex/*.mat', texInd);
        readNoiseName   = sprintf('tex-%i/noise/*.mat', texInd);

        texFiles        = dir([readPath readTexName]);
        noiseFiles      = dir([readPath readNoiseName]);

        nFiles = length(texFiles);

        % measure statistics
        saveVec = [];
        for fInd = 1:nFiles
            texMatFile = load([texFiles(fInd).folder '/' texFiles(fInd).name]);
            thisIm = double(texMatFile.res);
            saveVec(:,fInd,1) = GetVecFromParam(textureAnalysis(thisIm,nScales,nOri,nA));

            noiseMatFile = load([noiseFiles(fInd).folder '/' noiseFiles(fInd).name]);
            thisIm = double(noiseMatFile.res);
            saveVec(:,fInd,2) = GetVecFromParam(textureAnalysis(thisIm,nScales,nOri,nA));
        end
    else
        readTexName     = sprintf('tex-320x320-im%i-smp*.png', texInd);
        readNoiseName   = sprintf('noise-320x320-im%i-smp*.png', texInd);

        texFiles        = dir([readPath readTexName]);
        noiseFiles      = dir([readPath readNoiseName]);

        nFiles = length(texFiles);

        % measure statistics
        saveVec = [];
        for fInd = 1:nFiles
            thisIm = double(imread([readPath texFiles(fInd).name]));
            saveVec(:,fInd,1) = GetVecFromParam(textureAnalysis(thisIm,nScales,nOri,nA));

            thisIm = double(imread([readPath noiseFiles(fInd).name]));
            saveVec(:,fInd,2) = GetVecFromParam(textureAnalysis(thisIm,nScales,nOri,nA));
        end
    end    
    thisTextureVec      = nanmean(saveVec(:,:,1),2);
    thisNoiseVec        = nanmean(saveVec(:,:,2),2);
    
    startParams         = GetParamFromVec(thisTextureVec,nScales,nOri,nA);
            
    % synthesize a big boy
    for sizeInd = 1:length(sizePixList)
        attemptedSize   = sizePixList(sizeInd);
        nPix            = 64*ceil(attemptedSize/64);
        thisBaseIm  = textureSynthesis(startParams, [1 1]*nPix, nIter);

        for seedInd = 1:nSeeds

            [texInd seedInd -1]

            baseFilename = sprintf('TexFam%i-SizePix%i-Seed%i-Coh%0.2f.png', texInd,nPix,seedInd,0);
            baseFile = dir([writePath '/' baseFilename]);
            if ~isempty(baseFile)
                % if we broke off halfway through generation, find the last
                % version of 0 coherence we wrote and use that as the base
                thisScrambleIm = double(imread([baseFile.folder '/' baseFile.name]));
                thisScrambleIm = (thisScrambleIm - nanmean(thisScrambleIm(:)))./nanstd(thisScrambleIm(:));
            else
                % phase scramble
                thisScrambleIm  = ifft2(ifftshift(fftshift(fft2(thisBaseIm)).*exp(1i*RandAngles(size(thisBaseIm)))));
            end

            for cohInd = 1:nCoh

                thisCoh = cohList(cohInd);

                [texInd seedInd thisCoh*100]
                
                filename        = sprintf('TexFam%i-SizePix%i-Seed%i-Coh%0.2f.png', texInd,nPix,seedInd,thisCoh*100);

                thisFile = dir([writePath '/' filename]);
                if ~isempty(thisFile)
                    continue;
                end
                
                % create statistics
                thisVec         = thisNoiseVec.*(1-thisCoh) + thisTextureVec*(thisCoh);
                thisCohParams   = GetParamFromVec(thisVec,nScales,nOri,nA);

                % synth a big boy at variable coherence
                thisSynthIm = textureSynthesis(thisCohParams, thisScrambleIm, nIter);
                
                % Sometimes the generated image is inverted compared to the
                % source image. If so, flip it and try again. 
                if nancorr(thisSynthIm(:), thisScrambleIm(:)) < 0
                    thisSynthIm = -thisSynthIm;
                    'redo'
                    thisSynthIm = textureSynthesis(thisCohParams, thisSynthIm, nIter);
                end

                thisWriteIm     = (thisSynthIm - nanmean(thisSynthIm(:)))./nanstd(thisSynthIm(:));
                thisWriteIm     = uint8(128+thisWriteIm.*256.*imageContrast);
                
                imwrite(thisWriteIm, [writePath filename]);
            end
        end
    end
end


end