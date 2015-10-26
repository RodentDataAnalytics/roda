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
        % menus
        main_menu = [];        
        % sub-tabs
        labels_view = [];
        clustering_view = [];
        results_view = [];
        % the trajectories
        traj = [];               
        % the trajectoriy labels
        tags = [];               
        % the current clustering results
        clustering_results = [];        
        reference_results = [];
        results_difference = [];        
        groups_colors = [];
    end
    
    properties(GetAccess = 'public', SetAccess = 'public')
        traj_labels = [];       
    end
    
    methods
        function inst = main_window(cfg, varargin)
            %%% HACK OpenGL renderer has some problems -> use SW rendering instead
            set(0, 'DefaultFigureRenderer', 'painters');
            %
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern'));    
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout'));
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout/Patch'));
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/cm_and_cb_utilities'));
            
            [inst.tags, inst.features_display, inst.features_cluster, inst.selection, inst.reference_results, name] = process_options(varargin, ...
                        'Tags', cfg.TAGS, 'Features', cfg.DEFAULT_FEATURE_SET, ...
                        'ClusteringFeatures', cfg.CLUSTERING_FEATURE_SET, ...
                        'UserSelection', [], 'ReferenceClassification', [], ...
                        'Name', 'Trajectories tagging' ...
            );
            
            % read labels if we already have something
            inst.config = cfg;
            inst.traj = inst.config.TRAJECTORIES;
            inst.labels_filename = ''; % inst.config.config.labels_fn;
            inst.traj_labels = zeros(inst.traj.count, length(inst.tags));
            if exist(inst.labels_filename, 'file')
                [labels_data, label_tags] = inst.traj.read_tags(inst.labels_filename, cfg.TAG_TYPE_ALL);
                [labels_map, labels_idx] = inst.traj.match_tags(labels_data, label_tags);
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
            
            %% compute features
            
            % combine display + clustering features
            if isscalar(inst.features_cluster)
                inst.features = inst.features_display;
            else
                inst.features = [inst.features_cluster, setdiff(inst.features_display, inst.features_cluster)];
            end
            
            h = waitbar(0, 'Computing features...', 'CreateCancelBtn', 'setappdata(gcbf, ''cancel'', 1);');
            setappdata(h, 'cancel', 0);            
            inst.features_values = inst.traj.compute_features(inst.features, ...             
                'ProgressCallback', ...
                @(mess, prog) return2nd(waitbar(prog, h, mess), getappdata(h, 'cancel')) ...
                );
            delete(h);
                                    
            % create main window
            inst.window = figure('Visible','off', 'name', inst.config.USER_DESCRIPTION, ...
                'Position', [200, 200, 1280, 800], 'Menubar', 'none', 'Toolbar', 'none', 'resize', 'on');
            
            % create menus
            inst.main_menu = uimenu(inst.window, 'Label', 'Edit');
            uimenu(inst.main_menu, 'Label', 'Tags', 'Callback', @inst.menu_tags_callback);
            
            % create the tabs
            vbox = uiextras.VBox( 'Parent', inst.window, 'Padding', 5);
            inst.tab_panel = uiextras.TabPanel( 'Parent', vbox, 'Padding', 5, 'Callback', @inst.update_tab_callback, 'TabSize', 150);
            
            inst.labels_view = label_trajectories_view(inst, inst.tab_panel);
            inst.clustering_view = clustering_view(inst, inst.tab_panel);
            inst.results_view = classification_results_view(inst, inst.tab_panel);
            
            inst.tab_panel.TabNames = {'Browsing & labelling', 'Clustering', 'Results'};
            inst.tab_panel.SelectedChild = 1;                      
            inst.update(1);
            inst.groups_colors = cmapping(inst.config.GROUPS + 1, jet);            
        end
        
        function show(inst)
            set(inst.window, 'Visible', 'on');  
        end         
        
        function update_tab_callback(inst, source, eventdata)
            inst.clear;
            inst.update(eventdata.SelectedChild);
        end
        
        function update_callback(inst, source, eventdata)
            inst.update_child(inst.tab_panel.SelectedChild);
        end        
        
        function update(inst, tabnr)
            switch tabnr
                case 1 % show features
                    inst.labels_view.update;
                case 2 
                    inst.clustering_view.update;
                case 3
                    inst.results_view.update;                
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
            
            if ismethod(inst.results_view, 'clustering_results_updated')
                inst.results_view.clustering_results_updated;
            end
            
            inst.update(inst.tab_panel.SelectedChild);
        end        
        
        function clear(inst)
            switch inst.tab_panel.SelectedChild
                case 1 % show features
                    if ismethod(inst.labels_view, 'clear')
                        inst.labels_view.clear;
                    end
                case 2
                    if ismethod(inst.clustering_view, 'clear')
                        inst.clustering_view.clear;
                    end
                case 3
                    if ismethod(inst.results_view, 'clear')
                        inst.results_view.clear;
                    end
            end
        end    
        
        function menu_tags_callback(inst, source, eventdata)
            wnd = edit_tags_window;
            wnd.show(inst.config);            
            inst.config.TAGS
        end       
    end        
end