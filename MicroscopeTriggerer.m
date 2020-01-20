classdef MicroscopeTriggerer < handle
    % Simple class for handling all microscope related stuff, triggering scopes depending on which one, etc...
    
    % Written 2020Jan20 KS
    % Updated
    
    properties
        microscope % Which microscope the stimuli is being used on
        s % A quick pointer to the daq object that's created
        enabled % Flag for whether or not it's enabled, if not, it just does nothing
        
        device = 'Dev1' % Default arguments, almost never change...
        pin = 'ao0'
    end
    
    methods
        function obj = MicroscopeTriggerer(microscope, enabled)
            if nargin == 0 || isempty(microscope)
                microscope = questdlg('Which microscope are you using?',...
                    'Microscope', '2P', 'widefield', '2P');
            end
            obj.microscope = microscope;
            obj.enabled = enabled;
        end
        
        function initialize(obj, stimulus_duration)
            if obj.enabled
                % Widefield requires a little extra work because of the weirdness of it...
                obj.s = daq.createSession('ni');
                obj.s.addAnalogOutputChannel(obj.device, obj.pin, 'Voltage');
                obj.s.outputSingleScan(0);
                
                if strcmp(obj.microscope, 'widefield')
                    if nargin < 2 || isempty(stimulus_duration)
                        temp = inputdlg('Input your stimulus duration (in seconds): ');
                        stimulus_duration = str2double(temp{1});
                    end
                    %generating a square wave for trigger
                    oneCycle = cat(2,repmat(4,[1 75]), repmat(0, [1 25])); %75samples (ms) on, 25 samples(ms) off
                    totalDur_samples = stimulus_duration * obj.s.Rate;
                    numCycles = ceil(totalDur_samples / length(oneCycle));
                    outputMat = repmat(oneCycle,[1 numCycles + 50]);
                    
                    obj.s.queueOutputData(outputMat'); % Prepares the stimulus gathering for the camera
                end
            end
        end
        
        function sendTrigger(obj)
            if obj.enabled
                switch obj.microscope
                    case '2P'
                        obj.s.outputSingleScan(5);
                    case 'widefield'
                        obj.s.startBackground();
                end
            end
        end
        
        function cleanUp(obj)
            if obj.enabled
                switch obj.microscope
                    case '2P'
                        obj.s.outputSingleScan(0);
                    case 'widefield'
                        obj.s.stop();
                        obj.s.outputSingleScan(0);
                end
            end
        end
    end
end
