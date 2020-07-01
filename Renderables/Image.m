classdef Image < Renderable
    properties
        image
        texture
        stretch_flag

        draw_rect
    end

    methods
        function obj = Image(img, stretch_flag)
            if nargin < 2 || isempty(stretch_flag)
                stretch_flag = false;
            end
            obj.image = img;
            obj.stretch_flag = stretch_flag;
        end

        function initialize(obj)

            if ~obj.stretch_flag
                ratio = size(obj.image, 1) / size(obj.image, 2);
                short_side = min([obj.getRect(3), obj.getRect(4)]);
                mid_point = max([obj.getRect(3), obj.getRect(4)]) / 2;
                long_side = round(ratio * short_side);
                obj.draw_rect = [mid_point - long_side/2, obj.getRect(2), mid_point + long_side/2, obj.getRect(4)];
            else
                obj.draw_rect = obj.getRect();
            end

            obj.image = obj.imgChecker(obj.image);
            obj.texture = Screen('MakeTexture', obj.getWindow(), obj.image); % probably should add some checks here to make sure it works properly... 
        end

        function draw(obj, t_close)

            vbl = Screen('Flip', obj.getWindow());
            while obj.getTime() < t_close
                Screen('DrawTexture', obj.getWindow(), obj.texture, [], obj.draw_rect);
                Screen('DrawingFinished', obj.getWindow());
                vbl = Screen('Flip', obj.getWindow(), vbl + 0.5 * obj.getIFI());
            end
        end

        function img = imgChecker(obj, img)
            if ~isa(img, 'double') && ~isa(img, 'uint8')
                img = double(img);
            end
        end
    end
end
