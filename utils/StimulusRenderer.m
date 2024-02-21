classdef StimulusRenderer < FrameworkObject
    %{
    A simple wrapper that covers most of the Psychtoolbox functions we use in the Goard Lab to make developing new stimuli much easier. Easy to develop on to add more functions. Make sure for each "draw" function added here, a "present" function is included in the manager.. We should probably change this later so that we don't need to add so many methods, and just have one method in the manager that can call different renderer methods. Potentially, we could use a name-pair argument pass in, coupled with varargin, but I'm not sure that's clean...

    % Written 20Jan2020 KS
    % Updated 14Feb2020
    %}
    properties
        screen_id = 1; % Which display to present things on
        background = 0.5; % Default background brightness
    end
    
    properties (Access = protected)
        timer_handle % handle to the timer
        window % pointer to psychtoolbox's window
        ifi % inter-frame-interval for timing
        rect % rectangle on the window to draw to

        renderable
    end
    
    methods % all these methods need to take tclose as the input argument
        function obj = StimulusRenderer(renderable)
            obj.renderable = renderable;
        end
        
        function initialize(obj, manager, screen_id)
            %% Initializes psychtoolbox and gets everything set up properly...
            if nargin < 3 || isempty(screen_id)
                screen_id = obj.screen_id;
            end

            obj.timer_handle = manager.timer;
            
            % Skip sync test
            Screen('Preference','SkipSyncTests',1);
            Screen('Preference','VisualDebugLevel',0);
            Screen('Preference','SuppressAllWarnings',1);
            
            % Open window
            obj.window = Screen('OpenWindow', screen_id, obj.background*255);
            % Calculate patch location
            [screenXpixels, screenYpixels] = Screen('WindowSize', obj.window);
            obj.rect = [0 0 screenXpixels screenYpixels];
            
            disp('Measuring ifi, please wait...')
            % Retrieve video redraw interval for later control of our animation timing:
            try
                obj.ifi = Screen('GetFlipInterval', obj.window, 100);
            catch
                disp('This was likely due to a failure to measure the ifi... run it again, and don''t touch anything')
                obj.ifi = 1/60;
            end
            topPriorityLevel = MaxPriority(obj.window);
            Priority(topPriorityLevel);

            
            % These two from the DrawBLank function, but i assume we need it here..
            % Make sure this is running on OpenGL Psychtoolbox:
            AssertOpenGL;
            
            % Make sure the GLSL shading language is supported:
            AssertGLSL;

            % Inject information to the renderable
            for r = obj.renderable
                r.setRenderer(obj);
            end
        end
        
        function setScreenID(obj, screen_id)
            % For changing screen ID
            obj.screen_id = screen_id;
        end
        
        function finish(obj)
            % Simple function just for cleaning up after we're done
            Priority(0);
            sca;
            close all;
        end

        function drawBlank(obj, t_close)
            % From MG Matlab function "DrawBlank.m"
            
            % Draw a blank rectabgle with user-defined brightness
            Screen('FillRect', obj.window, obj.background*255, obj.rect);
            
            % Update some grating animation parameters:
            vbl = Screen('Flip', obj.window);
            
            while obj.getTime() < t_close

                Screen('FillRect', obj.window, obj.background*255, obj.rect);
                Screen('DrawingFinished', obj.window);

                % Show it at next retrace:
                vbl = Screen('Flip', obj.window, vbl + 0.5 * obj.ifi);
            end
            return
        end

        function drawStimulus(obj, idx, t_close)
            obj.renderable(idx).draw(t_close);
        end
    
        % Getters
        function out = getScreenID(obj)
            out = obj.screen_id;
        end

        function out = getIFI(obj)
            out = obj.ifi;
        end

        function out = getWindow(obj)
            out = obj.window;
        end

        function out = getRect(obj, vtx)
            if nargin < 2 || isempty(vtx)
                vtx = [1:4];
            end
            out = obj.rect(vtx);
        end

        function time = getTime(obj)
            time = obj.timer_handle.get();
        end
    end   
end