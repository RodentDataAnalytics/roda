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
        enable_cv_check = [];        
        prev_button = [];
        next_button =[]
        status_text = [];
        cur = 0;
        
        prototypes_view = [];
        clusters_view = [];
        clustering_results = [];
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
                set(inst.window, 'Sizes', [-1 50] )
                
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
                inst.cur = 0;
                inst.update_position;
            end
                                
            if ~isempty(inst.parent.clustering_results)
                if isempty(inst.tab_panel)
                    inst.tab_panel = uiextras.TabPanel( 'Parent', inst.tab_box, 'Padding', 5, 'Callback', @inst.update_tab_callback, 'TabSize', 150);                
                    inst.prototypes_view = cluster_prototypes_view(inst.parent, inst.tab_panel);            

                    inst.tab_panel.TabNames = {'Prototypes'};
                    inst.tab_panel.SelectedChild = 1;               
                end
                set(inst.status_text, 'String', '');
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
            vis = get(inst.window, 'Visible');            
                                    
            if strcmp(vis, 'on')                
                switch tabnr
                    case 1 % show features
                        inst.prototypes_view.update;
                    otherwise
                        error('Ehm, seriously?');
                end
            end            
        end
        
        function cluster_callback(inst, source, eventdata) 
            set(gcf,'Pointer', 'watch');         
            
            nmin = get(inst.clusters_min_combo, 'value');        
            nmax = get(inst.clusters_max_combo, 'value');        
            
            tmp = nmin;
            nmin = min(nmin, nmax);
            nmax = max(tmp, nmax);
            cv = get(inst.enable_cv_check, 'value');
            if cv
                test_p = 0.1;
            else
                test_p = 0.;
            end
            
            % run multiple clustering rounds            
            inst.clustering_results = [];
            classif = inst.parent.traj.classifier(inst.parent.labels_filename, inst.parent.features_cluster, inst.parent.config.TAG_TYPE_BEHAVIOUR_CLASS);                
            for n = nmin:nmax
                set(inst.status_text, 'String', ['Running clustering for N=' num2str(n)]);
                refresh(inst.parent.window);
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
                set(inst.status_text, 'String', ['Clustering results for N=' num2str(inst.clustering_results(inst.cur).nclusters)]);
                inst.parent.set_clustering_results(inst.clustering_results(inst.cur));                  
            else
                set(inst.status_text, 'String', '*** RUN CLUSTERING ***');
            end
        end
                
        function clustering_results_updated(inst, source, eventdata)             
                         
        end
    end   
end
