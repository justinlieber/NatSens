

%% Setup

texFamList  = [18 30 60 336 459];
nTrials     = 160;

subjectID   = 'JDL';
expInd      = 2;
texFamInd   = 1;

% Set up experimental parameters
switch expInd
    case 1 % Low-pass filtering
        % Set write pathways
        expName         = 'StandardLowPassResults';
        imagePath       = '/v/analysis/justin/images/NatSens/LowPassImages/'; 
        writePath       = '/v/psycho/Justin/NatSens/Results/StandardLowPassResults/';

        % Image parameters
        lowPassEdgeList = (2.^[0.5:0.5:4])*4;
        nSize           = length(lowPassEdgeList);
        groupIndList    = [8:-1:1];

        runEyeTrack = false;

        
        expParameters   = GetLowPassStimulusParameters(texFamList(texFamInd), lowPassEdgeList,imagePath);

    case 2 % Rescaling
        % Set write pathways
        expName         = 'FullScaleResults';
        imagePath       = '/v/analysis/justin/images/NatSens/RescaledImages/';
        writePath       = '/v/psycho/Justin/NatSens/Results/FullScaleResults/';
        % Image parameters
        imageZoomList   = 2.^[0 0.5 1 2 3 3 3]/4;
        viewDistList    = round([1 1 1 1 1 0.5 0.25]*1.42*100)/100; % actual presentation distance
        nSize           = length(viewDistList);
        groupIndList    = [6 7 5 4 3 2 1];
        runEyeTrack     = false;
        
        expParameters   = GetFullScaleStimulusParameters(texFamList(texFamInd), imageZoomList,viewDistList,imagePath);
    
    case 3 % Rescaling low-pass filtered images
        % Set write pathways
        expName         = 'FilterScaleResults';
        imagePath       = '/v/analysis/justin/images/NatSens/RescaledLowPassImages/';
        writePath       = '/v/psycho/Justin/NatSens/Results/FilterScaleResults/';
        % Image parameters
        imageZoomList   = 2.^[0 0.5 1 2 3 3 3]/4;
        viewDistList    = round([1 1 1 1 1 0.5 0.25]*1.42*100)/100; % actual presentation distance
        nSize           = length(viewDistList);
        groupIndList    = [6 7 5 4 3 2 1];
        runEyeTrack     = false;
        
        lpFilterEdge      = 2.^4.5; % c/image
        
        expParameters   = GetFilterScaleStimulusParameters(texFamList(texFamInd), imageZoomList,viewDistList, lpFilterEdge, imagePath);
    case 4 % Eccentricity
        expName         = 'StandardEccentricityResults';
        imagePath       = '/v/analysis/justin/images/NatSens/RescaledImages/';
        writePath       = '/v/psycho/Justin/NatSens/Results/StandardEccentricityResults/';
        
        eccList             = 0:4:24;
        imageZoomList       = [2.^[zeros(size(eccList(1:4))) -ones(size(eccList(5:7)))]];
        viewDistList        = round((imageZoomList)*1.42*100)/100;

        stimLocationList    = [5 5 5 5 5 5 9];
        fixLocationList     = stimLocationList - eccList;
        groupIndList        = 1:7;

        nSize               = length(viewDistList);

        % Calibrate the Eyetracker
        runEyeTrack = true;
        
        expParameters       = GetEccStimulusParameters(texFamList(texFamInd), fixLocationList, stimLocationList, imageZoomList, viewDistList, imagePath);
end

fullSizeOutput = {};

%% Run experiment on all conditions


currentViewDist = 1.42; % m

for groupListInd=1:nSize
    %% Run each individual scale
    groupInd = groupIndList(groupListInd);

    oldViewDist     = currentViewDist;
    currentViewDist = CheckUpdateViewDistance(expParameters{groupInd}.viewDist, currentViewDist);
    
    %outputStruct    = RunFullNamedStaircase(sizeImGroup{groupInd}, writePath, subjectID, currentViewDist,scaleName );
    outputStruct    = AXBStaircase_PTB(expParameters{groupInd}, writePath, subjectID, currentViewDist,expName,nTrials,runEyeTrack);
    fullSizeOutput{groupInd} = outputStruct;

%%
    figure(1); clf;
    PlotScaleThresholds(expParameters, fullSizeOutput);
    drawnow;

    figure(2)
    subplot(2,4,groupInd)
    cla;
    saveBeta(:,groupInd) = PlotStaircaseSigmoidFit(fullSizeOutput{groupInd}, expParameters{groupInd}.cohList,[]);
    title(sprintf('size: %0.2f, thr:%0.1f',expParameters{groupInd}.eyeDegSize, 2.^(saveBeta(1,groupInd))));
    drawnow;

end
