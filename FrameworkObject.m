classdef FrameworkObject < handle
	%{
	A simple wrapper just for all the objects. This will be used later to easily call methods on all objects through a for loop intsead of manually calling each one
	
	Written 14Feb2020 KS
	Updated 
	%}

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