classdef TwoPhotonTriggerer < MicroscopeTriggerer
	properties
	end

	methods
		function obj = TwoPhotonTriggerer(enabled)
			obj = obj@MicroscopeTriggerer(enabled)
			obj.microscope = '2P';
		end

		function initialize(obj, device, pin)
			if nargin < 2 || isempty(device)
				device = 'Dev1';
			end

			if nargin < 3 || isempty(pin)
				pin = 'ao0'
			end
			if obj.enabled
				obj.s = daq.createSession('ni');
				obj.s.addAnalogOutputChannel(device, pin, 'Voltage');
				obj.s.outputSingleScan(0);
			end
		end

		function start(obj)
			if obj.enabled
				obj.s.outputSingleScan(5);
			end
		end

		function finish(obj)
			if obj.enabled
				obj.s.outputSingleScan(0);
			end
		end	
	end
end

