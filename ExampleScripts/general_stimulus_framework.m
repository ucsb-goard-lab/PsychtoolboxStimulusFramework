% This is the general framework for creating stimuli using the new stimulus framework:


% Because these are designed to work with scripts and not functions, make sure you clean up your workspace before starting
clear; 
close all;
sca;

%% Defining times 
pre_time = 2; % seconds preceding stimulus on
on_time = 2; % seconds stimulus is on for
post_time = 2; % seconds following stimulus on

n_presentations = 15; % Unique presentations of stimuli, see examples for some common use cases
n_repeats = 10; % Number of repeats for each group of presentations

DAQ_flag = 0; % flag for enabling or disabling the triggerer

%% Instantiate the manager
manager = StimulusManager(); % stimulus manager creates all the subclasses necessary for presentation
manager.setScreenID(1); % PTB screen for display

%% Initialize manager
manager.initialize();
manager.setTrigger(DAQ_flag); % Enable/Disable the microscope trigger

%% Start the manager (sets timer, etc)
manager.start();

%% Main presentation loop
for r = 1:n_repeats
	for p = 1:n_presentations
		% Choose one, not all 3...
		manager.present('stimtype', data); % where "stitype" can be "image", "grating", "movie" with the appropriate data included
	end
end

%% Clean up
manager.finish();