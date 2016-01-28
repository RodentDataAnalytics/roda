classdef clustering_view < handle
    %CLUSTERING_VIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        window = [];        
        parent = [];
        tab_box = [];
        tab_panel = [];
        ctrl_box = [];
        clusters_min_combo = [];
        clusters_max_combo = [];
        num_features_combo = []; 
        clusters_min = -1;
        clusters_max = -1;
        enable_cv_check = [];        
        prev_button = [];
        next_button = [];
        map_clusters_button = [];
        status_text = [];
        cur = 0;
        
        clustering_results = [];        
        
        prototypes = [];
        clusters = [];
        statistics = [];
    end
    
    methods
        function inst = clustering_view(par, par_wnd)            
            inst.parent = par;            
            inst.window = uiextras.VBox('Parent', par_wnd);            
        end    
            
        function update(inst)
            if isempty(inst.tab_box)
                inst.tab_box = uiextras.VBox('Parent', inst.window);
                inst.ctrl_box = uiextras.HBox('Parent', inst.window);
                set(inst.window, 'Sizes', [-1 70] )
                
                % clustering controls
                hbox = uiextras.HBox('Parent', inst.ctrl_box);
                vbox_ctrls = uiextras.VBox('Parent', hbox);
                inst.prev_button = uicontrol('Parent', hbox, 'Style', 'pushbutton', 'String', '<-', 'Callback', {@inst.previous_callback});
                inst.status_text = uicontrol('Parent', hbox, 'Style', 'text', 'String', '');                
                inst.next_button = uicontrol('Parent', hbox, 'Style', 'pushbutton', 'String', '->', 'Callback', {@inst.next_callback});
                set(hbox, 'Sizes', [400 80 -1 80] )
                
                %% clusters min
                hbox = uiextras.HBox('Parent', vbox_ctrls);                
                uicontrol('Parent', hbox, 'Style', 'text', 'String', 'Min clusters:');        
                vals = arrayfun( @(x) sprintf('%d', x), 1:200, 'UniformOutput', 0);                
                inst.clusters_min_combo = uicontrol('Parent', hbox, 'Style', 'popupmenu', 'String', vals);         
                inst.enable_cv_check = uicontrol('Parent', hbox, 'Style', 'checkbox', 'String', 'Enable CV');                    
                set(hbox, 'Sizes', [90 80 -1] );
                set(inst.clusters_min_combo, 'value', 5);
                
                %% clusters max
                hbox = uiextras.HBox('Parent', vbox_ctrls);
                uicontrol('Parent', hbox, 'Style', 'text', 'String', 'Max clusters:');        
                inst.clusters_max_combo = uicontrol('Parent', hbox, 'Style', 'popupmenu', 'String', vals);                                         
                uicontrol('Parent', hbox, 'Style', 'pushbutton', 'String', 'Cluster', 'Callback', {@inst.cluster_callback});                
                set(hbox, 'Sizes', [90 80 -1] );                
                set(inst.clusters_max_combo, 'value', 15);            
                
                %% clusters max
                hbox = uiextras.HBox('Parent', vbox_ctrls);
                uicontrol('Parent', hbox, 'Style', 'text', 'String', 'PCA components:');        
                vals = arrayfun( @(x) sprintf('%d', x), 1:100, 'UniformOutput', 0);                
                inst.num_features_combo = uicontrol('Parent', hbox, 'Style', 'popupmenu', 'String', vals);                                         
                inst.map_clusters_button = uicontrol('Parent', hbox, 'Style', 'pushbutton', 'String', 'Map clusters', 'Callback', {@inst.map_clusters_callback});                                
                set(hbox, 'Sizes', [90 80 -1] );                
                set(inst.num_features_combo, 'value', 4);                   
                
                inst.cur = 0;
                inst.update_position;
            end
                                
            if ~isempty(inst.parent.clustering_results)
                if isempty(inst.tab_panel)
                    inst.tab_panel = uiextras.TabPanel( 'Parent', inst.tab_box, 'Padding', 5, 'Callback', @inst.update_tab_callback, 'TabSize', 150);                
                    inst.prototypes = cluster_prototypes_view(inst, inst.tab_panel);            
                    inst.clusters = clusters_view(inst, inst.tab_panel);
                    inst.statistics = clustering_statistics_view(inst, inst.tab_panel);
                    
                    inst.tab_panel.TabNames = {'Prototypes', 'Clusters', 'Statistics'};
                    inst.tab_panel.SelectedChild = 1;               
                end
                inst.update_child(inst.tab_panel.SelectedChild);            
            end
        end
        
        function update_tab_callback(inst, source, eventdata)
            inst.update_child(eventdata.SelectedChild);
        end
        
        function update_callback(inst, source, eventdata)
            inst.update_child(inst.tab_panel.SelectedChild);
        end
        
        function update_child(inst, tabnr)
            set(inst.parent.window, 'pointer', 'watch');
            drawnow;
            vis = get(inst.window, 'Visible');            
                                    
            if strcmp(vis, 'on')                
                switch tabnr
                    case 1 % show features
                        inst.prototypes.update;
                    case 2 % show features
                        inst.clusters.update;                    
                    case 3 % show features
                        inst.statistics.update;                                        
                    otherwise
                        error('Ehm, seriously?');
                end
            end            
            set(inst.parent.window, 'pointer', 'arrow');            
        end
        
        function cluster_callback(inst, source, eventdata) 
            set(gcf,'Pointer', 'watch');         
            
            inst.clusters_min = get(inst.clusters_min_combo, 'value');        
            inst.clusters_max = get(inst.clusters_max_combo, 'value');        
            
            tmp = inst.clusters_min;
            inst.clusters_min = min(inst.clusters_min, inst.clusters_max);
            inst.clusters_max = max(tmp, inst.clusters_max);
            cv = get(inst.enable_cv_check, 'value');
            if cv
                test_p = 0.1;
            else
                test_p = 0.;
            end
            inst.parent.config.set_property('NUMBER_FEATURES_PCA', get(inst.num_features_combo, 'value'));            
            
            % run multiple clustering rounds            
            inst.clustering_results = [];
            % select all tags of type behaviour
            tag_type = arrayfun( @(idx) inst.parent.config.TAGS(idx).type, 1:length(inst.parent.config.TAGS) );            
            
            classif = inst.parent.traj.classifier( ...
                inst.parent.config ...
              , inst.parent.traj_labels ...              
              , inst.parent.config.TAGS(find(tag_type == base_config.TAG_TYPE_BEHAVIOUR_CLASS)) ...              
            );                
            for n = inst.clusters_min:inst.clusters_max
                set(inst.status_text, 'String', ['Running clustering for N=' num2str(n)]);
                drawnow;
                inst.clustering_results = [inst.clustering_results, classif.cluster(n, test_p)];          
            end
            
            inst.cur = 1;
            inst.update_position;             
            set(gcf,'Pointer', 'arrow');         
        end
        
        function previous_callback(inst, source, eventdata)             
            inst.cur = inst.cur - 1;
            inst.update_position;           
        end
        
        function next_callback(inst, source, eventdata) 
            inst.cur = inst.cur + 1;
            inst.update_position;
        end
        
        function update_position(inst)
            if inst.cur <= 1
                set(inst.prev_button, 'Enable', 'off');
            else
                set(inst.prev_button, 'Enable', 'on');
            end
            
            if inst.cur >= length(inst.clustering_results)
                set(inst.next_button, 'Enable', 'off');
            else
                set(inst.next_button, 'Enable', 'on');
            end    
            
            if inst.cur > 0                
                set(inst.status_text, 'String', ['Clustering results for N=' num2str(inst.clusters_min - 1 + inst.cur)]);
                inst.parent.set_clustering_results(inst.clustering_results(inst.cur));                  
            else
                set(inst.status_text, 'String', '*** RUN CLUSTERING ***');
            end
        end
                
        function clustering_results_updated(inst, source, eventdata)             
            if ismethod(inst.clusters, 'clustering_results_updated')
                inst.clusters.clustering_results_updated;
            end
            
            if ismethod(inst.prototypes, 'clustering_results_updated')
                inst.prototypes.clustering_results_updated;
            end
            
            if ismethod(inst.statistics, 'clustering_results_updated')
                inst.statistics.clustering_results_updated;
            end
            set(inst.parent.window, 'Position', get(inst.parent.window, 'Position') + [1 1 1 1]);
        end
                
        function map_clusters_callback(inst, source, eventdata)
            
        end        
   end   
end
