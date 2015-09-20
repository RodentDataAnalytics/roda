classdef main_window < handle
    %MAIN_WINDOW Summary of this class goes here
    %   Detailed explanation goes here    
    properties(GetAccess = 'public', SetAccess = 'protected')        
        features = [];  
        features_values = [];
        features_display = [];
        features_cluster = [];
        labels_filename = [];
        selection = [];
        config = [];
        % GUI elements
        window = [];        
        tab_panel = [];
        % sub-tabs
        labels_view = [];
        clustering_view = [];
        % the trajectories
        traj = [];               
        % the trajectoriy labels
        tags = [];               
        traj_labels = []
        % the current clustering results
        clustering_results = [];
        reference_results = [];
        results_difference = [];
    end
    
    methods
        function inst = main_window(labels_fn, traj, varargin)
            global g_config;
            inst.config = g_config;
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern'));    
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout'));
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout/Patch'));
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/cm_and_cb_utilities'));
            
            [inst.tags, inst.features_display, inst.features_cluster, inst.selection, inst.reference_results, name] = process_options(varargin, ...
                        'Tags', g_config.TAGS, 'Features', g_config.DEFAULT_FEATURE_SET, ...
                        'ClusteringFeatures', g_config.CLUSTERING_FEATURE_SET, ...
                        'UserSelection', [], 'ReferenceClassification', [], ...
                        'Name', 'Trajectories tagging' ...
            );
            
            % read labels if we already have something
            inst.traj = traj;
            inst.labels_filename = labels_fn;
            inst.traj_labels = zeros(inst.traj.count, length(inst.tags));
            if exist(labels_fn, 'file')
                [labels_data, label_tags] = traj.read_tags(labels_fn, g_config.TAG_TYPE_ALL);
                [labels_map, labels_idx] = traj.match_tags(labels_data, label_tags);
                non_matched = sum(labels_idx == -1);
                if non_matched > 0
                    fprintf('Warning: %d unmatched trajectories/segments found!\n', non_matched);
                end

                % match tags with complete list of tags
                for i = 1:length(label_tags)
                    for j = 1:length(inst.tags)
                       if strcmp(label_tags(i).abbreviation, inst.tags(j).abbreviation)
                           inst.traj_labels(:, j) = labels_map(:, i);
                           break;
                       end
                    end
                end
            end
            
            % create main window
            inst.window = figure('Visible','off', 'name', name, ...
                'Position', [200, 200, 1280, 800], 'Menubar', 'none', 'Toolbar', 'none', 'resize', 'on');

            % combine display + clustering features
            inst.features = [inst.features_cluster, setdiff(inst.features_display, inst.features_cluster)];
            inst.features_values = inst.traj.compute_features(inst.features);  
            
            % create the tabs
            vbox = uiextras.VBox( 'Parent', inst.window, 'Padding', 5);
            inst.tab_panel = uiextras.TabPanel( 'Parent', vbox, 'Padding', 5, 'Callback', @inst.update_tab_callback, 'TabSize', 150);
            
            inst.labels_view = label_trajectories_view(inst, inst.tab_panel);
            inst.clustering_view = clustering_view(inst, inst.tab_panel);
            
            inst.tab_panel.TabNames = {'Browse/label segments', 'Clustering'};
            inst.tab_panel.SelectedChild = 1;                      
            inst.update(1);           
        end
        
        function show(inst)
            set(inst.window, 'Visible', 'on');  
        end
        
        function update_tab_callback(inst, source, eventdata)
            inst.update(eventdata.SelectedChild);
        end
        
        function update_callback(inst, source, eventdata)
            inst.update(inst.tab_panel.SelectedChild);
        end
        
        function update(inst, tabnr)
            switch tabnr
                case 1 % show features
                    inst.labels_view.update;
                case 2 
                    inst.clustering_view.update;
                otherwise
                    error('Ehm, seriously?');
            end                        
        end 
        
        function set_clustering_results(inst, res)
            inst.clustering_results = res;
            
            if ~isempty(inst.reference_results)
                inst.results_difference = inst.clustering_results.difference(inst.reference_results);
            else
                inst.results_difference = [];
            end
                    
            % notify sub-windows
            if ismethod(inst.labels_view, 'clustering_results_updated')
                inst.labels_view.clustering_results_updated;
            end
            
            if ismethod(inst.clustering_view, 'clustering_results_updated')
                inst.clustering_view.clustering_results_updated;
            end
            
            inst.update(inst.tab_panel.SelectedChild);
        end        
    end        
end

