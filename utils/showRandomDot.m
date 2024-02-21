    % Equavilent to goard lab's passive drifting gratings
    clear;
    close all;
    sca;

    pre_time = 0.5; % seconds preceding stimulus on
    on_time = 1; % seconds stimulus presentation
    post_time = 0.5; % seconds following stimulus on

    n_repeats = 1; % 10 repeats of each group of presentations

    orientation_list = [0:45:315]; % Orientation pool

    n_presentations = length(orientation_list); % 8 different presentations (each time is a different orientation in this case)

    DAQ_flag = 0; % For triggering the microscope
    for ii = 1:numel(orientation_list)
    stimulus(ii) = RandomDotKinematogram(0.8, orientation_list(ii));
    end

    % Instantiate objects
    manager = StimulusManager(stimulus);
    manager.setScreenID(2);

    manager.setTrigger(DAQ_flag); 
    manager.initialize();

    manager.start();

    %% get the timer working tomorrow 
    for r = 1:n_repeats
        for p = 1:n_presentations
            manager.present(p); % internal counter
        end
    end

    manager.finish();