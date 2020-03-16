function reset()
	clear;
	clc;
	close all;

	sca;
	s = daq.createSession('ni');
	s.addAnalogOutputChannel('Dev1', 'ao0', 'Voltage')
	s.outputSingleScan(0);

	clear;
	clc;
	close all;

	disp('Reset.')
end