% This stimulus is similar to the natural movies stimulus we currently use

clear;
close all;
sca;

pre_time = 2;
on_time = 15; 
post_time = 2;

n_repeats = 30;
n_presentations = 1;

DAQ_flag = 0;


% Load movie
movie = importdata('C:\Users\sit\Dropbox\StimulusPresentation\NaturalScenes\MovieDatabase\TouchofEvil\TouchofEvil.mat');

manager = StimulusManager();
manager.setScreenID(1);

manager.initialize();
manager.setTrigger(DAQ_flag);

manager.start();

for r = 1:n_repeats
	for p = 1:n_presentations
		manager.present('movie', movie)
	end
end
