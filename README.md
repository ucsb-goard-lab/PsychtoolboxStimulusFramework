# Psychtoolbox Stimulus Framework
## Purpose
A simple set of classes to make developing and using psychtoolbox more user-friendly and less prone to stupid errors. Each portion of the usual stimulus code is separated into its own class, so there is less chance for crosstalk or confusion.  
  
Importantly, the code also enforces a strict structure for both timing and presentation order of stimuli. This is primarily in order to allow for easy design of simple stimuli, at the expense of flexibility for more complex stimuli.

## Contents
### FrameworkObject
A simple class just for handling all our objects and to provide them with some basic methods.  

### StimulusManager
This is the main class that users will interact with. The Manager contains handles to all other classes, and will properly route commands to the appropriate class.  

### StimulusRenderer
This class handles all the stimulus rendering and setting up of psychtoolbox. The Renderer works hand in hand with a Renderable, which contains specific stimulus information to be presented.

### Renderable
Renderables are the stimuli themselves. These classes hold the stimulus parameters and include a "draw" method to correctly draw when called on by the Renderer. For example, the "Image" class, contains an image and display properties of that image. For each image you want to use in your stimulus, create another instance of the "Image" class.

### MicroscopeTriggerer
An easy wrapper for converting code from "two-photon" to "widefield" code by simply allowing you to change which microscope system you're on. Sets up the DAQ based on some defaults and triggers appropriately.

### StimDataLogger
A class for storing variables from your stimulus in one easy place for export later on. 

### StimulusTimer
A class that keeps track of time and can be used easily from the other classes.  

## Usage
The stimulus framework is designed to work specifically with the visual analysis framework. In order to ensure compatibility, you must follow these rules:  
  
### Definitions
__pre_time__: gray screen that precedes each _on_time_  
__on_time__: a single distinct stimulus _presentation_  
__post_time__: gray screen following each _on_time_   

__presentation__: [_pre_time_ + _on_time_ + _post_time]  
__repeat__: [_presentation_ * n_presentations]  
  

### Creating a new stimulus class
To create a new type of stimulus, create a new subclass under Renderables. Your class must have at least two methods: initialize and draw. Initialize determines all the pre-processing required to generate a PTB texture which is then stored in the class. Draw then draws that texture as necessary (or in some cases, uses other PTB functions like DrawDots to draw).

### Examples
Check the __ExampleScripts__ folder for both a general framework for constructing your own stimulus, or for some example stimuli.  

_Note: It's important to keep the naming of the variables (pre_time, on_time, post_time, n_presentations, and n_repeats). The program currently searches through your workspace for these specific variable names. This will be improved in the future to be more malleable._