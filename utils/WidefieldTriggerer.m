classdef WidefieldTriggerer < MicroscopeTriggerer
	properties (Constant)
		FREQUENCY = 20; % 12Hz means in one second we get 10 pulses of blue and 2 pulses of violet
	end

	properties
		illumination % string defining the illumination style {'both', 'blue', 'violet'}
	end

	methods
		function obj = WidefieldTriggerer(enabled, illumination)
			if nargin < 1 || isempty(enabled)
				enabled = false;
			end
			if nargin < 2 || isempty(illumination)
				illumination = 'both';
			end
			obj = obj@MicroscopeTriggerer(enabled);
			obj.microscope = 'Widefield';
			obj.illumination = illumination;
		end

		function initialize(obj, stimulus_duration)
			% probably better to pass it in and prepare, right?
			if obj.enabled
			obj.s = daq('ni');

			blue_trigger = obj.s.addoutput('Dev1', 'ao0', 'Voltage');
			violet_trigger = obj.s.addoutput('Dev1', 'ao1', 'Voltage');
			microscope_trigger = obj.s.addoutput('Dev1', 'port0\line0', 'Digital'); % routed through user defined signal (jump the pins)
			trigger_waveforms = obj.generateLEDTriggers();
			microscope_waveform = obj.generateMicroscopeTrigger();
			obj.s.preload(repmat([trigger_waveforms', microscope_waveform'], stimulus_duration, 1)) % number of seconds
			end
		end

		function start(obj)
			if obj.enabled
				obj.s.start();
			end
		end

		function finish(obj)
			if obj.enabled
                disp('Still running...')
                if obj.s.Running
                    waitfor(obj.s, 'Running')
                end
                disp('done')
				obj.abort();
			end
        end
        
        function abort(obj)
            if obj.enabled
                obj.s.stop();
                obj.s.flush();
                obj.s.write([0, 0, 0]);
            end
        end
    end
    
	methods (Access = protected)

		function microscope_waveform = generateMicroscopeTrigger(obj)
			duty = 10;
			t = 0:1/obj.s.Rate:1;
			microscope_waveform = rescale(square(2 * pi * obj.FREQUENCY * t, duty));
			microscope_waveform(end) = [];
		end

		function trigger_waveforms = generateLEDTriggers(obj)
			offset = 0.05; % offset from the LED and frame trigger to reduce fluctuations on LED on/off
			t = 0:1/obj.s.Rate:1; % 1 second of trigger
			duty = 50/2 * (1 + 5 * offset);
			blue_waveform = 5 * rescale(square(2 * pi * (obj.FREQUENCY/2) * t - ((1 - offset) * 2 * pi), duty));
			violet_waveform = 5 * rescale(square(2 * pi * (obj.FREQUENCY/2) * t - ((0.50 - offset) * 2 * pi), duty));	
			blue_waveform(end) = [];
			violet_waveform(end) = []; 
			switch obj.illumination
				case 'blue'
					trigger_waveforms = cat(1, blue_waveform, zeros(size(blue_waveform)));
				case 'violet'
					trigger_waveforms = cat(1, zeros(size(violet_waveform)), violet_waveform);
				case 'both'
					trigger_waveforms = cat(1, blue_waveform, violet_waveform);
			end
		end
	end
end

