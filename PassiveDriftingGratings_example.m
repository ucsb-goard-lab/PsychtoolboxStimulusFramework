%PassiveDriftingGratings_new

oriList = [0:30:330];%[0:30:330];                                   % Orientation list, Default = [0:30:330]
repeats = 8;                                            % Number of repeats, Default = 8
spatFreqList = 0.004 * ones(1,length(oriList));         % Spatial Freq, Default = 0.004
tempFreqList = 2 * ones(1,length(oriList));             % Temporal freq, Default = 2
contrastList = 1 * ones(1,length(oriList));             % Contrast [0 1], Default = 1
phaseList = zeros(1,length(oriList));                   % Phase list, Default = 0
offTime = 4;                                            % Offtime (sec), Default = 4
onTime = 2;                              
DAQ_flag = 0;   

% Display total time of stimulus set
repDur = (onTime+offTime)*length(oriList);
totalDur = repDur*repeats;
disp(['Stimulus duration: ' num2str(totalDur) ' sec'])

% Instantiate objects
renderer = StimulusRenderer(); %renderer for drawing..
renderer.setScreenID(1); % In case you need to change the screenID

logger = StimDataLogger(oriList, repeats, spatFreqList, tempFreqList, contrastList, phaseList, offTime, onTime); % pass variables to save
logger.setSaveDirectory(); % set it now, so you don't prompt later

triggerer = MicroscopeTriggerer('2P', DAQ_flag); % Enable it here, and it'll remember if it's supposed to be doing stuff

% Initialize objects
triggerer.initialize(); % If not enabled, nothing will happen, prevents us from typing 1000x DAQ_flags
renderer.initialize(); % this will also open the window

% Start stimulus presentation
triggerer.sendTrigger(); % chg to start
renderer.startTimer();

for rep = 1:repeats
    for ori = 1:length(oriList)
        % draw blank
        blank_on = renderer.getTime()
        tclose = (rep-1)*repDur+(ori-1)*(offTime+onTime)+offTime; % calculate end time
        renderer.drawBlank(tclose); % everything else is held in the object
        
        % draw grating
        stim_on = renderer.getTime()
        tclose = (rep-1)*repDur+ori*(offTime+onTime);
        renderer.drawDriftingGrating(...
            tclose, oriList(ori), spatFreqList(ori), tempFreqList(ori), contrastList(ori), phaseList(ori))   
    end
end

tfinal = renderer.getTime()

triggerer.cleanUp(); % chg to finish
renderer.cleanUp(); %chg to finish

logger.saveData(); % save your stimdata