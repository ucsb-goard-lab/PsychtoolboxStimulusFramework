classdef Movie < Renderable
    properties
        movie
        n_frames
        framerate
    end

    properties (Access = protected)
        textures
        waitframes
    end

    methods
        function obj = Movie(movie, framerate)
            if nargin < 2 || isempty(framerate)
                framerate = 30;
            end
            obj.movie = movie;
            obj.n_frames = size(obj.movie, 3); 
            obj.framerate = framerate;
        end

        function initialize(obj)
            obj.waitframes = (1 / obj.getIFI()) / obj.framerate;

            for idx = 1:obj.n_frames
                obj.textures(idx) = Screen('MakeTexture', obj.getWindow(), obj.movie(:, :, idx));
            end
        end

        function draw(obj, t_close)
            vbl =  Screen('Flip', obj.getWindow());
            frame_idx = 1;
            while obj.getTime() < t_close
                Screen('DrawTexture', obj.getWindow(), obj.textures(frame_idx), [], obj.getRect());
                Screen('DrawingFinished', obj.getWindow());
                vbl = Screen('Flip', obj.getWindow(), vbl + (obj.waitframes) * obj.getIFI());
                frame_idx = mod(frame_idx, obj.n_frames) + 1;
            end
        end
    end
end