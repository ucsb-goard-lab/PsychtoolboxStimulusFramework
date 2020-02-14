% This stimulus would be akin to some kind of image database stimulus


clear;
close all;
sca;

pre_time = 2;
on_time = 1;
post_time = 2;
n_repeats = 5;
DAQ_flag = 0;


% Get your images, replace this as necessary
image_matrix = importdata('C:\Users\Goard Lab\Dropbox\CodeInBeta_Kevin\Amani Project\TextureStimuli\image_matrix.mat'); % load the image matrix
n_presentations = size(image_matrix, 3);

% Instantiate objects
manager = StimulusManager();
manager.setScreenID(1);

manager.initialize();
manager.setTrigger(DAQ_flag);

manager.start();

for r = 1:n_repeats
	for p = 1:n_presentations
		manager.presentImage(p, r, image_matrix(:, :, p));
	end
end

manager.finish();