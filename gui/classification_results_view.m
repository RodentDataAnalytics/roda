classdef classification_results_view < handle   
    
    properties(GetAccess = 'public', SetAccess = 'protected')        
        window = [];
        parent = [];
        % selected groups and trials
        groups = [];
        trials = [];
        trial_type = [];
        block_begin = [];
        block_end = [];
        % selected cluster
        cluster = 0;                
        groups_colors = [];
        trajectories_group = [];
        trajectories_trial = [];
        max_time = [];
        blocks = 1;
        block_length = -1;
    end
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        tab_panel = [];
        common_controls_box = [];        
        % tabs        
        single_features = [];
        features_evolution = [];
        full_trajectories = [];
        correlations = [];
        classes = [];
        block_begin_edit = [];        
        block_end_edit = [];
        block_length_edit = [];                
        % common controls
        group_checkboxes = [];
        trial_type_combo = [];
        first_trial_combo = [];
        last_trial_combo = [];
        cluster_combo = [];             
    end
    
    methods
        function inst = classification_results_view(par, par_wnd)
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;     
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/cm_and_cb_utilities'));
            
            inst.groups_colors = cmapping(inst.parent.config.GROUPS + 1, jet);                                    
        end
        
        function update(inst)
        % create the tabs
            if isempty(inst.tab_panel)
                vbox = uiextras.VBox( 'Parent', inst.window, 'Padding', 5);
                inst.tab_panel = uiextras.TabPanel( 'Parent', vbox, 'Padding', 5, 'Callback', @inst.update_tab_callback, 'TabSize', 150);

                inst.single_features = results_single_features_view(inst, inst.tab_panel);            
                inst.features_evolution = results_features_evolution_view(inst, inst.tab_panel);
                inst.correlations = results_correlation_view(inst, inst.tab_panel);
                inst.classes = results_classes_evolution_view(inst, inst.tab_panel);
                inst.tab_panel.TabNames = {'Segment features', 'Features evolution', 'Correlations', 'Classes'};
                inst.tab_panel.SelectedChild = 1;       

                %%
                %% common control area
                %%
                inst.common_controls_box = uiextras.HBox( 'Parent', vbox);
                set(vbox, 'Sizes', [-1, 70]);

                % trials combos
                pan = uiextras.BoxPanel('Parent', inst.common_controls_box, 'Title', 'Filter');      
                
                vbox = uiextras.VBox('Parent', pan);                                                    
                hbox = uiextras.HBox('Parent', vbox);
                                
                uicontrol('Parent', hbox, 'Style', 'text', 'String', 'Trial type:');                        
                types = {'All'};
                types = [types, inst.parent.config.TRIAL_TYPES_DESCRIPTION];
                inst.trial_type_combo = uicontrol('Parent', hbox, 'Style', 'popupmenu', 'String', types, 'Callback', @inst.update_callback);
                 
                trials = arrayfun( @(t) num2str(t), 1:inst.parent.config.TRIALS, 'UniformOutput', 0);  
                uicontrol('Parent', hbox, 'Style', 'text', 'String', 'First trial:');            
                inst.first_trial_combo = uicontrol('Parent', hbox, 'Style', 'popupmenu', 'String', trials, 'Callback', @inst.update_callback);
                set(inst.first_trial_combo, 'value', 1);            
                
                uicontrol('Parent', hbox, 'Style', 'text', 'String', 'Time begin:');            
                inst.block_begin_edit = uicontrol('Parent', hbox, 'Style', 'edit', 'String', '0', 'Callback', @inst.update_callback);
                                
                %% lower row
                hbox = uiextras.HBox('Parent', vbox);                
                
                uicontrol('Parent', hbox, 'Style', 'text', 'String', 'Cluster:');        
                inst.cluster_combo = uicontrol('Parent', hbox, 'Style', 'popupmenu', 'String', '** all **', 'Enable', 'off');                
                
                uicontrol('Parent', hbox, 'Style', 'text', 'String', 'Last trial:');            
                inst.last_trial_combo = uicontrol('Parent', hbox, 'Style', 'popupmenu', 'String', trials, 'Callback', @inst.update_callback);
                set(inst.last_trial_combo, 'value', inst.parent.config.TRIALS);
                
                % longest trajectory
                inst.max_time = max(arrayfun( @(idx) inst.parent.traj.items(idx).compute_feature(base_config.FEATURE_LATENCY), 1:inst.parent.traj.count));
                
                % uicontrol('Parent', hbox, 'Style', 'text', 'String', 'Time end:');            
                % inst.block_end_edit = uicontrol('Parent', hbox, 'Style', 'edit', 'String', num2str(inst.max_time), 'Callback', @inst.update_callback);
                
                uicontrol('Parent', hbox, 'Style', 'text', 'String', 'Block length:');            
                inst.block_length_edit = uicontrol('Parent', hbox, 'Style', 'edit', 'String', num2str(inst.max_time), 'Callback', @inst.update_callback);
               
                
                % groups
                pan = uiextras.BoxPanel('Parent', inst.common_controls_box, 'Title', 'Groups');      
                box = uiextras.HBox('Parent', pan);                                    
                inst.group_checkboxes = uicontrol('Parent', box, 'Style', 'checkbox', 'String', '', 'Callback', @inst.update_callback, 'BackgroundCol', inst.groups_colors(1, :), 'Value', 1);          
                uicontrol('Parent', box, 'Style', 'text', 'String', 'Combined');
                sz = [25, -1];
                for g = 1:inst.parent.config.GROUPS
                    if ~isempty(inst.parent.config.GROUPS_DESCRIPTION)
                        str = inst.parent.config.GROUPS_DESCRIPTION{g};
                    else
                        str = sprinttf('Group %d', g);
                    end
                    inst.group_checkboxes = [ inst.group_checkboxes, ...
                                               uicontrol('Parent', box, 'Style', 'checkbox', 'String', '', 'Callback', @inst.update_callback, 'BackgroundCol', inst.groups_colors(g + 1, :)) ...
                                             ];                
                    uicontrol('Parent', box, 'Style', 'text', 'String', str);
                    sz = [sz, 25, -1];
                end                                    
                set(box, 'Sizes', sz);
                set(inst.common_controls_box, 'Sizes', [500, -1]);
            end
            
            if ~isempty(inst.parent.clustering_results)
                inst.update_child(inst.tab_panel.SelectedChild);            
            end
        end
                    
        function clustering_results_updated(inst, source, eventdata)                        
            strings = {'** all **'};            
            for i = 1:inst.parent.clustering_results.nclusters
                if inst.parent.clustering_results.cluster_class_map(i) == 0
                    lbl = inst.parent.config.UNDEFINED_TAG_ABBREVIATION;
                else
                    lbl = inst.parent.clustering_results.classes(inst.parent.clustering_results.cluster_class_map(i)).abbreviation;
                end
                nclus = sum(inst.parent.clustering_results.cluster_index == i);
                strings = [strings, sprintf('#%d (''%s'', N=%d)', i, lbl, nclus)];  
            end        
            
            set(inst.cluster_combo, 'String', strings, 'Callback', @inst.update_callback, 'Enable', 'on', 'Value', 1);            
            if ~isempty(inst.tab_panel)
                inst.update(inst.tab_panel.SelectedChild);
            end
        end
        
        function update_tab_callback(inst, source, eventdata)
            inst.clear;      
            inst.update_child(eventdata.SelectedChild);
        end
        
        function update_callback(inst, source, eventdata)
            inst.update_child(inst.tab_panel.SelectedChild);
        end
        
        function update_child(inst, tabnr)                        
            inst.groups = arrayfun( @(h) get(h, 'value'), inst.group_checkboxes);
            
            trial_type = get(inst.trial_type_combo, 'value');
            first_trial = get(inst.first_trial_combo, 'value');            
            last_trial = get(inst.last_trial_combo, 'value');
            inst.trials = zeros(1, inst.parent.config.TRIALS);
            inst.block_begin = str2num(get(inst.block_begin_edit, 'String'));            
            inst.block_end = inst.max_time; % str2num(get(inst.block_end_edit, 'String'));            
            inst.block_length = str2num(get(inst.block_length_edit, 'String'));            
            if inst.block_length > 0
                inst.blocks = round((inst.max_time - inst.block_begin) / inst.block_length);
            end
            sig = sign(last_trial - first_trial);
            if sig == 0
                sig = 1;
            end
            inst.trials(first_trial:sig:last_trial) = 1;
            inst.trial_type = trial_type - 1;
%             if trial_type > 1
%                 inst.trials = inst.trials & (g_config.TRIAL_TYPE == trial_type - 1);
%             end                
            
            inst.cluster = get(inst.cluster_combo, 'value') - 1;            
            
            switch tabnr
                case 1 % show features
                    inst.single_features.update;
                case 2
                    inst.features_evolution.update;                       
                case 3
                    inst.correlations.update;                        
                case 4
                    inst.classes.update;
                otherwise
                    error('Ehm, seriously?');
            end            
        end                         
        
        function clear(inst)
            switch inst.tab_panel.SelectedChild
                case 1 % show features
                    if ismethod(inst.single_features, 'clear')
                        inst.single_features.clear;
                    end
                case 2
                    if ismethod(inst.features_evolution, 'clear')
                        inst.features_evolution.clear;
                    end                                           
                case 3
                    if ismethod(inst.correlations, 'clear')
                        inst.correlations.clear;
                    end                                                              
                case 4
                    if ismethod(inst.classes, 'clear')
                        inst.classes.clear;
                    end                    
                otherwise
                    error('Ehm, seriously?');
            end                  
        end
    end        
end