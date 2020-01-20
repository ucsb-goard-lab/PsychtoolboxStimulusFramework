# Psychtoolbox Stimulus Framework
## Purpose
A simple set of classes to make developing and using psychtoolbox more user-friendly and less prone to stupid errors. Each portion of the usual stimulus code is separated into its own class, so there is less chance for crosstalk or confusion.

## Contents
### StimulusRenderer
This class handles all the stimulus rendering and setting up of psychtoolbox. Contains a couple built-in methods that should cover 90% of the stimuli we use: drawBlank, drawDriftingGrating, drawImage, and drawMovie. Also hold all the timing information.

### MicroscopeTriggerer
An easy wrapper for converting code from "two-photon" to "widefield" code by simply allowing you to change which microscope system you're on. Sets up the DAQ based on some defaults and triggers appropriately.

### StimDataLogger
A class for storing variables from your stimulus in one easy place for export later on. 

## Usage
Compare the 'PassiveDriftingGratings_example.m' code to our standard PassiveDriftingGratings code to see how to use the new framework.
