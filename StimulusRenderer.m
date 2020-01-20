classdef StimulusRenderer < handle
    % A simple wrapper that covers most of the Psychtoolbox functions we use in the Goard Lab to make developing new stimuli
    % much easier...
    
    % Written 2020Jan20
    % Updated
    
    properties
        screen_id = 1; % Which display to present things on
        background = 0.5; % Default background brightness
    end
    
    properties (Access = protected)
        window % pointer to psychtoolbox's window
        ifi % inter-frame-interval for timing
        rect % rectangle on the window to draw to
        t_start % initial starting time, used to calculate other times
    end
    
    methods % all these methods need to take tclose as the input argument
        function obj = StimulusRenderer()
            % Empty
        end
        
        function initialize(obj, screen_id)
            %% Initializes psychtoolbox and gets everything set up properly...
            if nargin < 2 || isempty(screen_id)
                screen_id = obj.screen_id;
            end
            
            % Skip sync test
            Screen('Preference','SkipSyncTests',1);
            Screen('Preference','VisualDebugLevel',0);
            Screen('Preference','SuppressAllWarnings',1);
            
            % Open window
            obj.window = Screen('OpenWindow', screen_id, obj.background*255);
            % Calculate patch location
            [screenXpixels, screenYpixels] = Screen('WindowSize', obj.window);
            obj.rect = [0 0 screenXpixels screenYpixels];
            
            % Retrieve video redraw interval for later control of our animation timing:
            obj.ifi = Screen('GetFlipInterval', obj.window);
            
            % These two from the DrawBLank function, but i assume we need it here..
            % Make sure this is running on OpenGL Psychtoolbox:
            AssertOpenGL;
            
            % Make sure the GLSL shading language is supported:
            AssertGLSL;
        end
        
        function setScreenID(obj, screen_id)
            % For changing screen ID
            obj.screen_id = screen_id;
        end
        
        function startTimer(obj)
            % This should be run immediately before starting the stimulus, for accurate timing
            obj.t_start = GetSecs;
        end
        
        function cleanUp(obj)
            % Simple function just for cleaning up after we're done
            sca;
            close all;
        end
        
        function out = getTime(obj)
            % Getting time for both internal and external uses
            out = GetSecs - obj.t_start;
        end
    end
    
    methods % Drawing toolbox, expand with more as necessary
        function drawBlank(obj, t_close)
            % From MG Matlab function "DrawBlank.m"
            
            % Draw a blank rectabgle with user-defined brightness
            Screen('FillRect', obj.window, obj.background*255, obj.rect);
            
            % Update some grating animation parameters:
            vbl = Screen('Flip', obj.window);
            
            while obj.getTime() < t_close
                
                Screen('FillRect', obj.window, obj.background*255, obj.rect);
                
                % Show it at next retrace:
                vbl = Screen('Flip', obj.window, vbl + 0.5 * obj.ifi);
            end
            return
        end
        
        function drawMovie(obj, t_close, movie)
            vbl =  Screen('Flip', obj.window);
            frame_idx = 1;
            while obj.getTime() < t_close
                [imageTexture] = Screen('MakeTexture', obj.window, movie(:, :, frame_idx)); % probably should add some checks here to make sure it works properly...
                Screen('DrawTexture', obj.window, imageTexture, [], obj.rect);
                vbl = Screen('Flip', obj.window, vbl + 0.5 * obj.ifi);
                frame_idx = frame_idx + 1;
            end
        end
        
        function drawImage(obj, t_close, img)
            vbl = Screen('Flip', obj.window);
            while obj.getTime() < t_close
                [imageTexture] = Screen('MakeTexture', obj.window, img); % probably should add some checks here to make sure it works properly...
                Screen('DrawTexture', obj.window, imageTexture, [], obj.rect);
                vbl = Screen('Flip', obj.window, vbl + 0.5 * obj.ifi);
            end
            
        end
        
        function drawDriftingGrating(obj, t_close, ori, spat_freq, temp_freq, contrast, phase, patch_size)
            %% From MG function "DrawDriftingGrating.m"
            % Setting default parameters
            if nargin < 3 || isempty(ori)
                ori = 0;
            end
            
            if nargin < 4 || isempty(spat_freq)
                spat_freq = 0.004;
            end
            
            if nargin < 5 || isempty(temp_freq)
                temp_freq = 2;
            end
            
            if nargin < 6 || isempty(contrast)
                contrast = 1;
            end
            
            if nargin < 7 || isempty(phase)
                phase = 0;
            end
            
            if nargin < 8 || isempty(patch_size)
                patch_size = 1000; %pixels
            end
            
            % Calculate parameters
            amplitude = contrast/2;
            
            % Internal rotation (default = 1)
            internalRotation = 1; % Rotate grating within patch (1) or entire patch (0)
            
            if internalRotation==1
                rotateMode = kPsychUseTextureMatrixForRotation;
            elseif internalRotation==0
                rotateMode = [];
            end
            
            % Compute increment of phase shift per redraw:
            phaseincrement = (temp_freq * 360) * obj.ifi;
            
            % Build a procedural sine grating texture
            gratingtex = CreateProceduralSineGrating(obj.window, patch_size, patch_size, [0.5 0.5 0.5 0.0]);
            
            % Update some grating animation parameters:
            vbl = Screen('Flip', obj.window);
            
            while obj.getTime() < t_close
                % Increment phase by 1 degree:
                phase = phase + phaseincrement;
                
                % Draw the grating:
                Screen('DrawTexture',obj.window, gratingtex, obj.rect, obj.rect, ori, ...
                    [], [], [], [], rotateMode, [phase, spat_freq, amplitude, 0]);
                
                % Show it at next retrace:
                vbl = Screen('Flip', obj.window, vbl + 0.5 * obj.ifi);
            end
            
            return;
            
        end
    end   
end