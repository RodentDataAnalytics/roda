classdef configurations < handle
    %CONFIGURATIONS Loads available experimental configurations    
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        descriptions = {};
        class_names = {};
        sub_configurations = {};
    end
    
    methods(Static)
        % Singleton class - provides access to the object instance
        function inst = instance()
            persistent single_inst;
            if isempty(single_inst) || ~isvalid(single_inst)
                single_inst = configurations;
            end
            inst = single_inst;
        end
    end
   
    methods
        function config = get_configuration(inst, idx, sub_idx, desc)
            %f = [inst.class_names{idx} '(''' desc ''', ' num2str(sub_idx) ')']
            %config = eval([inst.class_names{idx} '(''' desc ''', ' num2str(sub_idx) ')']);
            % HACK TODO: matlab crashing with the code above, need to
            % investigate
            switch idx
                case 1
                    config = config_place_avoidance_silver(desc, sub_idx);
                case 2
                    config = config_mwm_stress(desc, sub_idx);                
                case 3
                    config = config_place_avoidance_silver2(desc, sub_idx);
                otherwise
                    error('Need to update the list of configurations');
            end
        end
    end
    
    methods(Access = 'private')
        function inst = configurations()
            % make sure that the WEKA library is initialized
            addpath(fullfile(fileparts(mfilename('fullpath')),'/extern/weka'));
            weka_init;
            
            % add other needed folders to the path
            addpath(fullfile(fileparts(mfilename('fullpath')),'/features'));
            addpath(fullfile(fileparts(mfilename('fullpath')),'/data_representation'));
            
            config_root = fullfile(fileparts(mfilename('fullpath')),'/config'); 
            addpath(config_root);

            % find all available configurations
            files = dir(fullfile(config_root, '*'));               
            for fi = 1:length(files)
                if files(fi).isdir
                    % add directory to the search folder list
                    addpath(fullfile(config_root, files(fi).name));                    
                end
            end            
            
            inst.class_names = {};
            inst.descriptions = {};
            inst.sub_configurations = {};
            
            % hard coded configurations
            conf_pat = config_place_avoidance_silver.CONFIGURATIONS;
            conf_pat2 = config_place_avoidance_silver2.CONFIGURATIONS;            
            conf_mwm = config_mwm_stress.CONFIGURATIONS;
            
            templates = { ...
                 'Place avoidance task (silver)', 'config_place_avoidance_silver', ...
                    arrayfun( @(idx) conf_pat{idx}{1}, ...
                            1:length(conf_pat), 'UniformOutput', 0), ...
                 'Morris water maze (peripubertal stress)', 'config_mwm_stress', ...
                    arrayfun( @(idx) conf_mwm{idx}{1}, ...
                            1:length(conf_mwm), 'UniformOutput', 0), ...
                 'Place avoidance task (silver) [new]', 'config_place_avoidance_silver2', ...
                    arrayfun( @(idx) conf_pat2{idx}{1}, ...
                            1:length(conf_pat2), 'UniformOutput', 0) ...
                 
            };
                %, 'Place avoidance task (memantine)', config_place_avoidance_mem ...
                     
            inst.descriptions = arrayfun( @(idx) templates{idx}, 1:3:length(templates), 'UniformOutput', 0);                                       
            inst.class_names = arrayfun( @(idx) templates{idx}, 2:3:length(templates), 'UniformOutput', 0);                                       
            inst.sub_configurations = arrayfun( @(idx) templates{idx}, 3:3:length(templates), 'UniformOutput', 0);                                       
        end
    end    
end