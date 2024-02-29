% This stimulus is similar to the natural movies stimulus we currently use

clear;
close all;
sca;

pre_time = 0.5;
on_time = 30;
post_time = 0.5;

n_repeats = 30;
n_presentations = 1;

DAQ_flag = 0;

% Load movie
movie = importdata('TouchofEvil.mat');

stimulus = Movie(movie);

manager = StimulusManager(stimulus);
manager.setScreenID(3);

manager.initialize();
manager.setTrigger(DAQ_flag);

manager.start();

for r = 1:n_repeats
	for p = 1:n_presentations
		manager.present()
	end
end

manager.finish();
