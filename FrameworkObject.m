classdef FrameworkObject < handle
	properties
	end
	methods
		function obj = FrameworkObject()
		end

		function initialize(obj)
		end

		function start(obj)
		end

		function finish(obj)
		end

		function msgPrinter(obj, str)
			fprintf([str, '\n']);
		end
	end
end