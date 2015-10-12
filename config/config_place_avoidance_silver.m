classdef config_place_avoidance_silver < config_place_avoidance
    % config_mwm Global constants
    properties(Constant)             
        TAGS_CONFIG = { ... % values are: file that stores the tags, segment length, overlap, default number of clusters
            { '/home/tiago/neuroscience/place_avoidance/labels_silver_large.csv', 0, 0}, ...
            { '/home/tiago/neuroscience/place_avoidance/labels_t1_silver.csv', 10, config_place_avoidance.SEGMENTATION_PLACE_AVOIDANCE, 1, config_place_avoidance.SECTION_AVOID, 6} ...
        };
        SESSIONS = 6;  
        TRIALS_PER_SESSION = ones(1, config_place_avoidance_silver.SESSIONS);
        TRIALS = 6;
        TRIAL_TYPE = [ config_place_avoidance.TRIAL_TYPE_APAT_TRAINING ...
                            config_place_avoidance.TRIAL_TYPE_APAT_TRAINING, ...
                            config_place_avoidance.TRIAL_TYPE_APAT_TRAINING, ...
                            config_place_avoidance.TRIAL_TYPE_APAT_TRAINING, ...
                            config_place_avoidance.TRIAL_TYPE_APAT_TRAINING, ...
                            config_place_avoidance.TRIAL_TYPE_APAT_TEST ];
        GROUPS = 2;        
        GROUPS_DESCRIPTION = { ...
            'Control', ...
            'Silver', ...                    
        };
        SHOCK_AREA_ANGLE = pi/180*225*ones(1, config_place_avoidance_silver.SESSIONS);                         
    end   
        
    methods        
        function inst = config_place_avoidance_silver()            
            inst@config_place_avoidance('Place avoidance task (silver)');                                   
        end
        
        % Imports trajectories from Noldus data file's
        function res = load_data(inst, root)            
            % "Silver" set
            % folder = '/home/tiago/place_avoidance/data3/';
            % control
            traj = config_place_avoidance.load_trajectories(inst, root, 1, 'FilterPattern', 'ho*Room*.dat', 'IdDayMask', 'hod%dr%d', 'ReverseDayId', 1); 
            
            % silver
            traj = traj.append(config_place_avoidance.load_trajectories(inst, root, 2, 'FilterPattern', 'nd*Room*.dat', 'IdDayMask', 'nd%dr%d', 'ReverseDayId', 1));           
            
            inst.TRAJECTORIES = traj;
            res = 1;
        end        
    end
end