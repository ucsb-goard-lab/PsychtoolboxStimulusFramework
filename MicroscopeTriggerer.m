classdef MicroscopeTriggerer < FrameworkObject
	%{
    Controls the DAQ and allows microscope triggering. If the microscope is the 2P, it doesn't need the length of the stimulus because the 2P only sends specific triggers. On the other hand, the widefield needs the length because it triggers each frame.
    
    Written 20Jan2020 KS
    Updated 14Feb2020 KS Updated for new integration with the framework objects
    %}
    
    properties
        microscope % Which microscope the stimuli is being used on
        enabled % Flag for whether or not it's enabled, if not, it just does nothing
    end

    properties (Access = protected)
    	s % A quick pointer to the daq object that's created
        device = 'Dev1' % Default arguments, almost never change...
        pin = 'ao0'
    end
    
    methods
        function obj = MicroscopeTriggerer(microscope, enabled)
            if nargin == 0 || isempty(microscope)
                microscope = questdlg('Which microscope are you using?',...
                    'Microscope', '2P', 'widefield', '2P');
            end

            if nargin < 2 || isempty(enabled)
                enabled = 0;
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
        
        function start(obj)
            if obj.enabled
                switch obj.microscope
                    case '2P'
                        obj.s.outputSingleScan(5);
                    case 'widefield'
                        obj.s.startBackground();
                end
            end
        end
        
        function finish(obj)
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

        function setTrigger(obj, enable)
            obj.enabled = enable;
        end
    end
end
