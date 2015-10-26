function cache_load_trajectories(config, path, varargin)        
    % see if we have them cached
    cache_dir = globals.CACHE_DIRECTORY;
    
    % find a unique id for the directory contents by hashing all the file
    % names / directories within it        
    id = config.hash();
    files = dir(path);
    for fi = 1:length(files)
        id = hash_combine(id, hash_value(files(fi).name));
    end
    
    fn = fullfile(cache_dir, ['trajetories_', num2str(id), '.mat']);
    if exist(fn, 'file')            
        load(fn);
        config.set_trajectories(traj);
    else
        % have to load them
        config.load_data(path, varargin{:});
        traj = config.TRAJECTORIES;
    
        % save for next time        
        save(fn, 'traj');
    end
    
    % see if we want to segment them
    if ~isempty(config.SEGMENTATION_FUNCTION)        
        % see if cached            
        id = hash_combine(config.hash, config.SEGMENTATION_FUNCTION.hash_value);             
        fn = fullfile(cache_dir, ['segments_', num2str(id), '.mat']);
        if exist(fn, 'file')            
            load(fn);                
        else                        
            seg = config.TRAJECTORIES.partition( config.SEGMENTATION_FUNCTION, varargin{:} );           
            save(fn, 'seg');
        end
        config.set_trajectories(seg);
    end            
end