classdef config_place_avoidance < base_config
    % config_mwm Global constants
    properties(Constant)                
        TRIAL_TYPE_APAT_HABITUATION = 1;
        TRIAL_TYPE_APAT_TRAINING = 2;
        TRIAL_TYPE_APAT_TEST = 3;
        TRIAL_TYPE_PAT_DARKNESS = 4;        
        
        TRIAL_TYPES_DESCRIPTION = { ...            
            'APAT/Habituation', ...
            'APAT/Training', ...
            'APAT/Testing', ...
            'PAT/Darkness', ...
        };                    
                    	
        REGULARIZE_GROUPS = 0;
        NDISCARD = 0;        
                        
        % trajectory sample status
        POINT_STATE_OUTSIDE = 0;
        POINT_STATE_ENTRANCE_LATENCY = 1;
        POINT_STATE_SHOCK = 2;
        POINT_STATE_INTERSHOCK_LATENCY = 3;
        POINT_STATE_OUTSIDE_LATENCY = 4;
        POINT_STATE_BAD = 5;
                                    
        CLUSTER_CLASS_MINIMUM_SAMPLES_P = 0.005; % 2% o
        CLUSTER_CLASS_MINIMUM_SAMPLES_EXP = 0.5;
        
        FEATURE_AVERAGE_SPEED_ARENA = base_config.FEATURE_LAST + 1;
        FEATURE_VARIANCE_SPEED_ARENA = base_config.FEATURE_LAST + 2;
        FEATURE_LENGTH_ARENA = base_config.FEATURE_LAST + 3;
        FEATURE_LOG_RADIUS = base_config.FEATURE_LAST + 4;
        FEATURE_IQR_RADIUS_ARENA = base_config.FEATURE_LAST + 5;        
        FEATURE_TIME_CENTRE = base_config. FEATURE_LAST + 6; 
        FEATURE_NUMBER_OF_SHOCKS = base_config.FEATURE_LAST + 7; 
        FEATURE_FIRST_SHOCK = base_config.FEATURE_LAST + 8; 
        FEATURE_MAX_INTER_SHOCK = base_config.FEATURE_LAST + 9; 
        FEATURE_ENTRANCES_SHOCK = base_config.FEATURE_LAST + 10; 
        FEATURE_ANGULAR_DISTANCE_SHOCK = base_config.FEATURE_LAST + 11;        
        FEATURE_SHOCK_RADIUS = base_config.FEATURE_LAST + 12;            
                                                             
        FEATURE_SET_APAT = [ base_config.FEATURE_LATENCY, ...
                             config_place_avoidance.FEATURE_AVERAGE_SPEED_ARENA, ...                                                                                                
                             config_place_avoidance.FEATURE_VARIANCE_SPEED_ARENA, ...
                             config_place_avoidance.FEATURE_TIME_CENTRE, ...
                             config_place_avoidance.FEATURE_NUMBER_OF_SHOCKS, ... 
                             config_place_avoidance.FEATURE_FIRST_SHOCK, ...
                             config_place_avoidance.FEATURE_MAX_INTER_SHOCK, ...
                             config_place_avoidance.FEATURE_ENTRANCES_SHOCK, ...
                             config_place_avoidance.FEATURE_SHOCK_RADIUS, ...
                             base_config.FEATURE_LENGTH ...                                
                           ];
                          
%         CLUSTERING_FEATURE_SET_APAT = [ base_config.FEATURE_DENSITY, ...
%                                         config_place_avoidance.FEATURE_ANGULAR_DISTANCE_SHOCK, ...
%                                         config_place_avoidance.FEATURE_LOG_RADIUS ...
%                                       ];
%         
        CLUSTERING_FEATURE_SET_APAT = [  base_config.FEATURE_DENSITY, ...
                                         config_place_avoidance.FEATURE_ANGULAR_DISTANCE_SHOCK, ...
                                         config_place_avoidance.FEATURE_LOG_RADIUS, ...
                                         config_place_avoidance.FEATURE_TIME_CENTRE, ...
                                         config_place_avoidance.FEATURE_VARIANCE_SPEED_ARENA, ...
                                         config_place_avoidance.FEATURE_FOCUS, ...
                                         config_place_avoidance.FEATURE_FOCUS, ...
                                         config_place_avoidance.FEATURE_BOUNDARY_ECCENTRICITY ...
                                       ];
         
        % plot properties
        CLASSES_COLORMAP = @jet;   
                 
        % which part of the trajectories are to be taken
        SECTION_T1 = 1; % segment until first entrance to the shock area
        SECTION_TMAX = 2; % longest segment between shocks
        SECTION_AVOID = 3; % segments between shocks
        SECTION_FULL = 0; % complete trajectories
        
        DATA_REPRESENTATION_ARENA_COORD = base_config.DATA_REPRESENTATION_LAST + 1;
        DATA_REPRESENTATION_ARENA_SPEED = base_config.DATA_REPRESENTATION_LAST + 2;
        DATA_REPRESENTATION_SHOCKS = base_config.DATA_REPRESENTATION_LAST + 3;
        DATA_REPRESENTATION_ARENA_SHOCKS = base_config.DATA_REPRESENTATION_LAST + 4;
                         
        %%%
        %%% Segmentation
        %%%
        SEGMENTATION_PLACE_AVOIDANCE = base_config.SEGMENTATION_LAST + 1;                                               
    end
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        DEFAULT_FEATURE_SET = [];
        CLUSTERING_FEATURE_SET = [];
        % centre point of arena in cm        
        CENTRE_X = [];
        CENTRE_Y = [];
        % radius of the arena
        ARENA_R = [];
        ROTATION_FREQUENCY = [];        
    end
            
    methods        
        function inst = config_place_avoidance(name, varargin)
            addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern'));
            
            [feat_set, clus_feat_set, r, x, y, rot, npca] = process_options(varargin, ...
                'FeatureSet', config_place_avoidance.FEATURE_SET_APAT, ...
                'ClusteringFeatureset', config_place_avoidance.CLUSTERING_FEATURE_SET_APAT, ...
                'ArenaRadius', 127, ...
                'CentreX', 127, ...
                'CentreY', 127, ...
                'RotationFrequency', 1, ...
                'FeaturesPCA', 4);
                        
            inst@base_config(name, ...                
               [ tag('C1', 'Class 1', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 1), ... % default tags
                 tag('C2', 'Class 2', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 2), ... 
                 tag('C3', 'Class 3', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 2), ... 
                 tag('C4', 'Class 4', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 2), ... 
                 tag('C5', 'Class 5', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 2), ... 
                 tag('C6', 'Class 6', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 2), ... 
                 tag('C7', 'Class 7', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 2), ... 
                 tag('C8', 'Class 8', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 2) ...                  
               ], ...          
               { {'Arena coordinates', base_config.DATA_TYPE_COORDINATES, 'trajectory_arena_coord' }, ...
                 {'Speed (arena)', base_config.DATA_TYPE_SCALAR_FIELD, 'trajectory_speed', 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD}, ...
                 {'Shock events', base_config.DATA_TYPE_EVENTS, 'trajectory_events', config_place_avoidance.POINT_STATE_SHOCK}, ...
                 {'Shock events (arena)', base_config.DATA_TYPE_EVENTS, 'trajectory_events', config_place_avoidance.POINT_STATE_SHOCK, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD} ...
               }, ...
               { {'Va', 'Average speed (arena)', 'trajectory_average_speed', 1, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD}, ...
                 {'Va_var', 'Log variance speed (arena)', 'feature_transform', 1, @log, 'trajectory_variance_speed', 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD}, ...
                 {'L_A', 'Length (arena)', 'trajectory_length', 1, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD}, ...
                 {'log_R12', 'Log radius  ', 'trajectory_radius', 1, 'TransformationFunc', @(x) -log(x), 'AveragingFunc', @(X) mean(X)}, ...
                 {'Riqr_A', 'IQR radius (arena)', 'trajectory_radius', 2, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD}, ...
                 {'Tc_A', 'Time centre', 'trajectory_time_within_radius', 1, 0.75*r, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD}, ...
                 {'N_s', 'Number of shocks', 'trajectory_count_events', 1, config_place_avoidance.POINT_STATE_SHOCK}, ...
                 {'T1', 'Time for first shock', 'trajectory_first_event', 1, config_place_avoidance.POINT_STATE_SHOCK}, ...
                 {'Tmax', 'Maximum time between shocks', 'trajectory_max_inter_event', 1, config_place_avoidance.POINT_STATE_SHOCK}, ...
                 {'Nent', 'Number of entrances', 'trajectory_entrances_shock', 1}, ...
                 {'D_ang', 'Angular dist. shock', 'trajectory_angular_distance_shock', 1}, ...                 
                 {'R_s', 'Shock radius', 'trajectory_event_radius', 1, config_place_avoidance.POINT_STATE_SHOCK}, ...                 
               }, ...config_place_avoidanceconfig_place_avoidance
               { {'Place avoidance', 'segmentation_place_avoidance'} } ...
            );                                   
        
            inst.NUMBER_FEATURES_PCA = npca;           
            inst.DEFAULT_FEATURE_SET = feat_set;
            inst.CLUSTERING_FEATURE_SET = clus_feat_set;            
            inst.ARENA_R = r;
            inst.CENTRE_X = x;
            inst.CENTRE_Y = y;
            inst.ROTATION_FREQUENCY = rot;
        end                
        
    end
    
    methods(Static)   
        function traj = load_trajectories(config, path, traj_group, varargin) 
        %LOAD_TRAJECTORIES Loads a set of trajectories from a given folder
            % filter: 
            % 0 == all, 
            % 1 == room coordinate system only, 
            % 2 == arena coordinate system only
            % 3 == whatever, I don't care      
            [filt_pat, id_day_mask, rev_day, force_trial, progress] = ...
                   process_options(varargin, ...
                                  'FilterPattern', '*Room*.dat', ...
                                  'IdDayMask', 'r%dd%d', ...
                                  'ReverseDayId', 0, ...
                                  'Trial', 0, ...
                                  'ProgressCallback', []);

            % contruct object to hold trajectories
            traj = trajectories([]);
            persistent track;
            if isempty(track)        
                track = 1;
            end

            if path(end) ~= '/'
                path = [path '/'];
            end
            files = dir(fullfile(path, filt_pat));
            if length(files) == 0
                return;
            end

            fprintf('Importing %d trajectories...\n', length(files));

            for j = 1:length(files)  
                if ~isempty(progress)
                    mess = sprintf('Importing trajectory %d of %d', j, length(files));
                    if progress(mess, j/length(files))
                        error('Operation cancelled');
                    end
                end
                % read trajectory from fiel
                pts = config_place_avoidance.read_trajectory(strcat(path, '/', files(j).name));
                if size(pts, 1) == 0
                    continue;
                end

                temp = sscanf(files(j).name, id_day_mask);
                if rev_day
                    id = temp(2);
                    trial = temp(1);
                else
                    id = temp(1);
                    trial = temp(2);
                end
                if force_trial > 0
                    trial = force_trial;
                end        

                % find group for this trajectory
                if length(traj_group) == 1
                    % fixed group
                    group = traj_group;
                else
                    % look up group from the list of rat ids            
                    pos = find(traj_group(:,1) == id); 
                    assert(~isempty(pos));
                    group = traj_group(pos(1),2);
                end

                traj = traj.append(trajectory(config, pts, 1, track, group, id, trial, -1, -1, 1));  
                track = track + 1;
            end                                              

            fprintf(' done.\n');
        end
                
        function pts = read_trajectory( fn, id_day_mask )
        %READ_TRAJECTORY Reads a trajectory from a file (native Ethovision format
        %supported)
            if ~exist(fn, 'file')
                error('Non-existent file');
            end

            % use a 3rd party function to read the file; matlab's csvread is a complete joke
            data = robustcsvread(fn);
            err = 0;
            pts = [];

            % HACK because of some Matlab stupidity
            for i = 1:length(data)        
                if isempty(data{i, 1})
                    data{i, 1} = '';
                end
            end

            %%
            %% parse the file
            %%

            % look for beggining of trajectory points
            l = strmatch('%%END_HEADER', data(:, 1));
            if isempty(l)
                err = 1;
            else
               for i = (l + 1):length(data)
                   % extract time, X and Y coordinates
                   if ~isempty(data{i, 1})
                       t = sscanf(data{i, 2}, '%f');
                       x = sscanf(data{i, 3}, '%f');
                       y = sscanf(data{i, 4}, '%f');
                       stat = sscanf(data{i, 6}, '%f'); % point status
                       % discard missing smaples
                       if ~isempty(t) && ~isempty(x) && ~isempty(y) && ~isempty(stat) && stat ~= config_place_avoidance.POINT_STATE_BAD
                           if ~(x == 0 && y == 0) 
                               pts = [pts; t/1000. x y stat];
                           end
                       end
                   end
               end
            end

            if err
                exit('invalid file format');
            end
        end
    end
end