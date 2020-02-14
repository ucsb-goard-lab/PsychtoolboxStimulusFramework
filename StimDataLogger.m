classdef StimDataLogger < dynamicprops & FrameworkObject
%     The role of this class is to collect and export stimulus related information (repeats, on time, etc) for future analyses
%     in a clean way. Heavily based on the "DataObject" class
%     
%     Written: 2020Jan20 KS
%     Updated:


properties (Access = protected)
        dynamicproperties % A property to refer to the other properties, for internal use only
        save_directory % Where to save all the data...


        blank_time
        pre_time
        post_time
        on_time
        n_presentations
        n_repeats
    end
    
    methods
        function obj = StimDataLogger(varargin)
            if nargin == 0
            else
                for ii = 1:nargin % Loops through the input arguments
                    if ischar(varargin{1})
                        evalin('caller',[varargin{ii} ';']); % this is an initial check to see if the variable exists
                        p(ii) = obj.addprop(varargin{ii}); % adds them as dynamic properties
                        obj.(varargin{ii}) = evalin('caller',[varargin{ii} ';']); % Fills in those properties with the values
                    else
                        p(ii) = obj.addprop(inputname(ii));
                        obj.(inputname(ii)) = varargin{ii};
                    end
                end
                obj.dynamicproperties = p; % here we assign the private dynamicproperties property, mainly for controlling these data
            end
        end
        
        function initialize(obj, save_dir)
            if nargin < 2 || isempty(save_dir)
                fprintf('Choose a save directory...\n')
                save_dir = uigetdir();
            end
            obj.setSaveDirectory(save_dir);
        end

        function finish(obj, suffix)
            if nargin < 2 || isempty(suffix)
                temp = inputdlg('Please enter a suffix for you recording:');
                suffix = temp{1};
            end
            obj.saveData(suffix)
        end

        function add(obj,varargin) % In order to add more data to our object
            try
                for ii = 1:nargin-1 % because there will always be "obj" there
                    % Overwrite the property
                    
                    if ischar(varargin{ii})
                        if ismember(varargin{ii},properties(obj))
                            obj.remove(varargin{ii});
                            obj.msgPrinter(sprintf('Overwriting: %s',varargin{ii}));
                        end
                        dynprops(ii) = obj.addprop(varargin{ii}); % adds them as dynamic properties
                        obj.(varargin{ii}) = evalin('caller',[varargin{ii} ';']); % Fills in those properties with the values
                    else
                        if ismember(inputname(ii+1),properties(obj))
                            obj.remove(inputname(ii+1));
                            obj.msgPrinter(sprintf('Overwriting: %s',inputname(ii+1)));
                        end
                        dynprops(ii) = obj.addprop(inputname(ii+1));
                        obj.(inputname(ii+1)) = varargin{ii};
                    end
                    obj.dynamicproperties = [obj.dynamicproperties dynprops]; % extending the thing
                    
                end
            catch
                obj.msgPrinter('Unknown error, data not added');
            end
        end

        function setSaveDirectory(obj, save_dir)
            obj.save_directory = save_dir;
        end

        function saveData(obj, suffix)
            if isempty(obj.save_directory)
                obj.save_directory = uigetdir();
            end
            
            props = properties(obj);
            stimdata = struct();
            for ii = 1:size(props,1)
                stimdata.(props{ii}) = obj.(props{ii});
            end

            save_name = [obj.save_directory '\Stimdata_', date, '_', suffix];
            save(save_name, 'stimdata');

            save_name_no_backslash = save_name;
            save_name_no_backslash(strfind(save_name_no_backslash, '\')) = '/';
            obj.msgPrinter(sprintf('Successfully saved stimulus data info as: "%s"', save_name_no_backslash));
        end
    end
end