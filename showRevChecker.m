function [] = showRevChecker(stimFreq, repeats,numSquares)
%%%Written 14Dec2016 Kevin Sit from Psychtoolbox checkerboard demo and
%%%accuratetimingdemo
%%%Modified PO 171206

%%%Makes alternating checkerboards flasing on the screen at a given
%%%frequency and # of squares across each edge

%%% fill doesn't work for vertical monitors, only horizontal. If using a
%%% vertical monitor, ensure you're using square.

if nargin == 0
%%%%%%Parameters
stimFreq = 1.5;         % frequency of checkerboard changing in Hz
repeats = 1000;         % # of repeats
numSquares = 5;       % # of squares across short edge
end

%size = 'square';      % either fill the screen, or create a maximized square in the middle: 'fill' or 'square'
size = 'fill';
degRotation = 0;      %degree of rotation per alternation, disabled when size = fill
%%%%%%

DAQflag = 0;

% Calculating necessary parametrs from input parameters
altDur = stimFreq^-1;
stimDur = altDur*2;
totalDur = stimDur * repeats;
disp(['Stimulus duration: ' num2str(totalDur) ' sec'])

%%% Copied from psychtoolbox tutorials %%%

PsychDefaultSetup(2);

% Skip sync test
Screen('Preference','SkipSyncTests',1);
Screen('Preference','VisualDebugLevel',0);
Screen('Preference','SuppressAllWarnings',1);

%choosing a screen
screenid = 1;

% Define black and white
white = WhiteIndex(screenid);
black = BlackIndex(screenid);
grey = white / 2;
inc = white - grey;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenid, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
screenDim = [screenXpixels screenYpixels];

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%%% End copy %%%

%%% Drawing the textures for the checkerboards %%%


%forcing square for vertical monitors
%if screenXpixels < screenYpixels
%    size = 'square';
%    disp('Forced into square because monitor is vertical')
%end

checkerboard = cell(1,2);

for i = 1:2
    
    screenRatio = ceil(max(screenDim)/min(screenDim)); %ratio for adjusting the texture, so that the squares are still squares when they fill the screen
    
    if strcmp(size, 'fill') == 1 % for filled screen
        degRotation = 0; %disables rotation for a filled screen
        if mod(numSquares, 2) == 0
            checkerboard{i} = repmat(eye(2), (numSquares/2), numSquares/2 * screenRatio); %creating the matrix for the texture for even squares
        elseif mod(numSquares, 2) == 1
            checkerboard{i} = repmat(eye(2), ceil(numSquares/2), ceil(numSquares/2 * screenRatio)); %creating the matrix for the texture for odd squares
            checkerboard{i} = checkerboard{i}(1:end-1, 1:end-1);
        else
            disp('Error in number of squares, check the parameters')
        end
        
        dstRect = [0 0 screenXpixels screenYpixels]; %to fill the screen 
        
    elseif strcmp(size,'square') == 1 %for square in the middle
        if mod(numSquares, 2) == 0
            checkerboard{i} = repmat(eye(2), numSquares/2, numSquares/2);
        elseif mod(numSquares,2) == 1
            checkerboard{i} = repmat(eye(2), ceil(numSquares/2), ceil(numSquares/2));
            checkerboard{i} = checkerboard{i}(1:end-1, 1:end-1);
        else
            disp('Error in number of squares, check the parameters')
        end
        
        dim = min([screenXpixels screenYpixels]); 
        dstRect = [0 0 dim dim]; %creates a square in the middle that fills one dimension, but not the other
        
    else
        disp('Error in size of checkerboard, change the parameter')
    end
    
    if i == 2
        checkerboard{i} = checkerboard{i}*-1 + 1; %inverts the matrix for the second checkerboard, so we have the inverted checkerboard
    end
end

% Make the checkerboard into a texure (4 x 4 pixels)
checkerTexture = Screen('MakeTexture', window, checkerboard{1});
checkerTexture1 = Screen('MakeTexture', window,  checkerboard{2});

   dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);

%%% End checkerboard texture drawing %%%

%%% Stimulus presentation
filterMode = 0;




% NiDAQ
if DAQflag==1
    s = daq.createSession('ni');
    addAnalogOutputChannel(s,'Dev1','ao0','Voltage');
    outputSingleScan(s,0);
end

% Timing
if DAQflag==1
    outputSingleScan(s,5);
end


tstart = GetSecs;

for i = 1:repeats
    tchange = (i)*stimDur - altDur;
    tclose = (i-1)*stimDur + stimDur;
    
    while GetSecs - tstart < tchange
        Screen('DrawTextures', window, checkerTexture, [], dstRect, (i-1)*degRotation, filterMode);
        Screen('Flip',window);
    end
    
    while GetSecs - tstart > tchange && GetSecs - tstart < tclose
        Screen('DrawTextures', window, checkerTexture1, [], dstRect, (i-1)*degRotation+degRotation/2, filterMode);
        Screen('Flip',window);
    end
    
    if mod(i,5) == 0
        %curr_time = GetSecs - tstart
    end
    
end

tfinal = GetSecs-tstart;

%%% End stimulus presentation
if DAQflag==1
    outputSingleScan(s,0);
end
Screen('CloseAll')
Priority(0);



sca;
clear all;
close all;
end
