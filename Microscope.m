classdef Microscope < handle
	properties
		microscope
		source
		is_direct_record
		save_directory
		filename

		tif_writer
		tags
	end

	methods
		function obj = Microscope()
			% initialize the microscope and stuff
			% 			try
			obj.microscope = videoinput('pcocameraadaptor_r2020b'); % make sure
			% 			catch
			% 				error('Couldn''t create microscope, you probably are missing the Image Acquisition toolbox or the pco camera adapter');
			% 			end


			% Set some defaults
			obj.setFrameRate(20); % default 20Hz
			obj.microscope.FramesPerTrigger = 1;
			obj.source = getselectedsource(obj.microscope); % this gets the hardware info from the microscope so we can change stuff
		end

		function setFrameRate(obj, frame_rate)
			frame_time = (1/frame_rate) * 1000000; % converting to frame time in usec
			obj.source.E2ExposureTime = frame_time * 0.80; % the reduction in frame time is necessary or else we won't hit the target framerate with teh trigger (skip frames)
		end

		function preview(obj)
			triggerconfig(obj.microscope, 'immediate', 'none', 'none'); % necessary or else no live preview sadly
			preview(obj.microscope);
		end

		function setMaxFrames(obj, n_frames)
			set(obj.microscope, 'TriggerRepeat', n_frames - 1); % -1 because it's additional triggers on top of the first one
		end

		function setSaveParameters(obj, save_dir, filename)
			obj.setSaveDirectory(save_dir);
			obj.setFilename(filename);
			% initialize the tif library
			obj.tif_writer = Tiff(sprintf('%s/%s.tif', obj.save_directory, obj.filename), 'w8');
			% set the tagstruct
            obj.generateTags();
			fprintf("Files will be saved as '%s%s%s.tif'.\n", obj.save_directory, filesep, obj.filename);
		end	

		function generateTags(obj)
			roi_dims = obj.microscope.ROIPosition;
			obj.tags.ImageLength = roi_dims(4); 
			obj.tags.ImageWidth = roi_dims(3);
			obj.tags.Photometric = Tiff.Photometric.MinIsBlack;
			obj.tags.BitsPerSample = 16;
			obj.tags.SamplesPerPixel = 1;
			obj.tags.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky; 
			obj.tags.Software = 'MATLAB'; 
		end

		function setSaveDirectory(obj, save_dir)
			if nargin < 2 || isempty(save_dir)
				save_dir = uigetdir();
			end
			% in case it's a partial path, get the full path heer
			s = what(save_dir);
			if isempty(s)
				error("Cannot find the specified directory.")
				return
			end
			obj.save_directory = s.path;
		end

		function setFilename(obj, filename)
			if nargin < 2 || isempty(filename)
				filename = inputdlg("Please enter a filename for saving (without extension):")
			end
			obj.filename = filename;
		end

		function defineROI(obj)
			% get a single frame
			snap = getsnapshot(obj.microscope);

			% display it
			f = figure; 
			ax = gca;
			title("Select your ROI and double click when finished:")
			imagesc(snap)
			axis image
			axis off
			colormap gray

			roi = drawrectangle(ax);
			obj.microscope.ROIPosition = round(customWait(roi)); % get rounded position
			close(f);
			obj.preview(); % recall to update ROI
			fprintf("ROI updated.\n");

			function pos = customWait(hROI)

				% Listen for mouse clicks on the ROI
				l = addlistener(hROI,'ROIClicked',@clickCallback);

				% Block program execution
				uiwait;

				% Remove listener
				delete(l);

				% Return the current position
				pos = hROI.Position;

			end
			function clickCallback(~,evt)

				if strcmp(evt.SelectionType,'double')
					uiresume;
				end

			end
		end

		function resetROI(obj)
			obj.microscope.ROIPosition = [0, 0, 2048, 2048];
			obj.preview();
			fprintf('ROI reset.\n');
		end

		function start(obj)                
 			stoppreview(obj.microscope); % cancel preview
			triggerconfig(obj.microscope, 'hardware', '', 'ExternExposureStart');
			start(obj.microscope);	
			fprintf('Waiting for trigger...\n')
			while obj.microscope.FramesAvailable < 1
				% wait until we have some frames before starting to
			end
			idx = 1;
			while obj.microscope.FramesAvailable > 0 || strcmp(obj.microscope.Running, 'on')
				if mod(idx, 10) == 0
					fprintf('Writing frame %d\n', idx)
					drawnow();
				end
				obj.write(); % will need error handlinng 
				idx = idx + 1;
			end
		end 

		function write(obj)
			try
			out = getdata(obj.microscope, 1); % currently only a single image taken, but can we try to take chunks?
			catch ME
				if strcmp(ME.identifier, 'imag:getdata:timeout')
					return
				else
					rethrow(ME); % rethrow if it's an actual error
				end
			end
			obj.tif_writer.setTag(obj.tags);
			obj.tif_writer.write(out);
			obj.tif_writer.writeDirectory();
		end

		function stop(obj)
			stop(obj.microscope);
		end

		function finish(obj)
			obj.stop();
			delete(obj.microscope);
			obj.tif_writer.close();
		end

		function abort(obj)
			stop(obj.microscope)
			obj.tif_writer.close();
		end
		function delete(obj)
			delete(obj.microscope); % ensure that the microscope has been deleted so it doen't jam up matlab
			obj.tif_writer.close();
		end
	end
end

