function [Stimdata] = showSpatialMappingBars()
%%% Display a series of animated gratings in order
%%% Written MG 160504

% params
repeats = 25;                                           % Number of repeats
num_x = 8;                                              % number of x locations
num_y = 8;                                              % number of y locations
rand_flag = 1;                                          % whether to randomize presentation

% visual params
spatFreq = 0.02;                                       % Spatial Freq
tempFreq = 2;                                           % Temporal freq
contrast = 1;                                           % Contrast [0 1]
phase = 0;                                              % Phase list
patchSize = 1000;                                       % Patchsize (pixels)
offTime = 0.5;                                            % Offtime (sec)
onTime = 2;                                             % Ontime (sec)
background = 0;                                         % Bkgrnd brightness [0 1]

% Display total time of stimulus set
repDur = (onTime+offTime)*(num_x+num_y);
totalDur = repDur*repeats;
disp(['Stimulus duration: ' num2str(totalDur) ' sec'])

% calculate positions
x_pos_width = 1/num_x;
x_pos_pixels(:,1) = [0:x_pos_width:1-x_pos_width];
x_pos_pixels(:,2) = [x_pos_width:x_pos_width:1];
y_pos_width = 1/num_x;
y_pos_pixels(:,1) = [0:y_pos_width:1-y_pos_width];
y_pos_pixels(:,2) = [y_pos_width:y_pos_width:1];

% Save stimulus order to file
Stimdata.Type = 'Spatial Mapping: X and Y';
Stimdata.num_x = num_x;
Stimdata.num_y = num_y;
Stimdata.numRep = repeats;

% Choose screen for display:
screenid = 2;

% Skip sync test
Screen('Preference','SkipSyncTests',1);
Screen('Preference','VisualDebugLevel',0);
Screen('Preference','SuppressAllWarnings',1);

% Open window
win = Screen('OpenWindow', screenid, background*255);

% Set priority to max
priorityLevel = MaxPriority(win);
Priority(priorityLevel);

% NiDAQ
s = daq.createSession('ni');
addAnalogOutputChannel(s,'Dev1','ao0','Voltage');
% addAnalogInputChannel(s,'Dev1','ai0','Voltage');
outputSingleScan(s,0);

% Timing
outputSingleScan(s,5);
tstart = GetSecs;

for rep = 1:repeats
    
    if rand_flag==1
        x_pos_list(rep,:) = randperm(num_x);
        y_pos_list(rep,:) = randperm(num_y);
    else
        x_pos_list(rep,:) = [1:num_x];
        y_pos_list(rep,:) = [1:num_y];
    end
    
    for pos = 1:num_x
        
        % draw blank
        blank_on = GetSecs-tstart
        tclose = (rep-1)*repDur+(pos-1)*(offTime+onTime)+offTime;
        DrawBlank(win,background,tclose,tstart)
        
        % draw grating
        patchArea([1 3]) = x_pos_pixels(x_pos_list(rep,pos),:);
        patchArea([2 4]) = [0 1];
        stim_on = GetSecs-tstart
        tclose = (rep-1)*repDur+pos*(offTime+onTime);
        DrawDriftingGrating(win,90,spatFreq,tempFreq,contrast,phase,patchSize,patchArea,tstart,tclose)
        
    end
    
    for pos = 1:num_y
        
        % draw blank
        blank_on = GetSecs-tstart
        tclose = (rep-1)*repDur+(pos+num_x-1)*(offTime+onTime)+offTime;
        DrawBlank(win,background,tclose,tstart)
        
        % draw grating
        patchArea([1 3]) = [0 1];
        patchArea([2 4]) = y_pos_pixels(y_pos_list(rep,pos),:);
        stim_on = GetSecs-tstart
        tclose = (rep-1)*repDur+(pos+num_x)*(offTime+onTime);
        DrawDriftingGrating(win,0,spatFreq,tempFreq,contrast,phase,patchSize,patchArea,tstart,tclose)
        
    end
    
end

tfinal = GetSecs-tstart
outputSingleScan(s,0);

Screen('CloseAll');
Priority(0);

% save stimdata
Stimdata.x_pos_list = x_pos_list;
Stimdata.y_pos_list = y_pos_list;
Stimdata.offTime = offTime;
Stimdata.onTime = onTime;

try
    cd('C:\Users\Goard Lab\Dropbox\StimulusDataFiles')
    uisave('Stimdata','SpatialMapping_')
catch
    cd('C:\Users\Widefield-Stimulus\Dropbox\StimulusDataFiles')
    uisave('Stimdata','SpatialMapping_')
end
