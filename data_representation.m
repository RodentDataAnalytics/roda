classdef data_representation < handle
    %TAG Groups together some commmon attributes of trajectories
    properties(GetAccess = 'public', SetAccess = 'protected')
        % short and long descriptions
        data_type = 0;     
    end
    
    properties(GetAccess = 'private', SetAccess = 'private')
        hash_ = [];
        f_ = [];
    end
    
    methods
        %% constructor        
        function inst = data_representation(desc, data_type, func, rarg, prop, varargin)   
            inst.data_type = data_type;
            if nargin < 4
                rarg = 1;
            end
            if nargin < 5
                prop = {};
            end
            inst.f_ = function_wrapper(desc, func, rarg, prop, varargin{:});
        end
        
        function val = hash_value(inst)
           val = inst.f_.hash_value;            
        end
        
        function set_parameters(inst, config)
            inst.f_.set_parameters(config);            
        end
                    
        function ret = apply(inst, traj, varargin)                
            ret = inst.f_.apply1(traj, varargin{:});
        end
    end
end