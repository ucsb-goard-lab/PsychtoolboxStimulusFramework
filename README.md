# Psychtoolbox Stimulus Framework
## Purpose
A simple set of classes to make developing and using psychtoolbox more user-friendly and less prone to stupid errors. Each portion of the usual stimulus code is separated into its own class, so there is less chance for crosstalk or confusion.

## Contents
### Manager
This is the main class that users will interact with. The Manager contains handles to all other classes, and will properly route commands to the appropriate class.  

### StimulusRenderer
This class handles all the stimulus rendering and setting up of psychtoolbox. Contains a couple built-in methods that should cover 90% of the stimuli we use: drawBlank, drawDriftingGrating, drawImage, and drawMovie. Also hold all the timing information.

### MicroscopeTriggerer
An easy wrapper for converting code from "two-photon" to "widefield" code by simply allowing you to change which microscope system you're on. Sets up the DAQ based on some defaults and triggers appropriately.

### StimDataLogger
A class for storing variables from your stimulus in one easy place for export later on. 

### MicroscopeTimer
A class that keeps track of time and can be used easily from the other classes.  

## Usage
The stimulus framework is designed to work specifically with the visual analysis framework. In order to ensure compatibility, you must follow these rules:  
  
### Definitions
__pre_time__: gray screen that precedes each _on_time_  
__on_time__: a single distinct stimulus _presentation_  
__post_time__: gray screen following each _on_time_   

__presentation__: [_pre_time_ + _on_time_ + _post_time]  
__repeat__: [_presentation_ * n_presentations]  

### Example stimulus construction 1
Goal: Present different drifting gratings to test orientation tuning in primary visual cortex
```matlab
pre_time = 2; % seconds preceding stimulus on
on_time = 4; % seconds stimulus presentation
post_time = 2; % seconds following stimulus on

n_presentations = 12; % 12 different presentations (each time is a different orientation in this case)
n_repeats = 10; % 10 repeats of each group of presentations

% see example_stim_1.m for full code
```
Stimulus schematic:  


### Example stimulus construction 2
Goal: Present multiple repeats of a movie to gauge the reliability of neurons in primary visual cortex
```matlab
pre_time = 2; % seconds preceding a movie
on_time = 15; % seconds you want the movie to play for
post_time = 2; % seconds following movie

n_presentations = 1; % Present the movie once
n_repeats = 10; % 10 repeats of each group

% see example_stim_2.m for full code
```
Stimulus schematic:
