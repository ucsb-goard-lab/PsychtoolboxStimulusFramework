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

    properties (Access = public)
    	s % A quick pointer to the daq object that's created
        device = 'Dev1' % Default arguments, almost never change...
        pin = 'ao0'
    end
    
    methods
        function obj = MicroscopeTriggerer(enabled)
            obj.enabled = enabled;
        end
        
        function initialize(obj, stimulus_duration)
	end
       	
        function start(obj)
        end
        
        function finish(obj)
        end

        function setTrigger(obj, enable)
            obj.enabled = enable;
        end
    end
end
