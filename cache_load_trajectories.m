function res = cache_load_trajectories(config, path)        
    % see if we have them cached
    cache_dir = globals.CACHE_DIRECTORY;
    res = 0;
    
    id = config.hash();
    fn = fullfile(cache_dir, ['trajetories_', num2str(id), '.mat']);
    if exist(fn, 'file')            
        load(fn);
        config.set_trajectories(traj);
    else
        % have to load them
        res = config.load_data(path);
        if ~res
            return;
        end                    
        traj = config.TRAJECTORIES;
    
        % save for next time
        if ~exist(cache_dir, 'dir')
            mkdir(cache_dir);
        end

        save(fn, 'traj');
    end
    
    % see if we want to segment them
    if ~isempty(config.SUB_CONFIGURATION)        
        if config.SUB_CONFIGURATION{3} > 0
            % see if cached            
            id = hash_combine(config.hash(), hash_value(config.SUB_CONFIGURATION));             
            fn = fullfile(cache_dir, ['segments_', num2str(id), '.mat']);
            if exist(fn, 'file')            
                load(fn);                
            else                        
                seg = config.TRAJECTORIES.partition( ...
                    config.SUB_CONFIGURATION{3}, ...
                    config.SUB_CONFIGURATION{4}, ...
                    config.SUB_CONFIGURATION{5:end} ...
                );        
                save(fn, 'seg');
            end
            config.set_trajectories(seg);
        end
    end
        
    res = 1;    
end