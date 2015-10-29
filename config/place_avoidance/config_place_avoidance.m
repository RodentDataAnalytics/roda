classdef config_place_avoidance < base_config
    % config_mwm Global constants
    properties(Constant)        
        TRIAL_TYPE_APAT_HABITUATION = 1;
        TRIAL_TYPE_APAT_TRAINING = 2;
        TRIAL_TYPE_APAT_TEST = 3;
        TRIAL_TYPE_PAT_DARKNESS = 4;        
                            	                        
        % trajectory sample status
        POINT_STATE_OUTSIDE = 0;
        POINT_STATE_ENTRANCE_LATENCY = 1;
        POINT_STATE_SHOCK = 2;
        POINT_STATE_INTERSHOCK_LATENCY = 3;
        POINT_STATE_OUTSIDE_LATENCY = 4;
        POINT_STATE_BAD = 5;               
        
        % wrap functions so that we can better deal with them (e.g. compute
        % a hash that uniquely identify them)
        FUNCTION_LOG = function_wrapper('Log', '@(x) log(x)');        
        FUNCTION_LOG_NEG = function_wrapper('Minus log', '@(x) -log(x)');
        FUNCTION_MEAN = function_wrapper('Mean', '@(x) mean(x)');       
                
        FEATURE_AVERAGE_SPEED_ARENA = trajectory_feature('Va', 'Average speed (arena)', 'trajectory_average_speed', 1, {}, ...
            'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD );
        FEATURE_VARIANCE_SPEED_ARENA = trajectory_feature('Va_var', 'Variance speed arena', 'trajectory_variance_speed', 1, {}, ...
            'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD );
        FEATURE_LOG_VARIANCE_SPEED_ARENA = trajectory_feature('Va_var', 'Log variance speed (arena)', 'feature_transform', 1, {}, ...
            config_place_avoidance.FUNCTION_LOG, ...
            config_place_avoidance.FEATURE_VARIANCE_SPEED_ARENA );
        FEATURE_LENGTH_ARENA = trajectory_feature('L_A', 'Length (arena)', 'trajectory_length', 1, {}, ...
            'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD );
        FEATURE_LOG_RADIUS = trajectory_feature('log_R12', 'Log radius  ', 'trajectory_radius', 1, ...
            {'CENTRE_X', 'CENTRE_Y', 'ARENA_R'}, ...
            'TransformationFunc', config_place_avoidance.FUNCTION_LOG_NEG, ...
            'AveragingFunc', config_place_avoidance.FUNCTION_MEAN );
        FEATURE_IQR_RADIUS_ARENA = trajectory_feature('Riqr_A', 'IQR radius (arena)', 'trajectory_radius', 2, ...
            {'CENTRE_X', 'CENTRE_Y', 'ARENA_R'}, ...
            'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD );
        FEATURE_TIME_CENTRE = trajectory_feature('Tc_A', 'Time centre', 'trajectory_time_within_radius', 1, ...
            {'CENTRE_X', 'CENTRE_Y', 'TIME_WITHIN_RADIUS_R'}, ...
            'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD );
        FEATURE_NUMBER_OF_SHOCKS = trajectory_feature('N_s', 'Number of shocks', 'trajectory_count_events', 1, {}, ...
            config_place_avoidance.POINT_STATE_SHOCK );
        FEATURE_FIRST_SHOCK = trajectory_feature('T1', 'Time for first shock', 'trajectory_first_event', 1, {}, ...
            config_place_avoidance.POINT_STATE_SHOCK );
        FEATURE_MAX_INTER_SHOCK = trajectory_feature('Tmax', 'Maximum time between shocks', 'trajectory_max_inter_event', 1, {}, ...
            config_place_avoidance.POINT_STATE_SHOCK );
        FEATURE_ENTRANCES_SHOCK = trajectory_feature('Nent', 'Number of entrances', 'trajectory_entrances_shock');
        FEATURE_ANGULAR_DISTANCE_SHOCK = trajectory_feature('D_ang', 'Angular distance shock', 'trajectory_angular_distance_shock', 1, ...
            {'CENTRE_X', 'CENTRE_Y', 'SHOCK_AREA_ANGLE'} );
        FEATURE_SHOCK_RADIUS = trajectory_feature('R_s', 'Shock radius', 'trajectory_event_radius', 1, ...
            {'CENTRE_X', 'CENTRE_Y', 'ARENA_R'}, ...
            config_place_avoidance.POINT_STATE_SHOCK );
                                                                            
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
                                  
        DATA_REPRESENTATION_ARENA_COORD = data_representation('Arena coordinates', base_config.DATA_TYPE_COORDINATES, 'trajectory_arena_coord', 1, {'CENTRE_X', 'CENTRE_Y', 'ROTATION_FREQUENCY'});
        DATA_REPRESENTATION_ARENA_SPEED = data_representation('Speed (arena)', base_config.DATA_TYPE_SCALAR_FIELD, 'trajectory_speed', 1, {}, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD);
        DATA_REPRESENTATION_ARENA_SPEED_PROFILE = data_representation('Speed profile (arena)', base_config.DATA_TYPE_FUNCTION, 'trajectory_speed_profile', 1, {}, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD);        
        DATA_REPRESENTATION_SHOCKS = data_representation('Shock events', base_config.DATA_TYPE_EVENTS, 'trajectory_events', 1, {}, config_place_avoidance.POINT_STATE_SHOCK);
        DATA_REPRESENTATION_ARENA_SHOCKS = data_representation('Shock events (arena)', base_config.DATA_TYPE_EVENTS, 'trajectory_events', 1, {}, config_place_avoidance.POINT_STATE_SHOCK, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD);
        
        %%%
        %%% Segmentation
        %%%
        SEGMENTATION_PLACE_AVOIDANCE = function_wrapper('Place avoidance', 'segmentation_place_avoidance', 1, {'SEGMENT_SECTION', 'SEGMENT_MINIMUM_SHOCKS_DELAY'});
    end    
            
    methods        
        function inst = config_place_avoidance(name, varargin)
            % set some properties if not set yet            
            prop = process_options(varargin, 'Properties', {});          
           
            prop = property_list_set_default(prop, 'ARENA_R', 127);
            prop = property_list_set_default(prop, 'CENTRE_X', 127);
            prop = property_list_set_default(prop, 'CENTRE_Y', 127);
            prop = property_list_set_default(prop, 'ROTATION_FREQUENCY', 1);
            prop = property_list_set_default(prop, 'CLUSTER_CLASS_MINIMUM_SAMPLES_P', 0.005); 
            prop = property_list_set_default(prop, 'CLUSTER_CLASS_MINIMUM_SAMPLES_EXP', 0.5);        
            prop = property_list_set_default(prop, 'NUMBER_FEATURES_PCA', 4);  
            prop = property_list_set_default(prop, 'TIME_WITHIN_RADIUS_R', 0.75*127); 
            
            % replace the properties with our new list            
            other_arg = property_list_replace(varargin, 'Properties', prop);
            
            inst@base_config(name, ...                
               'DataRepresentations', ...
               [ config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD, ...
                 config_place_avoidance.DATA_REPRESENTATION_ARENA_SPEED, ... 
                 config_place_avoidance.DATA_REPRESENTATION_ARENA_SPEED_PROFILE, ... 
                 config_place_avoidance.DATA_REPRESENTATION_SHOCKS, ...
                 config_place_avoidance.DATA_REPRESENTATION_ARENA_SHOCKS ...
               ], 'Features', ...
               [ config_place_avoidance.FEATURE_AVERAGE_SPEED_ARENA, ...
                 config_place_avoidance.FEATURE_VARIANCE_SPEED_ARENA, ...
                 config_place_avoidance.FEATURE_LENGTH_ARENA, ...
                 config_place_avoidance.FEATURE_LOG_RADIUS, ...
                 config_place_avoidance.FEATURE_IQR_RADIUS_ARENA, ...
                 config_place_avoidance.FEATURE_TIME_CENTRE, ...
                 config_place_avoidance.FEATURE_NUMBER_OF_SHOCKS, ...
                 config_place_avoidance.FEATURE_FIRST_SHOCK, ...
                 config_place_avoidance.FEATURE_MAX_INTER_SHOCK, ...
                 config_place_avoidance.FEATURE_ENTRANCES_SHOCK, ...
                 config_place_avoidance.FEATURE_ANGULAR_DISTANCE_SHOCK, ...
                 config_place_avoidance.FEATURE_SHOCK_RADIUS ... 
               ], ...
               'FeatureSet', config_place_avoidance.FEATURE_SET_APAT, ...
               'ClusteringFeatureSet', config_place_avoidance.CLUSTERING_FEATURE_SET_APAT, ...               
               'TrialTypesDescription', ...
               { 'APAT/Habituation', ...
                 'APAT/Training', ...
                 'APAT/Testing', ...
                 'PAT/Darkness' }, ...                                        
               other_arg{:} ...
            );                                
        end                        
        
        function traj = load_trajectories(inst, path, traj_group, varargin) 
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
                pts = inst.read_trajectory(strcat(path, '/', files(j).name));
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

                traj = traj.append(trajectory(pts, 1, track, group, id, trial, inst.trial_to_session(trial), -1, -1, 1, inst.TRIAL_TYPES(trial)));  
                track = track + 1;
            end                                              

            fprintf(' done.\n');
        end
                
        function pts = read_trajectory(inst, fn)
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