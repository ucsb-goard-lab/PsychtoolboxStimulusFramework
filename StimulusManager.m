classdef StimulusManager < handle
	properties
		renderer
		logger
		triggerer
		timer

		t_close
	end

	methods
		function obj = StimulusManager()
			obj.logger = StimDataLogger();
			obj.timer = StimulusTimer();
			obj.triggerer = MicroscopeTriggerer();
			obj.renderer = StimulusRenderer();

		end

		function setScreenID(obj, id)
			obj.renderer.setScreenID(id);
		end

		function initialize(obj)
			% Not ideal, because i want to loop through the properties, but this will work.. for now
			obj.logger.initialize();
			obj.triggerer.initialize(obj.timer.getStimulusDuration()); % Pass into the triggerer
			obj.timer.initialize();
			obj.renderer.initialize(obj);
		end

		function start(obj)
			obj.renderer.start();
			obj.logger.start();
			obj.triggerer.start();
			obj.timer.start();

			obj.t_close = obj.timer.getTClose();
		end

		function finish(obj)
			obj.renderer.finish();			
			obj.timer.finish();
			obj.triggerer.finish();
			obj.logger.finish();
		end

		function setTrigger(obj, enable)
			obj.triggerer.setTrigger(enable);
		end

		function presentDriftingGrating(obj, presentation, repeat, ori, spat_freq, temp_freq, contrast, phase, patch_size)			
	        % pre blank
	        pre_blank_on = obj.timer.get()
	        obj.renderer.drawBlank(obj.t_close(repeat, presentation, 1)); % everything else is held in the object
	        
	        % draw grating
	        stim_on = obj.timer.get()
	        obj.renderer.drawDriftingGrating(obj.t_close(repeat, presentation, 2), ori)   

	        % post blank
	        post_blank_on = obj.timer.get()
	        obj.renderer.drawBlank(obj.t_close(repeat, presentation, 3));
	    end

	    function presentImage(obj, presentation, repeat, img)
	    	% pre blank
	    	pre_blank_on = obj.timer.get()
	        obj.renderer.drawBlank(obj.t_close(repeat, presentation, 1)); % everything else is held in the object
	        
	        % draw image
	        stim_on = obj.timer.get()
	        obj.renderer.drawImage(obj.t_close(repeat, presentation, 2), img)   

	        % post blank
	        post_blank_on = obj.timer.get()
	        obj.renderer.drawBlank(obj.t_close(repeat, presentation, 3));
	    end

	    function presentMovie(obj, presentation, repeat, movie)
	    	% pre blank
	    	pre_blank_on = obj.timer.get()
	        obj.renderer.drawBlank(obj.t_close(repeat, presentation, 1)); % everything else is held in the object
	        
	        % draw movie
	        stim_on = obj.timer.get()
	        obj.renderer.drawMovie(obj.t_close(repeat, presentation, 2), movie)   

	        % post blank
	        post_blank_on = obj.timer.get()
	        obj.renderer.drawBlank(obj.t_close(repeat, presentation, 3));
	    end
	end
end