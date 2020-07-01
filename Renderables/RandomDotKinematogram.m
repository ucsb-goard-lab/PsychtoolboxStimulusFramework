classdef RandomDotKinematogram < Renderable
    properties
        coherence
        direction

        dot_properties
        display_properties
    end

    methods
        function obj = RandomDotKinematogram(coherence, direction, size, speed, nDots, lifetime)
            if nargin < 3 || isempty(size)
                size = 10;
            end

            if nargin < 4 || isempty(speed)
                speed = 80;
            end

            if nargin < 5 || isempty(nDots)
                nDots = 200;
            end

            if nargin < 6 || isempty(lifetime)
                lifetime = 60;
            end

            obj.coherence = coherence;
            obj.direction = direction;
            obj.dot_properties.nDots = nDots;
            obj.dot_properties.speed = speed;
            obj.dot_properties.lifetime = lifetime;
            obj.dot_properties.size = size;

            obj.dot_properties.center = [0, 0];
            obj.dot_properties.color = [0, 0, 0];
        end

        function initialize(obj)
            % Initialize dot parameters
            % Randomize the direction of every dot to start
            random_directions = 0:45:315;
            obj.dot_properties.random_directions = datasample(random_directions, obj.dot_properties.nDots);

            obj.dot_properties.coherence_direction = obj.direction;
            obj.dot_properties.coherence = obj.coherence;

            is_already_direction = (obj.dot_properties.random_directions == obj.dot_properties.coherence_direction);
            coherent_dot_idx = datasample(1:obj.dot_properties.nDots,round(obj.dot_properties.coherence * obj.dot_properties.nDots), 'Replace', false);
            is_coherent = false(1, obj.dot_properties.nDots);
            is_coherent(coherent_dot_idx) = true; 

            obj.dot_properties.direction = obj.dot_properties.random_directions;
            obj.dot_properties.direction(is_coherent & ~is_already_direction) = obj.dot_properties.coherence_direction;

            % Initialize display parameters
            screen_id = obj.renderer.getScreenID(); 
            screen_info = Screen('Resolution', screen_id);
            obj.display_properties.dist = 3; % cm
            obj.display_properties.width = 14.1; % cm
            obj.display_properties.resolution = [screen_info.width, screen_info.height];
            obj.display_properties.frame_rate = Screen('NominalFrameRate', screen_id);


            obj.dot_properties.apertureSize = [obj.display_properties.resolution];
        end

        function draw(obj, t_close)

            % probably smart to split this up into several subfunctions here

            obj.dot_properties.x = (rand(1,obj.dot_properties.nDots)-.5)*obj.dot_properties.apertureSize(1) + obj.dot_properties.center(1);
            obj.dot_properties.y = (rand(1,obj.dot_properties.nDots)-.5)*obj.dot_properties.apertureSize(2) + obj.dot_properties.center(2);
            pixpos.x = obj.dot_properties.x;
            pixpos.y = obj.dot_properties.y;

            pixpos.x = pixpos.x + obj.display_properties.resolution(1)/2;
            pixpos.y = pixpos.y + obj.display_properties.resolution(2)/2;
            % dot movement
            dx = obj.dot_properties.speed*sin(obj.dot_properties.direction*pi/180)/obj.display_properties.frame_rate;
            dy = -obj.dot_properties.speed*cos(obj.dot_properties.direction*pi/180)/obj.display_properties.frame_rate;

            dx = obj.angle2pix(obj.display_properties,dx);
            dy = obj.angle2pix(obj.display_properties,dy);
            l = obj.dot_properties.center(1)-obj.dot_properties.apertureSize(1)/2;
            r = obj.dot_properties.center(1)+obj.dot_properties.apertureSize(1)/2;
            b = obj.dot_properties.center(2)-obj.dot_properties.apertureSize(2)/2;
            t = obj.dot_properties.center(2)+obj.dot_properties.apertureSize(2)/2;

            obj.dot_properties.life =    ceil(rand(1,obj.dot_properties.nDots)*obj.dot_properties.lifetime);

            while obj.renderer.getTime() < t_close
                %convert from degrees to screen pixels
                pixpos.x = obj.dot_properties.x+ obj.display_properties.resolution(1)/2;
                pixpos.y = obj.dot_properties.y+ obj.display_properties.resolution(2)/2;
                
                %Use the equation of an ellipse to determine which dots fall inside.
                %goodDots = (obj.dot_properties.x-obj.dot_properties.center(1)).^2/(obj.dot_properties.apertureSize(1)/2)^2 + ...  % circular aperture
                %    (obj.dot_properties.y-obj.dot_properties.center(2)).^2/(obj.dot_properties.apertureSize(2)/2)^2 < 1;
                
                
                % if you're using an ellipse, add pixpos.x(goodDots) and for y too
                Screen('DrawDots', obj.getWindow(), [pixpos.x; pixpos.y],  obj.dot_properties.size, obj.dot_properties.color, [0, 0], 3);
                %update the dot position
                obj.dot_properties.x = obj.dot_properties.x + dx;
                obj.dot_properties.y = obj.dot_properties.y + dy;
                
                %move the dots that are outside the aperture back one aperture
                %width.
                obj.dot_properties.x(obj.dot_properties.x<l) = obj.dot_properties.x(obj.dot_properties.x<l) + obj.dot_properties.apertureSize(1);
                obj.dot_properties.x(obj.dot_properties.x>r) = obj.dot_properties.x(obj.dot_properties.x>r) - obj.dot_properties.apertureSize(1);
                obj.dot_properties.y(obj.dot_properties.y<b) = obj.dot_properties.y(obj.dot_properties.y<b) + obj.dot_properties.apertureSize(2);
                obj.dot_properties.y(obj.dot_properties.y>t) = obj.dot_properties.y(obj.dot_properties.y>t) - obj.dot_properties.apertureSize(2);
                
                %increment the 'life' of each dot
                obj.dot_properties.life = obj.dot_properties.life+1;
                
                %find the 'dead' dots
                deadDots = mod(obj.dot_properties.life,obj.dot_properties.lifetime)==0;
                
                %replace the positions of the dead dots to a random location
                obj.dot_properties.x(deadDots) = (rand(1,sum(deadDots))-.5)*obj.dot_properties.apertureSize(1) + obj.dot_properties.center(1);
                obj.dot_properties.y(deadDots) = (rand(1,sum(deadDots))-.5)*obj.dot_properties.apertureSize(2) + obj.dot_properties.center(2);
                
                Screen('Flip', obj.getWindow());
            end
            return;
        end

        function pix = angle2pix(obj, display, ang)
            %Calculate pixel size
            pixSize = obj.display_properties.width/obj.display_properties.resolution(1);   %cm/pix

            sz = 2*obj.display_properties.dist*tan(pi*ang/(2*180));  %cm

            pix = round(sz/pixSize);   %pix

        end
    end
end