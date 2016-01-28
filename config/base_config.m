classdef base_config < handle
    properties(Constant)        
        %%%
        %%% Default tags
        %%%
        TAG_TYPE_ALL = 0;
        TAG_TYPE_BEHAVIOUR_CLASS = 1;
        TAG_TYPE_TRAJECTORY_ATTRIBUTE = 2;               
        
        UNDEFINED_TAG = tag('UD', 'undefined', base_config.TAG_TYPE_BEHAVIOUR_CLASS);
               
        DEFAULT_TAGS = [ base_config.UNDEFINED_TAG ];                   
        
        %%%
        %%% Default features
        %%%        
        FEATURE_LENGTH = trajectory_feature('L', 'Path length', 'trajectory_length');
        FEATURE_LATENCY = trajectory_feature('Lat', 'Latency', 'trajectory_latency');
        FEATURE_AVERAGE_SPEED = trajectory_feature('v_m', 'Average speed', 'trajectory_average_speed');
        FEATURE_BOUNDARY_CENTRE_X = trajectory_feature('x', 'Boundary centre x', 'trajectory_boundaries', 1);
        FEATURE_BOUNDARY_CENTRE_Y = trajectory_feature('y', 'Boundary centre y', 'trajectory_boundaries', 2);
        FEATURE_BOUNDARY_RADIUS_MIN = trajectory_feature('r_a', 'Boundary min radius', 'trajectory_boundaries', 3);
        FEATURE_BOUNDARY_RADIUS_MAX = trajectory_feature('r_b', 'Boundary max radius', 'trajectory_boundaries', 4);
        FEATURE_BOUNDARY_INCLINATION = trajectory_feature('inc', 'Boundary inclination', 'trajectory_boundaries', 5);
        FEATURE_BOUNDARY_ECCENTRICITY = trajectory_feature('ecc', 'Boundary eccentricity', 'trajectory_eccentricity', 1);
        FEATURE_MEDIAN_RADIUS = trajectory_feature('r_12', 'Median radius', 'trajectory_radius', 1, {'CENTRE_X', 'CENTRE_Y', 'ARENA_R'});
        FEATURE_IQR_RADIUS = trajectory_feature('r_iqr', 'IQR radius', 'trajectory_radius', 2, {'CENTRE_X', 'CENTRE_Y', 'ARENA_R'});
        FEATURE_FOCUS = trajectory_feature('f', 'Focus', 'trajectory_focus', 1, {'CENTRE_X', 'CENTRE_Y'});
        FEATURE_MEAN_ANGLE = trajectory_feature('ang0', 'Mean angle', 'trajectory_mean_angle', 1, {'CENTRE_X', 'CENTRE_Y'});
        FEATURE_DENSITY = trajectory_feature('rho', 'Density', 'trajectory_density', 1, {'CENTRE_X', 'CENTRE_Y'});
        FEATURE_ANGULAR_DISPERSION = trajectory_feature('d_ang', 'Angular dispersion', 'trajectory_angular_dispersion');
        FEATURE_VARIANCE_SPEED = trajectory_feature('v_var', 'Speed variance', 'trajectory_speed_variance');
        
        DEFAULT_FEATURES = [ ...
            base_config.FEATURE_LENGTH, ...
            base_config.FEATURE_LATENCY, ...
            base_config.FEATURE_AVERAGE_SPEED, ...
            base_config.FEATURE_BOUNDARY_CENTRE_X, ...
            base_config.FEATURE_BOUNDARY_CENTRE_Y, ...
            base_config.FEATURE_BOUNDARY_RADIUS_MIN, ...
            base_config.FEATURE_BOUNDARY_RADIUS_MAX, ...
            base_config.FEATURE_BOUNDARY_INCLINATION, ...
            base_config.FEATURE_BOUNDARY_ECCENTRICITY, ...
            base_config.FEATURE_MEDIAN_RADIUS, ...
            base_config.FEATURE_IQR_RADIUS, ...
            base_config.FEATURE_FOCUS, ...
            base_config.FEATURE_MEAN_ANGLE, ...
            base_config.FEATURE_DENSITY, ...
            base_config.FEATURE_ANGULAR_DISPERSION, ...
            base_config.FEATURE_VARIANCE_SPEED ...
        ];
                
        %%%
        %%% Default data representations
        %%%        
        DATA_TYPE_COORDINATES = 1;
        DATA_TYPE_SCALAR_FIELD = 2;
        DATA_TYPE_VECTOR_FIELD = 3;
        DATA_TYPE_EVENTS = 4;
        DATA_TYPE_FUNCTION = 5;
        
        DATA_REPRESENTATION_COORD = data_representation('Coordinates', base_config.DATA_TYPE_COORDINATES, 'trajectory_points');
        DATA_REPRESENTATION_SPEED = data_representation('Speed', base_config.DATA_TYPE_SCALAR_FIELD, 'trajectory_speed');        
        DATA_REPRESENTATION_SPEED_PROFILE = data_representation('Speed profile', base_config.DATA_TYPE_FUNCTION, 'trajectory_speed_profile');        
        
        DEFAULT_DATA_REPRESENTATIONS = [ ...
            base_config.DATA_REPRESENTATION_COORD, ...
            base_config.DATA_REPRESENTATION_SPEED, ...
            base_config.DATA_REPRESENTATION_SPEED_PROFILE ...
        ];
    
        %%%
        %%% Standard segmentations
        %%%
        SEGMENTATION_CONSTANT_LENGTH = function_wrapper('Constant length', 'trajectory_segmentation_constant_len', 1, ...
            {'SEGMENT_LENGTH', 'SEGMENT_OVERLAP'});
        
        SEGMENTATION_CONSTANT_TIME = function_wrapper('Constant time', 'trajectory_segmentation_constant_time', 1, ...
            {'SEGMENT_TIME', 'SEGMENT_TIME_OVERLAP'});
    end
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        DESCRIPTION = '';  
        TAGS = [];
        DATA_REPRESENTATIONS = [];
        FEATURES = [];  
        SEGMENTATION_FUNCTION = [];
        CLUSTERING_FEATURES_SEGMENTATION = [];
        OUTPUT_DIR = 'unknown.mat';
        SAVED_FILE_NAME = [];
        SAVED_TAGS_FILE_NAME = [];
        TRAJECTORIES = [];
        TAG_TYPES = [];
        
        DISPLAY_FEATURES = [];
        CLUSTERING_FEATURES = [];
        SELECTED_FEATURES = [];
        
        SESSIONS = 1;  
        TRIALS_PER_SESSION = 1; 
        TRIALS = 1;
        TRIAL_TYPES = 1;
        GROUPS = 1;        
        GROUPS_DESCRIPTION = {'Unknown'};        
        TRIAL_TYPES_DESCRIPTION = {'Unknown'};
        TAG_TYPES_DESCRIPTION = [];
        TAGGED_DATA = [];        
    end
    
    properties(GetAccess = 'private', SetAccess = 'private')
        properties_ = containers.Map('KeyType', 'char', 'ValueType', 'any');
        clust_feat_vals_ = [];
        prev_npca_ = -1;
        sub_segments_ = [];
    end
    
    methods
        function inst = base_config(desc, varargin) 
           [extr_tags, clus_feat_set, feat_set, extr_data_repr, extr_features, ...
            inst.SESSIONS, inst.TRIALS_PER_SESSION,  ...
            inst.TRIAL_TYPES_DESCRIPTION, inst.TRIAL_TYPES, inst.GROUPS_DESCRIPTION, ...
            inst.SEGMENTATION_FUNCTION, inst.TAG_TYPES_DESCRIPTION, ...
            inst.CLUSTERING_FEATURES_SEGMENTATION, prop] = process_options(varargin, ...
                'Tags', [], ...
                'ClusteringFeatureSet', [], ...
                'FeatureSet', [], ...    
                'DataRepresentations', [], ...
                'Features', [], ...                                
                'Sessions', 1, ...
                'TrialsPerSession', 1, ...
                'TrialTypesDescription', {'Unknown'}, ...
                'TrialType', 1, ...
                'GroupsDescription', {'Unknown'}, ...
                'SegmentationFunction', [], ...
                'TagTypesDescription', {'Behavioural class', 'Trajectory attribute'},  ...
                'SubSegmentationFunction', [], ...                    
                'Properties', {} ...
            );
                        
            inst.DESCRIPTION = desc;          
            inst.TAGS = [base_config.DEFAULT_TAGS, extr_tags];
            inst.DATA_REPRESENTATIONS = [base_config.DEFAULT_DATA_REPRESENTATIONS, extr_data_repr];
            inst.FEATURES = [base_config.DEFAULT_FEATURES, extr_features];
            inst.CLUSTERING_FEATURES = clus_feat_set;            
            inst.DISPLAY_FEATURES = feat_set;                        
            inst.TRIALS = sum(inst.TRIALS_PER_SESSION);
            inst.GROUPS = length(inst.GROUPS_DESCRIPTION);  
            
            % set other properties - have to come in pairs
            assert(mod(length(prop), 2) == 0);
            for i = 1:2:length(prop)
                inst.set_property(prop{i}, prop{i + 1});
            end            
            
             % combine display + clustering features           
            inst.SELECTED_FEATURES = [inst.CLUSTERING_FEATURES, setdiff(inst.DISPLAY_FEATURES, inst.CLUSTERING_FEATURES)];                        
            
            inst.SAVED_FILE_NAME = [inst.DESCRIPTION '.mat'];            
       end
        
        function val = hash_value(inst)
           val = hash_value(inst.DESCRIPTION);
        end   
        
        function set_trajectories(inst, traj)
            inst.TRAJECTORIES = traj;
            
            % define one set of tags - we could in theory have multiple            
            inst.SAVED_TAGS_FILE_NAME = {[inst.DESCRIPTION '_tags01.csv']};
            inst.TAGGED_DATA = tags_list('Default', inst.TRAJECTORIES);
        end
                
        function set_output_directory(inst, new_dir)
            inst.OUTPUT_DIR = new_dir;
            if ~exist(inst.OUTPUT_DIR, 'dir')
                mkdir(inst.OUTPUT_DIR);
            end                        
        end                
        
        function set_subconfig(inst, conf)
            inst.SUB_CONFIGURATION = conf;
        end             
            
        function save_to_file(inst, varargin)
            tags_only = process_options(varargin, 'TagsOnly', 0);
            
            % save the tags
            for i = 1:length(inst.SAVED_TAGS_FILE_NAME)
                fn = fullfile(inst.OUTPUT_DIR, inst.SAVED_TAGS_FILE_NAME{i});
                inst.TAGGED_DATA(i).save_to_file(fn);
            end
            % here we effectively save the tag data twice - well, not a big
            % deal really
            if ~tags_only
                fn = fullfile(inst.OUTPUT_DIR, inst.SAVED_FILE_NAME);
                SAVED_CONFIGURATION = inst;
                save(fn, 'SAVED_CONFIGURATION');
                clear('SAVED_CONFIGURATION');
            end
        end                
        
        function set_tags(inst, tags)
            inst.TAGS = tags;
        end
        
        function set_property(inst, name, val)
            inst.properties_(name) = val;            
        end
        
        function val = property(inst, name, def)
            if inst.has_property(name)
                val = inst.properties_(name);
            else
                if nargin > 2
                    val = def;
                else                    
                    error(['Property ' name ' is not defined']);
                end
            end
        end
        
        function ret = has_property(inst, name)
            ret = isKey(inst.properties_, name);
        end
        
        % this has to be called after initializing properties needed for
        % the features and other functions
        function post_init(inst)
            for i = 1:length(inst.FEATURES)
                inst.FEATURES(i).set_parameters(inst);
            end
            for i = 1:length(inst.DATA_REPRESENTATIONS)
                inst.DATA_REPRESENTATIONS(i).set_parameters(inst);
            end
            if ~isempty(inst.SEGMENTATION_FUNCTION)
                inst.SEGMENTATION_FUNCTION.set_parameters(inst);
            end
            if ~isempty(inst.CLUSTERING_FEATURES_SEGMENTATION)
                inst.CLUSTERING_FEATURES_SEGMENTATION.set_parameters(inst);
            end
        end
        
        function ses = trial_to_session(inst, trial)
            ses = 0;
            tot = 0;
            for i = 1:length(inst.TRIALS_PER_SESSION)
                tot = tot + inst.TRIALS_PER_SESSION(i);
                if trial <= tot
                    ses = i;
                    break;
                end
            end
        end

        function load_trajectories_cached(inst, path, varargin)        
            % see if we have them cached
            cache_dir = globals.CACHE_DIRECTORY;
            
            % find a unique id for the directory contents by hashing all the file
            % names / directories within it        
            id = 0;
            files = dir(path);
            for fi = 1:length(files)
                id = hash_combine(id, hash_value(files(fi).name));
            end
            
            fn = fullfile(cache_dir, ['trajetories_', num2str(id), '.mat']);
            if exist(fn, 'file')            
                load(fn);
                inst.set_trajectories(traj);
            else
                % have to load them
                res = inst.load_data(path, varargin{:});
                if res == 1
                    traj = inst.TRAJECTORIES;                
                    % save for next time        
                    save(fn, 'traj');
                else
                    error('Error loading trajectories');
                end
            end
            
            % see if we want to segment them
            if ~isempty(inst.SEGMENTATION_FUNCTION)        
                nmin = inst.property('SEGMENTATION_MINIMUM_SEGMENTS', 2);
                nmax = inst.property('SEGMENTATION_MAXIMUM_SEGMENTS', 0);                
                inst.set_trajectories( inst.TRAJECTORIES.partition( inst.SEGMENTATION_FUNCTION, nmin, ...
                    'MaxSegments', nmax, varargin{:} ) );
            end            
        end
        
        function tags = tags_of_type(inst, tag_type)
            if tag_type == base_config.TAG_TYPE_ALL
                tags = inst.TAGS;
            else
                tags = [];
                for i = 1:length(inst.TAGS)
                    if inst.TAGS(i).type == tag_type
                        tags = [tags, inst.TAGS(i)];
                    end
                end
            end                           
        end
        
        function vals = clustering_feature_values(inst)
            npca = inst.property('NUMBER_FEATURES_PCA', 0);
                
            if isempty(inst.clust_feat_vals_) || inst.prev_npca_ ~= npca
                % check if we want to sub-segment the segments to compute
                % multiple values for each feature               
                if ~isempty(inst.CLUSTERING_FEATURES_SEGMENTATION)
                    if isempty(inst.sub_segments_)
                        nmin = inst.property('SUB_SEGMENTATION_MINIMUM_SEGMENTS', 2);
                        nmax = inst.property('SUB_SEGMENTATION_MAXIMUM_SEGMENTS', 0);                
                
                        inst.sub_segments_ = inst.TRAJECTORIES.partition(inst.CLUSTERING_FEATURES_SEGMENTATION, nmin, ...
                            'MaxSegments', nmax);                                                
                    end
                    % use the sub-segments
                    traj = inst.sub_segments_;
                else
                    % use the original segments
                    traj = inst.TRAJECTORIES;
                end
                
                if npca > 0 && isempty(inst.sub_segments_)
                    inst.clust_feat_vals_ = traj.compute_features_pca(inst.CLUSTERING_FEATURES, npca);
                else
                    inst.clust_feat_vals_ = traj.compute_features(inst.CLUSTERING_FEATURES);
                end
                inst.prev_npca_ = npca;
                
                if ~isempty(inst.sub_segments_)
                    % combine the feature values of sub-segments for the same segments
                    part = inst.sub_segments_.partitions;
                    nmax = max(part);
                    nfeat = size(inst.clust_feat_vals_, 2);
                    comb_values = zeros(inst.TRAJECTORIES.count, nmax*nfeat);
                    
                    i = 1;
                    n = 0;
                    iseg = 1;
                    while i <= inst.sub_segments_.count
                        n = n + 1;
                        if n > part(iseg)
                            n = 0;
                            iseg = iseg + 1;
                            continue;
                        end
                        comb_values(iseg, (n - 1)*nfeat + 1 : n*nfeat) = inst.clust_feat_vals_(i, :);
                        i = i + 1;
                    end                                        
                    inst.clust_feat_vals_ = comb_values;
                end                
                
            end
            
            if npca > 0
                coeff = pca(inst.clust_feat_vals_);                
                inst.clust_feat_vals_ = inst.clust_feat_vals_*coeff(:, 1:npca);
            end
            
            vals = inst.clust_feat_vals_;
        end
    end
    
    methods(Static)
        function inst = load_from_file(fn)
            load(fn);
            if ~exist('SAVED_CONFIGURATION', 'var')
                error('Invalid file');
            end
            inst = SAVED_CONFIGURATION;
            clear('SAVED_CONFIGURATION');
            
            % see if we have saved tag files -> these might be newer since
            % they are saved more often
            for i = 1:length(inst.SAVED_TAGS_FILE_NAME)
                fn = fullfile(inst.OUTPUT_DIR, inst.SAVED_TAGS_FILE_NAME{i});                    
                if exist(fn, 'file')
                    inst.TAGGED_DATA(i).load_from_file(fn);
                end
            end
        end
    end
end