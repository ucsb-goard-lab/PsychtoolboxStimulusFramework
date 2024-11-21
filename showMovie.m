% This stimulus is similar to the natural movies stimulus we currently use

clear;
close all;
sca;

pre_time = 1;
on_time = 30;
post_time = 2;

n_repeats = 15;
n_presentations = 1;

DAQ_flag = 1;

% Load movie
movie = importdata('TouchofEvil.mat');

stimulus = Movie(movie);

manager = StimulusManager(stimulus);
manager.setScreenID(1);

manager.initialize();
manager.setTrigger(DAQ_flag);

manager.start();

for r = 1:n_repeats
	for p = 1:n_presentations
		manager.present()
	end
end

manager.finish();
