classdef Microscope < handle
    properties
        microscope
        source
        is_direct_record
        save_directory
        filename
        
        saver
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
            obj.microscope.FramesPerTrigger = 1;
            obj.source = getselectedsource(obj.microscope); % this gets the hardware info from the microscope so we can change stuff
            set(obj.microscope, 'TriggerRepeat', Inf); % -1 because it's additional triggers on top of the first one
            
            %% initialize parallel pool if not exist
            p = gcp('nocreate');
            if isempty(p)
                p = parpool(4); % important that the processor has 8 logical (usualy 4 physical) cores to work with, or else we won't be able to write fast enough
            end
            
        end
        
        function setExposureTime(obj, exposure_time)
            obj.source.E2ExposureTime = exposure_time * 1000; % the reduction in frame time is necessary or else we won't hit the target framerate with teh trigger (skip frames)
        end
        
        function preview(obj)
            triggerconfig(obj.microscope, 'immediate', 'none', 'none'); % necessary or else no live preview sadly
            preview(obj.microscope);
        end
        
        function setSaveParameters(obj, save_dir, filename)
            obj.setSaveDirectory(save_dir);
            obj.setFilename(filename);
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
                filename = inputdlg("Please enter a filename for saving (without extension):");
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
            % stoppreview(obj.microscope);
            triggerconfig(obj.microscope, 'hardware', '', 'ExternExposureStart');
            obj.microscope.FramesAcquiredFcnCount = 2;
            obj.microscope.FramesAcquiredFcn = {@Microscope.saveImageData, sprintf('%s%s%s', obj.save_directory, filesep, obj.filename)};
            start(obj.microscope)
        end
        
        function write(obj)
            % calculate num_frames
            n_frames = min(obj.microscope.FramesAvailable, 1); % single frame writing seems to be the way to go...
            try
                out = getdata(obj.microscope, n_frames); % currently only a single image taken, but can we try to take chunks?
            catch ME
                if strcmp(ME.identifier, 'imaq:getdata:timeout')
                    return
                else
                    rethrow(ME); % rethrow if it's an actual error
                end
            end
            for ii = 1:n_frames
                obj.saver.setTag(obj.tags);
                obj.saver.write(out(:, :, ii));
                obj.saver.writeDirectory();
            end
        end
        
        function stop(obj)
            stop(obj.microscope);
        end
        
        function finish(obj)
            obj.stop();
            delete(obj.microscope);
            obj.saver.close();
        end
        
        function abort(obj)
            stop(obj.microscope)
            obj.saver.close();
        end
        function delete(obj)
            delete(obj.microscope); % ensure that the microscope has been deleted so it doen't jam up matlab
            % obj.saver.close();
        end
    end
    
    
    methods (Static)
        function saveImageData(obj, ~, fileName)
            % saveImageData saves acquired images to TIFF files.
            %
            % saveImageData is a callback function fired by a videoinput
            % FramesAvailable event. It uses PARFEVAL (Parallel Computing Toolbox) to
            % save images to disk without blocking MATLAB execution.
            
            [data, ~, metadata] = getdata(obj, obj.FramesAcquiredFcnCount);
            
            f = parfeval(@Microscope.writeTIFF, 0, ...
                data, numel(metadata), fileName, metadata(1).FrameNumber);
            
            % Store future handles in UserData for checking error messages later.
            % obj.UserData = [obj.UserData; f];
            
        end
        function writeTIFF(data, n , fileName, relativeFrame)
            % writeTIFF saves acquired images to separate TIFF files.
            %
            % writeTIFF is called by saveImageData.
            
            for ii = 1:n
                fullFileName = [fileName sprintf('_%06d.tif', relativeFrame + ii - 1)];
                imwrite(data(:,:,:,ii), fullFileName, 'tiff');
            end
            
            
        end
    end
end

