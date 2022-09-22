

function [outputStruct, behSummaryMat] = AXBStaircase_PTB(stimuliGroupList, writePath, subjectID, currentViewDist,taskName,nTrials,runEyeTrack)

if ~exist('nTrials') || isempty(nTrials)
    nTrials         = 160;    
end

% Initialize Screen
PsychDefaultSetup(1);

screenNumber    = max(Screen('Screens'));
meanGrayColor   = [0.5 0.5 0.5]*256;
ptbWindow       =   Screen('OpenWindow', screenNumber,meanGrayColor);

if ~exist('runEyeTrack') || isempty(runEyeTrack) || ~runEyeTrack
    % no need to setup
    runEyeTrack = false;
else
    el=EyelinkInitDefaults(ptbWindow);
    
    
    % STEP 3
    if ~EyelinkInit(0, 1)x
        fprintf('Eyelink Init failed.\n');
        beep()
        cleanup;  % cleanup function
        return;
    end
    
    % make sure that we get gaze data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    
    commandwindow;
    EyelinkDoDriftCorrection(el);
    Eyelink('StartRecording');
end

if isfield(stimuliGroupList,'fixLocation')
    fixLocation     = [stimuliGroupList.fixLocation 0];
else
    fixLocation     = [0 0];
end

if isfield(stimuliGroupList,'stimLocation')
    stimuliLoc     = [stimuliGroupList.stimLocation 0];
elseif isfield(stimuliGroupList, 'stimLocationX')
    stimuliLoc     = [stimuliGroupList.stimLocationX stimuliGroupList.stimLocationY];
else
    stimuliLoc     = [0 0];
end

writeFilename       = sprintf('%s-Subject%s-%s', taskName,subjectID, stimuliGroupList.writeStimParam);
writeFullPathName   = [writePath writeFilename];

if ~exist(writePath,'dir')
    mkdir(writePath);
end

if stimuliGroupList.viewDist~= currentViewDist
    error('Set View Distance to %0.2f', stimuliGroupList.viewDist);
end

viewDist_m = stimuliGroupList.viewDist;


% input parameters (a lot)

% format: cell{nGroups}(nLevels,nSamples);
% this is meant to be a structure that carries full paths to images

%%%%%%
% Parse Inputs
%%%%%%

if ~exist('stimuliGroupList') || isempty(stimuliGroupList) 
    error('GroupABXStaircase: No images passed in\n');
end

if ~exist('writeFullPathName') || isempty(writeFullPathName) 
    error('GroupABXStaircase: No write path passed in\n');
end

if ~exist('subjectID') || isempty(subjectID) 
    warning('GroupABXStaircase: No subject name passed in, setting to "testSubject'\n');
    subjectID = 'testSubject';
end

if ~exist('viewDist_m') || isempty(viewDist_m) 
    warning('GroupABXStaircase: No view distance passed in, setting to 1.42 m\n');
    viewDist_m = 1.42;
end

if ~exist('nTrials') || isempty(nTrials) 
    nTrials = size(stimuliGroupList,1)*8;
    warning('GroupABXStaircase: # trials per group not set, setting to %i m\n', nTrials);
end

if ~exist('fixLocation') || isempty(fixLocation) 
    fixLocation = [0 0];
elseif length(fixLocation)==1
    fixLocation = [fixLocation 0];
end

if ~exist('stimuliLoc') || isempty(stimuliLoc) 
    stimuliLoc = [0 0];
elseif length(stimuliLoc)==1
    stimuliLoc = [stimuliLoc 0];
end

if ~exist('runEyeTrack') || isempty(runEyeTrack);
    runEyeTrack = false;
end



[~,compName] = system('hostname');

if strcmp(strtrim(compName), 'gurnemanz')
    isGurn = true;
else
    isGurn = false;
end
    

randSeed    = randi(2.^32,1);
rng(randSeed,'twister');


outputStruct = [];
outputStruct.subjectID      = subjectID;
outputStruct.writeFullPathName  = writeFullPathName;
outputStruct.fixLocation    = fixLocation;
outputStruct.stimuliLoc     = stimuliLoc;
outputStruct.viewDist_m     = viewDist_m;
outputStruct.nTrials        = nTrials;
outputStruct.nGroups        = 1;


% drawFixDuring: do we draw fixation point between trials
if isfield(stimuliGroupList,'eccentricity')
    drawFixDuring       = true; 
else
    drawFixDuring       = false; 
end


staircaseShift      = 6; % start staircase shifted down by 6 steps

% staircase structure
upDownList          = [1 2; 1 3]; %2 staircases: 1u2d and 1u3d


%% Initialize the screen





%%%%%%%%%%
% Experiment parameters
%%%%%%%%%%
screenProperties                        = [];



if isGurn
    screenProperties.RES_BACKGROUND_PIX     = [1280 1024]; %pix, stimulus must be square!
else
    screenProperties.RES_BACKGROUND_PIX     = [1280 960]; %pix, stimulus must be square!
end
screenProperties.SCREEN_CENTER_PIX      = (screenProperties.RES_BACKGROUND_PIX+1)/2;
%screenProperties.RES_DISPLAY_CM         = [30 40]; % cm

screenProperties.N_STIMULI              = 3;
screenProperties.CONDITIONS_X           = 2;
screenProperties.DURATION_INITIAL_BLANK = 0.4; % seconds
screenProperties.DURATION_STIMULI       = 0.2;
screenProperties.DURATION_BLANK2_S      = 0.4;
screenProperties.DURATION_INTERSTIM     = 0.3;
screenProperties.DURATION_AFTERCHOICE   = 0.25;

screenProperties.DISTANCE_VIEWING_M     = viewDist_m; 
screenProperties.PIX_PER_DEG            = 32*screenProperties.DISTANCE_VIEWING_M/.57;

%%%%%%%%%%
% Stimuli
%%%%%%%%%%
screenProperties.STIMULI_LOC_DEG = stimuliLoc; 
screenProperties.STIMULI_LOC_PIX = screenProperties.STIMULI_LOC_DEG*screenProperties.PIX_PER_DEG + screenProperties.SCREEN_CENTER_PIX; 
%screenProperties.X_STIM_DEG     = ones(1,screenProperties.N_STIMULI)*screenProperties.STIMULI_LOC(1);
%screenProperties.Y_STIM_DEG     = ones(1,screenProperties.N_STIMULI)*screenProperties.STIMULI_LOC(2);


%%%%%%%%%%
% Fixation target & blank screen
%%%%%%%%%%

if isfield(stimuliGroupList, 'contrast')
    imageSetContrast = stimuliGroupList.contrast;
    screenProperties.FIX_CONTRAST = min(0.15, (imageSetContrast/100)*8);
else
    screenProperties.FIX_CONTRAST           = 0.15;
end
screenProperties.FIX_LOC_DEG            = fixLocation;
screenProperties.FIX_WIDTH_DEG          = 0.1; % deg, square target


fixLocPix       = screenProperties.RES_BACKGROUND_PIX/2 + ceil(screenProperties.FIX_LOC_DEG.*screenProperties.PIX_PER_DEG);
fixWidthPix     = ceil(screenProperties.FIX_WIDTH_DEG.*screenProperties.PIX_PER_DEG); 
blankScreen     = 0.5*ones(screenProperties.RES_BACKGROUND_PIX);
targetInd       = (1:fixWidthPix) - floor(fixWidthPix/2);
targetScreen    = blankScreen;
targetScreen(targetInd+fixLocPix(1),targetInd+fixLocPix(2)) = ...
    blankScreen(targetInd+fixLocPix(1),targetInd+fixLocPix(2))-screenProperties.FIX_CONTRAST;


screenProperties.TARGET_POS_RECT        = [targetInd(1) targetInd(1) targetInd(end) targetInd(end)] + [fixLocPix(1) fixLocPix(2) fixLocPix(1) fixLocPix(2)];
screenProperties.TARGET_DARK_COLOR      = 256*(0.5 - [1 1 1]*screenProperties.FIX_CONTRAST);
screenProperties.TARGET_BLANK_COLOR     = 256*(0.5 + [1 1 1]*0);
screenProperties.TARGET_LIGHT_COLOR     = 256*(0.5 + [1 1 1]*screenProperties.FIX_CONTRAST);

screenProperties.BLANK_SCREEN           = 256*blankScreen;
screenProperties.DARK_TARGET_SCREEN     = 256*targetScreen;
screenProperties.LIGHT_TARGET_SCREEN    = 256*(-1*(targetScreen - 0.5) + 0.5);

%% Gamma correction
gammaTable = GetGammaTable();

%% Initialize the behavior

% We're using an AXB task structure
% Trials can be of four possible forms: 
%   signal / signal / noise,  correct = left
%   signal / noise  / noise,  correct = right
%   noise  / signal / signal, correct = right
%   noise  / noise  / signal, correct = left

behProperties           = [];
behProperties.dimNames  = {'behStimLevel','behSignalWindow','behSignalX',...
    'behGroup','behUserInput','behCorrect'};
behProperties.dimDescriptions = {'stimulus level value', 'first stimulus (A), signal=1, noise=0',...
    'second (test) stimulus (X), signal=1, noise=0', 'user input, left=1, right=2', ...
    'is user correct?'};

nDim = length(behProperties.dimNames);
for dimInd = 1:nDim
    %behProperties = setfield(behProperties,behProperties.dimNames{dimInd},dimInd);
    behProperties.(behProperties.dimNames{dimInd}) = dimInd;
end


behProperties.useKeys           = [39 41]; % j, k, corresponds to left/right
behProperties.useKeys           = {'j','k'}; % j, k, corresponds to left/right
behProperties.IX_FEEDBACK_POS   = 2;
behProperties.IX_FEEDBACK_NEG   = 1;

behProperties.nPracticeTrials   = 3; % 3 practice trials at the start



nUseTrials                      = nTrials + behProperties.nPracticeTrials;
nTotalTrials                    = nUseTrials.*outputStruct.nGroups;


outputStruct.behavior           = nan(nTotalTrials,nDim);
outputStruct.behDimNames        = behProperties.dimNames;
outputStruct.behDimDescriptions = behProperties.dimDescriptions;


%% Read in stimuli

nStimGroup          = 1;
totalTrials         = nUseTrials.*nStimGroup;

groupOrder          = repmat(1:nStimGroup,[nUseTrials 1]);
[~,randIndOrder]    = sort(rand([totalTrials 1]));
groupOrder          = groupOrder(randIndOrder);

outputStruct.behavior(:,behProperties.behGroup) = groupOrder;

groupProperties                 = [];
groupProperties.staircase       = cell(nStimGroup,1);

% Initialize practice trial counter
groupProperties.practiceCounter = ones(nStimGroup,1).*behProperties.nPracticeTrials;

stimuliList         = cell(1,1,nStimGroup);


stimuliGroup = stimuliGroupList;
    
groupNLevels  = size(stimuliGroupList.filenames,1);
groupNSamples = size(stimuliGroupList.filenames,2);


for levelInd = 1:groupNLevels
    for sampleInd = 1:groupNSamples
        if isempty( stimuliGroup.filenames{levelInd,sampleInd} )
            continue
        end
        thisIm = imread(stimuliGroup.filenames{levelInd,sampleInd});

        % filtering goes here
        % vignetting goes here

        stimuliList{levelInd,sampleInd} = thisIm;
    end
end

if isempty(staircaseShift)
    initialLevels = round((groupNLevels-1)).*[1 1]; 
else
    initialLevels = round((groupNLevels-staircaseShift-1)).*[1 1];
end

% Initialize staircase
%  # levels = groupNLevels-1, because we don't count 0
groupProperties.staircase = MakeStaircaseStructure(upDownList,groupNLevels-1,nUseTrials,initialLevels);



% Set up trial pattern

% Randomize 1/4 conditions
N                   = ceil(nUseTrials/4);
condOrder           = repmat(1:4,[N 1]);
[~,randIndOrder]    = sort(rand([N*4 1]));
condOrder           = condOrder(randIndOrder(1:nUseTrials));

% Randomize 3/15 seeds into the three positions
[~,sampleOrder]     = sort(rand(groupNSamples, nUseTrials));
sampleOrder         = sampleOrder(1:3,:);

groupProperties.behSignalWindow   = condOrder == 1 | condOrder == 2;
groupProperties.behSignalX        = condOrder == 1 | condOrder == 3;
groupProperties.sampleOrder       = sampleOrder;

outputStruct.behavior(:,behProperties.behSignalWindow)  = groupProperties.behSignalWindow;
outputStruct.behavior(:,behProperties.behSignalX)       = groupProperties.behSignalX;


groupProperties.nLevels         = groupNLevels;
groupProperties.nSamples        = groupNSamples;
groupProperties.nTotalTrials    = totalTrials;
groupProperties.trialOrder      = groupOrder;
groupProperties.trialCounter    = zeros(nStimGroup,1);


%% Initialize MGL and draw to the screen

% global MGL;
% mglListener('init');
% 
% mglOpen();
% %mglVisualAngleCoordinates(100*screenProperties.DISTANCE_VIEWING_M, fliplr(screenProperties.RES_DISPLAY_CM));
% mglVisualAngleCoordinates(142, fliplr([30 40]));
% mglClearScreen([0.5 0.5 0.5]); mglFlush
% 
% % Gamma correction.
% mglSetGammaTable(gammaTable.redInd,gammaTable.greenInd,gammaTable.blueInd);

%mglDarkTarget   = mglCreateTexture(255.0*screenProperties.DARK_TARGET_SCREEN);
%mglLightTarget  = mglCreateTexture(255.0*screenProperties.LIGHT_TARGET_SCREEN);
%mglGray         = mglCreateTexture(255.0*screenProperties.BLANK_SCREEN);

%% Initialize PsychToolbox and draw to the screen

meanGrayColor   = [0.5 0.5 0.5]*256;
if ~exist('ptbWindow')
    PsychDefaultSetup(1);

    % find display screen
    screenNumber    = max(Screen('Screens'));

    % initialize screen
    ptbWindow       =   Screen('OpenWindow', screenNumber,meanGrayColor);
end

% gamma correction
Screen('LoadNormalizedGammaTable',ptbWindow,[gammaTable.redInd; gammaTable.greenInd; gammaTable.blueInd]');

ptbDarkTarget   = Screen('MakeTexture', ptbWindow, screenProperties.DARK_TARGET_SCREEN');
ptbLightTarget  = Screen('MakeTexture', ptbWindow, screenProperties.LIGHT_TARGET_SCREEN');
ptbGray         = Screen('MakeTexture', ptbWindow, screenProperties.BLANK_SCREEN');

ptbDarkTargetFunc   = @()(Screen('FillRect',ptbWindow,screenProperties.TARGET_DARK_COLOR,screenProperties.TARGET_POS_RECT));
%ptbBlankTargetFunc  = @()(Screen('FillRect',ptbWindow,screenProperties.TARGET_BLANK_COLOR,screenProperties.TARGET_POS_RECT));
ptbBlankTargetFunc  = @()(1);
ptbLightTargetFunc  = @()(Screen('FillRect',ptbWindow,screenProperties.TARGET_LIGHT_COLOR,screenProperties.TARGET_POS_RECT));

if ~exist('drawFixDuring') || drawFixDuring == false
    ptbIntertrialScreen           = ptbGray;
    ptbIntertrialFunc             = ptbBlankTargetFunc;
else
    ptbIntertrialScreen           = ptbDarkTarget;
    ptbIntertrialFunc             = ptbDarkTargetFunc;
end


% Set both display buffers to gray.
fullScreenRect  = [0 0 screenProperties.RES_BACKGROUND_PIX];
Screen('DrawTexture',ptbWindow,ptbGray); Screen('Flip',ptbWindow);
Screen('DrawTexture',ptbWindow,ptbGray); Screen('Flip',ptbWindow);


% Wait for first keypress
Screen('DrawTexture',ptbWindow,ptbGray); ptbDarkTargetFunc(); Screen('Flip',ptbWindow); 
%Screen('DrawTexture',ptbWindow,ptbDarkTarget,[],fullScreenRect); Screen('Flip',ptbWindow);

% sound settings
beepF       = 300;
soundVol    = 0.1;

% Find appropriate keyboard
keyboardList    = GetKeyboardIndices();
% inputKbId       = keyboardList(1);  % only listen to a single keyboard
inputKbId       = -1;                 % listen to all keyboards

% Key code list
keyCodeIndList = [];
for i=1:length(behProperties.useKeys)
    keyCodeIndList(i) = KbName(behProperties.useKeys{i});
end



disp('Awaiting key press...')
commandwindow;
Beeper(beepF*2,soundVol,0.05); Beeper(beepF,0,0.05); Beeper(beepF*3,soundVol,0.05);
%Beeper(beepF,soundVol,0.15);


%FlushEvents();

[~,keyCodeOutput]     = KbWait(inputKbId);
while ~any(keyCodeOutput(keyCodeIndList))
    [~,keyCodeOutput]     = KbWait(inputKbId);
end

%% Eyelink setup

%warning('Have not yet done Eyelink integration\n')
if runEyeTrack
    el = EyelinkInitDefaults();

    eyelinkSettings                 = [];
    eyelinkSettings.runEyeTrack     = runEyeTrack;
    eyelinkSettings.maxDeviation    = screenProperties.PIX_PER_DEG*1.25;
    
    eyelinkData             = [];
    eyelinkData.eyeUsed     = Eyelink('EyeAvailable');
    eyelinkData.xyInd       = [14 16] + (eyelinkData.eyeUsed);

    eyelinkData.fullData    = cell(groupProperties.nTotalTrials,1);
    eyelinkData.minX        = nan(groupProperties.nTotalTrials,1);
    eyelinkData.maxX        = nan(groupProperties.nTotalTrials,1);
    eyelinkData.minY        = nan(groupProperties.nTotalTrials,1);
    eyelinkData.maxY        = nan(groupProperties.nTotalTrials,1);
end


%% Loop

for fullTrialInd = 1:groupProperties.nTotalTrials
    
    groupProperties.trialCounter = groupProperties.trialCounter + 1;
    trialInd        = groupProperties.trialCounter;
    
    % Find level for next trial
    if groupProperties.practiceCounter <= 0
        % normal staircase trial
        thisStaircase   = groupProperties.staircase;
        testLevelInd    = thisStaircase.GetNextLevel(thisStaircase,trialInd)+1; 
    else
        %practice trial
        groupProperties.practiceCounter = groupProperties.practiceCounter-1;
        testLevelInd    = groupProperties.nLevels; % max level for practice trials
    end    

    outputStruct.behavior(fullTrialInd,behProperties.behStimLevel) = testLevelInd;
    
    % Initialize stimuli
    isFirstSignal   = groupProperties.behSignalWindow(trialInd);
    isSecondSignal  = groupProperties.behSignalX(trialInd);
    
    signalBoolList  = [isFirstSignal isSecondSignal ~isFirstSignal];
    correctLoc      = 1 + int8(~(isFirstSignal==isSecondSignal));
    
    ptbStim         = cell(3,1);
    ptbTextDrawBox  = cell(3,1);
    for stimInd = 1:3
        sampleInd = groupProperties.sampleOrder(stimInd,trialInd);    
        
        if signalBoolList(stimInd)
            thisLevelInd = testLevelInd;
        else
            thisLevelInd = 1;
        end
        
        thisStim = stimuliList{thisLevelInd,sampleInd};
        ptbStim{stimInd} = Screen('MakeTexture', ptbWindow,thisStim);
        
        thisTextSize    = size(thisStim);
        thisDrawBox     = [-thisTextSize(2) -thisTextSize(1) thisTextSize(2) thisTextSize(1)]/2;
        thisDrawBox     = thisDrawBox + [1 0 1 0]*screenProperties.STIMULI_LOC_PIX(1);
        thisDrawBox     = thisDrawBox + [0 1 0 1]*screenProperties.STIMULI_LOC_PIX(2);
        ptbTextDrawBox{stimInd} = thisDrawBox;
    end
  
  
  %%%%%%%%%%
  % Render images
  %%%%%%%%%%
  
  eyeSampleList = {};
  % initial blank
  if (screenProperties.DURATION_INITIAL_BLANK > 0)
      
    eyeSampleList = cat(2,eyeSampleList,{GetNewestFloatSample(runEyeTrack)});
      
    Screen('DrawTexture',ptbWindow,ptbGray); 
    ptbDarkTargetFunc();
    Screen('Flip',ptbWindow);
      
    eyeSampleList = cat(2,eyeSampleList,{GetNewestFloatSample(runEyeTrack)});

    WaitSecs(screenProperties.DURATION_INITIAL_BLANK);
    
    eyeSampleList = cat(2,eyeSampleList,{GetNewestFloatSample(runEyeTrack)});
  end
  
  
  for stimInd = 1:3
      Screen('DrawTexture',ptbWindow,ptbGray);
      Screen('DrawTexture',ptbWindow,ptbStim{stimInd},[],ptbTextDrawBox{stimInd});
      ptbIntertrialFunc();
      %Screen('DrawTexture',ptbWindow,ptbStim{stimInd});
      Screen('Flip',ptbWindow);
      
      eyeSampleList = cat(2,eyeSampleList,{GetNewestFloatSample(runEyeTrack)});
      
      WaitSecs(screenProperties.DURATION_STIMULI);
      
      eyeSampleList = cat(2,eyeSampleList,{GetNewestFloatSample(runEyeTrack)});
      
      % intertrial
      Screen('DrawTexture',ptbWindow,ptbGray);
      ptbIntertrialFunc();
      Screen('Flip',ptbWindow);
      
      eyeSampleList = cat(2,eyeSampleList,{GetNewestFloatSample(runEyeTrack)});
      
      WaitSecs(screenProperties.DURATION_INTERSTIM);
      
      eyeSampleList = cat(2,eyeSampleList,{GetNewestFloatSample(runEyeTrack)});
  end
  
  % change fixation point color
  Screen('DrawTexture',ptbWindow,ptbGray);
  ptbLightTargetFunc();
  Screen('Flip',ptbWindow);
  
  eyeSampleList = cat(2,eyeSampleList,{GetNewestFloatSample(runEyeTrack)});
  %%%%%%%%%%
  

  if runEyeTrack

    %eyelinkData.eyeUsed     = Eyelink('EyeAvailable');
    %eyelinkData.xyInd       = [14 16] + (eyelinkData.eyeUsed);

    
    useMask                             = cellfun(@(x)isfield(x,'time'), eyeSampleList);
    if sum(useMask) < 16
        warning('only got %i/16 eye track samples\n',sum(useMask)); 
    end
    eyeSampleList                       = eyeSampleList(useMask);
    
    eyelinkData.fullData{fullTrialInd}  = eyeSampleList;
    eyelinkData.time{fullTrialInd}      = cellfun(@(x)(x.time),eyeSampleList);
    
    
    xPos    = cellfun(@(x)(x.gx(eyelinkData.eyeUsed+1)),eyeSampleList);
    eyelinkData.minX(fullTrialInd)      = min( xPos );
    eyelinkData.maxX(fullTrialInd)      = max( xPos );
    
    yPos    = cellfun(@(x)(x.gy(eyelinkData.eyeUsed+1)),eyeSampleList);
    eyelinkData.minY(fullTrialInd)      = min( yPos );
    eyelinkData.maxY(fullTrialInd)      = max( yPos );

    rVal = sqrt((xPos-median(xPos)).^2+(yPos-median(yPos)).^2);
    eyelinkData.maxRVal(fullTrialInd)      = max(rVal);
    
    %if ( any(xPos < -500) || any(yPos < -500) )
    if max(rVal) > eyelinkSettings.maxDeviation
        largeRad    = eyelinkSettings.maxDeviation;
        p           = min(largeRad, max(rVal) - largeRad)/largeRad;
        useF        = 2.^(log2(beepF)+(3*p));
        eyeTrackVol = soundVol/6.5;
        lowFactor = 0.71;
        Beeper(useF*0.7*lowFactor,eyeTrackVol*2,0.2);Beeper(useF,0,0.1); Beeper(useF*0.55*lowFactor,eyeTrackVol*2,0.1);
    end
  end
  
 
  %%%%%%%%%%
  % Get response
  %%%%%%%%%%
  commandwindow;
  [~,keyCodeOutput]     = KbWait(inputKbId);
  while ~any(keyCodeOutput(keyCodeIndList)) %|| length(keyCodeOutput)>1
      [~,keyCodeOutput]     = KbWait(inputKbId);
  end
  
  responseChoice    = find(keyCodeOutput(keyCodeIndList)); 
  
  isCorrect         = responseChoice == correctLoc;
  
  outputStruct.behavior(fullTrialInd,behProperties.behUserInput)    = responseChoice;
  outputStruct.behavior(fullTrialInd,behProperties.behCorrect)      = isCorrect;
  
  
  %%%%%%%%%%
  % Feedback 
  %%%%%%%%%%
  if (isCorrect)
      Beeper(beepF*2,soundVol,0.05); Beeper(beepF,0,0.05); Beeper(beepF*3,soundVol,0.05);
  else
      Beeper(beepF,soundVol,0.15);Beeper(beepF,0,0.1); Beeper(beepF,soundVol,0.15);
  end
  WaitSecs(screenProperties.DURATION_AFTERCHOICE);
  %%%%%%%%%%
  
  % update staircase level
  groupProperties.staircase = ...
      UpdateStairLevel(groupProperties.staircase,trialInd,isCorrect);
  
  
  for stimInd=1:3
    Screen('Close', ptbStim{stimInd});
  end
end

%% Run some quick analysis

outputStruct.behavior;


%%

uBehLev = unique(outputStruct.behavior(:,behProperties.behStimLevel));

behSummaryMat = [];
for levInd = 1:length(uBehLev)
    levMask = outputStruct.behavior(:,behProperties.behStimLevel) == uBehLev(levInd);
    behSummaryMat(levInd,:) = [uBehLev(levInd) sum(levMask) sum(outputStruct.behavior(levMask,behProperties.behCorrect))];
end


if isfield(stimuliGroupList,'cohList')
    behSummaryMat(:,1) = stimuliGroupList.cohList(behSummaryMat(:,1));
end

outputStruct.behSummaryMat = behSummaryMat;

%%
%% Clean up

if runEyeTrack
    outputStruct.eyelinkData = eyelinkData;
end


sca;
clear stimuliList

% write data
fullPath = sprintf('%s-Taken%s',writeFullPathName,datestr(now,30));
save([fullPath '.mat']);
dlmwrite(sprintf('%s.text',fullPath),outputStruct.behavior,'delimiter',',')


sca;
if runEyeTrack
    Eyelink('StopRecording');
end


return;


