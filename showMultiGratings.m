%{
Passive drifting gratings.
Presents at 12 orientations, 6 spatial frequencies, and 6 temporal
frequencies. Frames are presented in shuffled order with grey ISI.
%}

clear;
close all;
sca;

% set random number seed
rng(10, "twister");

shuffle = 1;
smlMonitor = 1;

orientation_list = 0:45:315; % Orientation pool
spat_freq_list = [0.02, 0.08, 0.32];
temp_freq_list = [2, 8];

if smlMonitor==1
    % convert cycles/pixel to cycles/deg
    % 77.9 pixels / 1 cm (for diagonal resolution of small monitors)
    % 1 cm / 4 deg (for monitor places 14.3 cm away from viewer)
    spat_freq_list = spat_freq_list ./ (77.9 / 4);
end

n_repeats = 8; % 10 repeats of each group of presentations

pre_time = 0; % seconds preceding stimulus on
on_time = 2; % seconds stimulus presentation
post_time = 4; % seconds following stimulus on

n_presentations = length(orientation_list) * length(spat_freq_list) * length(temp_freq_list);

DAQ_flag = 1; % For triggering the microscope

count_ = 0;
for ori = 1:numel(orientation_list)
    for sf = 1:numel(spat_freq_list)
        for tf = 1:numel(temp_freq_list)
            count_ = count_ + 1;
            stimulus(count_) = DriftingGrating(orientation_list(ori), spat_freq_list(sf), temp_freq_list(tf));
        end
    end
end

if shuffle == 1
    stimulus = stimulus(randperm(length(stimulus)));
end

% Instantiate objects
manager = StimulusManager(stimulus);
manager.setScreenID(1);

manager.initialize();
manager.setTrigger(DAQ_flag);

manager.start();

% Present the stimulus
for r = 1:n_repeats
    for p = 1:n_presentations
        manager.present(p); % internal counter
    end
end

manager.finish();

% save stimulus
cd('C:\Users\Goard Lab\Desktop')
uisave('stimulus','241120_DMM_DMM033_multiGratings_test_1')