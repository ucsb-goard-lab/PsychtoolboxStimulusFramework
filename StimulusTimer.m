classdef StimulusTimer < FrameworkObject
	properties
		on_time
		post_time
		pre_time

		n_presentations
		n_repeats

        t_start % initial starting time, used to calculate other times
        t_close_matrix 
    end

    methods
    	function obj = StimulusTimer()
    		obj.extractValues();
    	end

    	function initialize(obj)
    		obj.msgPrinter(sprintf('Stimulus duration : %d seconds', obj.getStimulusDuration()));
    		obj.t_close_matrix = obj.calculateTCloses();
    	end

    	function out = getStimulusDuration(obj)
    		out = ((obj.pre_time + obj.on_time + obj.post_time) * obj.n_presentations) * obj.n_repeats;
    	end

    	function start(obj)
            % This should be run immediately before starting the stimulus, for accurate timing
            obj.t_start = GetSecs;
        end

        function finish(obj)
        	obj.msgPrinter('Total stimulus duration: %s seconds', obj.get());
        end

		function extractValues(obj) % Don't kill me MATLAB gods
			% Hacky way of acessing outside variables, but it works
			vars = evalin('base', 'who');
			props = properties(obj);
			for p = props'
				for v = vars'
					if strcmp(p, v)
						obj.(p{1}) = evalin('base', v{1});
					end
				end
			end
		end

		function out = get(obj)
            % Getting time for both internal and external uses
            out = GetSecs - obj.t_start;
        end

        function out = calculatePreClose(obj, presentation, repeat)
        	out = (repeat - 1) * ((obj.pre_time + obj.on_time + obj.post_time) * obj.n_presentations) + ...
        	(presentation - 1) * (obj.pre_time + obj.on_time + obj.post_time) + obj.pre_time;
        end

        function out = calculateStimClose(obj, presentation, repeat)
        	out = (repeat - 1) * ((obj.pre_time + obj.on_time + obj.post_time) * obj.n_presentations) + ...
        	(presentation - 1) * (obj.pre_time + obj.on_time + obj.post_time) + obj.pre_time + obj.on_time;
        end

        function out = calculatePostClose(obj, presentation, repeat)
        	out = (repeat - 1) * ((obj.pre_time + obj.on_time + obj.post_time) * obj.n_presentations) + ...
        	(presentation - 1) * (obj.pre_time + obj.on_time + obj.post_time) + obj.pre_time + obj.on_time  + obj.post_time;
        end

        function out = calculateTCloses(obj)
        	out = zeros(obj.n_repeats, obj.n_presentations, 3);
        	for r = 1:obj.n_repeats
        		for p = 1:obj.n_presentations
        			out(r, p, 1) = obj.calculatePreClose(p, r);
        			out(r, p, 2) = obj.calculateStimClose(p, r);
        			out(r, p, 3) = obj.calculatePostClose(p, r);
        		end
        	end
        end

        function out = getTClose(obj);
        	out = obj.t_close_matrix;
        end
    end
end