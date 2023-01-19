%{  
Widefield microscope aquisition

Do not close the preview window. There are no terminal outputs during
aquisition, but the preview window will swtich from "waiting for start" to
"waiting for trigger 100" when it waits for the trigger of the 100th frame.
Just the text at the bottom of the
Widefield trigger should be in the 'USER 1' BNC port of stimulus computer
DAQ. In the DAQ IO block, USER1 should be connected to P0.0
%}

%% Start microscope
m = Microscope;
m.setExposureTime(100); % ms
m.preview();

%% Define ROI
m.defineROI();

%% Set save path
% if you don't run this, it'll just save in whatever folder you're currently in
selpath = uigetdir('F:/','Select save directory.');

selName = inputdlg('Select file name.');

m.setSaveParameters(selpath, selName{1});
%%
m.start();

%%
m.stop();
