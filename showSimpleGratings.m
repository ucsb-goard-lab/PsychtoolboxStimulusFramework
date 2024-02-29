% Equavilent to goard lab's passive drifting gratings

clear;
close all;
sca;

orientation_list = 0:30:330; % Orientation pool
n_repeats = 10; % 10 repeats of each group of presentations

pre_time = 2; % seconds preceding stimulus on
on_time = 2; % seconds stimulus presentation
post_time = 2; % seconds following stimulus on

n_presentations = length(orientation_list); % 8 different presentations (each time is a different orientation in this case)

DAQ_flag = 0; % For triggering the microscope

for ori = 1:numel(orientation_list)
    stimulus(ori) = DriftingGrating(orientation_list(ori));
end

% Instantiate objects
manager = StimulusManager(stimulus);
manager.setScreenID(3);

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