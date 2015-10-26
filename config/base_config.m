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
        
        DATA_REPRESENTATION_COORD = data_representation('Coordinates', base_config.DATA_TYPE_COORDINATES, 'trajectory_points');
        DATA_REPRESENTATION_SPEED = data_representation('Speed', base_config.DATA_TYPE_SCALAR_FIELD, 'trajectory_speed');        
        
        DEFAULT_DATA_REPRESENTATIONS = [ ...
            base_config.DATA_REPRESENTATION_COORD, ...
            base_config.DATA_REPRESENTATION_SPEED ...
        ];                                            
    end
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        DESCRIPTION = '';  
        TAGS = [];
        DATA_REPRESENTATIONS = [];
        FEATURES = [];  
        SEGMENTATION_FUNCTION = [];
        OUTPUT_DIR = 'unknown.mat';
        SAVED_FILE_NAME = [];
        TRAJECTORIES = [];
        TAG_TYPES = [];
        
        DEFAULT_FEATURE_SET = [];
        CLUSTERING_FEATURE_SET = [];
        
        SESSIONS = 1;  
        TRIALS_PER_SESSION = 1; 
        TRIALS = 1;
        TRIAL_TYPES = 1;
        GROUPS = 1;        
        GROUPS_DESCRIPTION = {'Unknown'};        
        TRIAL_TYPES_DESCRIPTION = {'Unknown'};
    end
    
    properties(GetAccess = 'private', SetAccess = 'private')
        properties_ = containers.Map('KeyType', 'char', 'ValueType', 'any');
    end
    
    methods
        function inst = base_config(desc, varargin) 
           [extr_tags, clus_feat_set, feat_set, extr_data_repr, extr_features, ...
            inst.SESSIONS, inst.TRIALS_PER_SESSION,  ...
            inst.TRIAL_TYPES_DESCRIPTION, inst.TRIAL_TYPES, inst.GROUPS_DESCRIPTION, ...
            inst.SEGMENTATION_FUNCTION, inst.TAG_TYPES, prop] = process_options(varargin, ...
                'Tags', [], ...
                'ClusteringFeatureset', config_place_avoidance.CLUSTERING_FEATURE_SET_APAT, ...
                'FeatureSet', config_place_avoidance.FEATURE_SET_APAT, ...    
                'DataRepresentations', [], ...
                'Features', [], ...                                
                'Sessions', 1, ...
                'TrialsPerSession', 1, ...
                'TrialTypesDescription', {'Unknown'}, ...
                'TrialType', 1, ...
                'GroupsDescription', {'Unknown'}, ...
                'SegmentationFunction', [], ...
                'TagTypesDescription', {'Behavioural class', 'Trajectory attribute'},  ...
                'Properties', {} ...
            );
                        
            inst.DESCRIPTION = desc;          
            inst.TAGS = [base_config.DEFAULT_TAGS, extr_tags];
            inst.DATA_REPRESENTATIONS = [base_config.DEFAULT_DATA_REPRESENTATIONS, extr_data_repr];
            inst.FEATURES = [base_config.DEFAULT_FEATURES, extr_features];
            inst.CLUSTERING_FEATURE_SET = clus_feat_set;            
            inst.DEFAULT_FEATURE_SET = feat_set;                        
            inst.TRIALS = sum(inst.TRIALS_PER_SESSION);
            inst.GROUPS = length(inst.GROUPS_DESCRIPTION);  
            
            % set other properties - have to come in pairs
            assert(mod(length(prop), 2) == 0);
            for i = 1:2:length(prop)
                inst.set_property(prop{i}, prop{i + 1});
            end            
       end
        
        function val = hash_value(inst)
           val = hash_value(inst.DESCRIPTION);
        end   
        
        function set_trajectories(inst, traj)
            inst.TRAJECTORIES = traj;
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
        
        function set_description(inst, desc)
            inst.USER_DESCRIPTION = desc;
            inst.SAVED_FILE_NAME = [desc '.mat'];
        end
            
        function save_to_file(inst)
            fn = fullfile(inst.OUTPUT_DIR, inst.SAVED_FILE_NAME);
            SAVED_CONFIGURATION = inst;
            save(fn, 'SAVED_CONFIGURATION');
            clear('SAVED_CONFIGURATION');
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
                inst.FEATURES(i).set_parameters(inst);
            end
            if ~isempty(inst.SEGMENTATION_FUNCTION)
                inst.SEGMENTATION_FUNCTION.set_parameters(inst);
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
    end
    
    methods(Static)
        function inst = load_from_file(fn)
            load(fn);
            if ~exist('SAVED_CONFIGURATION')
                error('Invalid file');
            end
            inst = SAVED_CONFIGURATION;
            clear('SAVED_CONFIGURATION');
        end
    end
end