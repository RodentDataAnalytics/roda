classdef function_wrapper < handle
    %TAG Groups together some commmon attributes of trajectories
    properties(GetAccess = 'public', SetAccess = 'protected')
        description = [];
        % name of the function
        function_name = [];
        % function used to calculate the value
        function_handle = [];      
        % return value number to use
        return_arg = 1;
        % name of configurable parameters
        parameters = {};
        % values of the configurable parameters
        parameter_values = {};
        % other fixed arguments
        other_args = {};            
    end
    
    properties(GetAccess = 'private', SetAccess = 'private')
        hash_ = [];
        args_ = [];
    end
    
    methods
        %% constructor        
        function inst = function_wrapper(desc, func, rarg, prop, varargin)   
            inst.description = desc;
            inst.function_name = func;
            if func(1) == '@'
                inst.function_handle = eval(func);
            else
                inst.function_handle = str2func(func);
            end
            if nargin > 2
                inst.return_arg  = rarg;
            end                
            if nargin > 3            
                inst.parameters = prop;                
            end
            if nargin > 4
                inst.other_args = varargin;
            end
        end
        
        function val = hash_value(inst)
           if isempty(inst.hash_)
               % if this assertion fires the parameters have not been set
               % yet 
               assert(length(inst.parameters) == length(inst.parameter_values));
               inst.hash_ = hash_value({inst.function_name, inst.return_arg, inst.parameter_values{:}, inst.other_args{:}});
           end
           val = inst.hash_;
        end
        
        function set_parameters(inst, config)
            inst.parameter_values = {};
            for i = 1:length(inst.parameters)
                inst.parameter_values = [inst.parameter_values, config.property(inst.parameters{i})];
            end
        end
                    
        function ret = apply(inst, varargin)                
            % check if parameters set have not been set              
            assert(length(inst.parameters) == length(inst.parameter_values));         
                
            switch inst.return_arg
                case 1
                    ret = inst.function_handle(varargin{:}, inst.parameter_values{:}, inst.other_args{:});
                case 2
                    [~, ret] = inst.function_handle(varargin{:}, inst.parameter_values{:}, inst.other_args{:});
                case 3
                    [~, ~, ret] = inst.function_handle(varargin{:}, inst.parameter_values{:}, inst.other_args{:});
                case 4
                    [~, ~, ~, ret] = inst.function_handle(varargin{:}, inst.parameter_values{:}, inst.other_args{:});
                case 5
                    [~, ~, ~, ~, ret] = inst.function_handle(varargin{:}, inst.parameter_values{:}, inst.other_args{:});
                otherwise
                    error('Too many return arguments');
            end            
        end
        
        %% This calls the function using 1 argument + N arguments that are appended
        %% after the parameters set in the function object
        function ret = apply1(inst, arg, varargin)                
            % check if parameters set have not been set              
            assert(length(inst.parameters) == length(inst.parameter_values));         
                
            switch inst.return_arg
                case 1
                    ret = inst.function_handle(arg, inst.parameter_values{:}, varargin{:}, inst.other_args{:});
                case 2
                    [~, ret] = inst.function_handle(arg, inst.parameter_values{:}, varargin{:}, inst.other_args{:});
                case 3
                    [~, ~, ret] = inst.function_handle(arg, inst.parameter_values{:}, varargin{:}, inst.other_args{:});
                case 4
                    [~, ~, ~, ret] = inst.function_handle(arg, inst.parameter_values{:}, varargin{:}, inst.other_args{:});
                case 5
                    [~, ~, ~, ~, ret] = inst.function_handle(arg, inst.parameter_values{:}, varargin{:}, inst.other_args{:});
                otherwise
                    error('Too many return arguments');
            end            
        end
    end
end