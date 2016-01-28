classdef trajectory_segmentation_composition
     
    properties(GetAccess = 'private', SetAccess = 'private')
        description = [];
        function1 = [];
        function2 = [];
    end

    methods
        function inst = trajectory_segmentation_composition(f1, f2)
            inst.description = [f1.description ' | ' f2.description];
            inst.function1 = f1;
            inst.function2 = f2;
        end
        
        % first segmentation

        function val = hash_value(inst)
           val = hash_combine( inst.function1.hash_value, inst.function2.hash_value);               
        end
        
        function set_parameters(inst, config)
            inst.function1.set_parameters(config);
            inst.function2.set_parameters(config);            
        end
                    
        function segs = apply(inst, varargin)                
            % we always need to call apply1() since the trajectory has to
            % be provided
            assert('not supported');
            segs = [];
        end
        
        %% This calls the function using 1 argument + N arguments that are appended
        %% after the parameters set in the function object
        function segs = apply1(inst, traj, varargin)                
            segs1 = inst.function1.apply1(traj, varargin{:});
            segs = [];
            for i = 1:segs1.count
                if isempty(segs)
                    segs = inst.function2.apply1(segs1.items(i), varargin{:});
                else
                    segs = segs.append(inst.function2.apply1(segs1.items(i), varargin{:}));
                end
            end
        end
    end
end