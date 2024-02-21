classdef StimDataLogger < dynamicprops & FrameworkObject
    %{
     The role of this class is to collect and export stimulus related information (repeats, on time, etc) for future analyses
     in a clean way. Heavily based on the "DataObject" class, which has since been deprecated. The DataObject class allows us to dynamically add properties to the class for easy export
     
     Written: 20Jan2020 KS
     Updated: 14Feb2020 KS Updated for new framework
    %}

    properties (Access = protected)
        dynamicproperties % A property to refer to the other properties, for internal use only
        save_directory % Where to save all the data...
        suffix % to append to the stimulus data file
        
        % These are all necessary stimulus parmaeters for the automated analysis
    end

    properties (Access = public)
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
                        evalin('base',[varargin{ii} ';']); % this is an initial check to see if the variable exists
                        p(ii) = obj.addprop(varargin{ii}); % adds them as dynamic properties
                        obj.(varargin{ii}) = evalin('base',[varargin{ii} ';']); % Fills in those properties with the values
                    else
                        p(ii) = obj.addprop(inputname(ii));
                        obj.(inputname(ii)) = varargin{ii};
                    end
                end
                obj.dynamicproperties = p; % here we assign the private dynamicproperties property, mainly for controlling these data
            end
        end
        
        function initialize(obj, save_dir, suffix)
            if nargin < 2 || isempty(save_dir)
                fprintf('Choose a save directory...\n')
                save_dir = uigetdir();
            end
            
            if nargin < 3 || isempty(suffix)
                temp = inputdlg('Please enter a suffix for you recording:');
                obj.suffix = temp{1};
            else
                obj.suffix = suffix;
            end
            
            obj.setSaveDirectory(save_dir);
        end

        function finish(obj)
            obj.saveData()
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
                        obj.(varargin{ii}) = evalin('base',[varargin{ii} ';']); % Fills in those properties with the values
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

        function saveData(obj)
            if isempty(obj.save_directory)
                obj.save_directory = uigetdir();
            end
            
            props = properties(obj);
            stimdata = struct();
            for ii = 1:size(props,1)
                stimdata.(props{ii}) = obj.(props{ii});
            end

            save_name = [obj.save_directory '\Stimdata_', date, '_', obj.suffix];
            save(save_name, 'stimdata');

            save_name_no_backslash = save_name;
            save_name_no_backslash(strfind(save_name_no_backslash, '\')) = '/';
            obj.msgPrinter(sprintf('Successfully saved stimulus data info as: "%s"', save_name_no_backslash));
        end
    end
end