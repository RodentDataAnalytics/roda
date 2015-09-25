classdef config_place_avoidance_combined < config_place_avoidance
    % config_mwm Global constants
    properties(Constant)             
        TAGS_CONFIG = { ... % values are: file that stores the tags, segment length, overlap, default number of clusters
            { '/home/tiago/neuroscience/place_avoidance/labels_combined.csv', 0, 0}, ...
            { '/home/tiago/neuroscience/place_avoidance/labels_combined_split.csv', 10, config_place_avoidance.SEGMENTATION_PLACE_AVOIDANCE, 1, config_place_avoidance.SECTION_AVOID, 6} ...
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
        GROUPS = 2 + config_place_avoidance_mem.GROUPS;        
        GROUPS_DESCRIPTION = [ ...            
            { 'Silver control', ...
              'Silver'}, ...
            config_place_avoidance_mem.GROUPS_DESCRIPTION ...
        ];
        SHOCK_AREA_ANGLE = pi/180*225*ones(1, config_place_avoidance_silver.SESSIONS);                         
    end   
        
    methods        
        function inst = config_place_avoidance_combined()            
            inst@config_place_avoidance('Place avoidance task (silver + memantine)');                                   
        end
               
        % Imports trajectories from Noldus data file's
        function traj = load_data(inst)            
            % "Silver" set
            traj = config_place_avoidance_silver.load_data;
            
            % Memantine set
            traj_mem = config_place_avoidance_mem.load_data(1);
            
            for i = 1:traj_mem.count
                % change group by 2
                traj_mem.items(i).set_group(traj_mem.items(i).group + 2);                
            end
            
            traj = traj.append(traj_mem);
        end        
    end
end