classdef configurations < handle
    %CONFIGURATIONS Loads available experimental configurations    
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        items = {};
        names = {};
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
            
            inst.items = {};
            inst.names = {};
            
            if isdeployed
                % hard coded configurations
                inst.items = {config_place_avoidance_silver, config_place_avoidance_mem};
                inst.names = arrayfun( @(idx) inst.items{idx}.DESCRIPTION, 1:length(inst.items), 'UniformOutput', 0);
            else                            
                for fi = 1:length(files)
                    if ~files(fi).isdir                
                        [~, fn] = fileparts(fullfile(config_root, files(fi).name));
                        new_inst = eval([fn '()']);
                        fprintf('\nFound configuration ''%s''', new_inst.DESCRIPTION);
                        inst.items = [inst.items, {new_inst}];                    
                        inst.names = [inst.names, new_inst.DESCRIPTION];
                    end
                end
            end
        end
    end    
end