classdef cluster_prototypes_view < handle
    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];    
        parent = [];
        main_window = [];
        grid = [];
        grid_box = [];
        panels = [];
        desc = [];
        axis = [];
        axis_edges = [];
        controls_box = []; 
        prev_n = 0;
        show_edge = 0;
    end
    
    methods
        function inst = cluster_prototypes_view(par, par_wnd)
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;
            inst.main_window = inst.parent.parent;
        end
                       
        function update(inst)     
            if isempty(inst.grid_box)
                inst.grid_box = uiextras.VBox('Parent', inst.window);
                inst.controls_box = uiextras.HBox('Parent', inst.window);
                set(inst.window, 'Sizes', [-1, 40]);       
            end
            
            if ~isempty(inst.main_window.clustering_results) && inst.prev_n ~= inst.main_window.clustering_results.nclusters
                if ~isempty(inst.grid)
                    delete(inst.grid);
                end
                n = inst.main_window.clustering_results.nclusters;                
                if n == 1
                    nr = 1;
                    nc = 1;
                elseif n == 2
                    nr = 1;
                    nc = 2;
                elseif n <= 4
                    nr = 2;
                    nc = 2;
                elseif n <= 6
                    nr = 2;
                    nc = 3;
                elseif n <= 9;
                    nr = 3;
                    nc = 3;
                elseif n <= 12;
                    nr = 3;
                    nc = 4;
                elseif n <= 15;
                    nr = 3;
                    nc = 5;
                elseif n <= 20;
                    nr = 4;
                    nc = 5;
                elseif n <= 25;
                    nr = 5;
                    nc = 5;                
                else
                    error('need to update the list above');
                end 
                        
                inst.grid = uiextras.Grid('Parent', inst.grid_box);               
                inst.axis = [];                
                inst.axis_edges = [];
                inst.desc = [];
                                
                for i = 1:n                    
                    vbox = uiextras.VBox('Parent', inst.grid);
                    hbox = uiextras.HBox('Parent', vbox);
                    inst.axis = [inst.axis, axes('Parent', uicontainer('Parent', hbox))];                                        
                    
                    if inst.show_edge
                        vbox2 = uiextras.VBox('Parent', hbox);
                        inst.axis_edges = [inst.axis_edges, axes('Parent', vbox2)];                                        
                        inst.axis_edges = [inst.axis_edges, axes('Parent', vbox2)];                                        
                    end
                    inst.desc = [inst.desc, uicontrol('Parent', vbox, 'Style', 'text')];
                    set(vbox, 'Sizes', [-1, 20]);
                end                                
                
                set(inst.grid, 'RowSizes', -1*ones(1, nr), 'ColumnSizes', -1*ones(1, nc));                                                                
            end                                    
            if ~isempty(inst.main_window.clustering_results)
                inst.update_plots;
            end
        end       
        
        function update_plots(inst, source, event_data) 
            npca = inst.main_window.config.property('NUMBER_FEATURES_PCA', 0);
            if npca > 0
                feat_val = inst.main_window.traj.compute_features_pca(inst.main_window.features_cluster, inst.parent.num_features);
            else
                feat_val = inst.main_window.traj.compute_features(inst.main_window.features_cluster);           
            end
            
            for idx = 1:length(inst.axis)                                                                
                set(inst.main_window.window, 'currentaxes', inst.axis(idx));                
                hold off;                
                
                % get the sample closest to the centre of the cluster                                
                sel = find(inst.main_window.clustering_results.cluster_index == idx);                  
                feat_norm = max(feat_val(sel, :)) - min(feat_val(sel, :));
            
                dist = sum(((feat_val(sel, :) - repmat(inst.main_window.clustering_results.centroids(:, idx)', length(sel), 1)) ./ repmat(feat_norm, length(sel), 1)).^2, 2);
                
                [~, min_dist] = sort(dist);
                                
                inst.main_window.traj.items(min_dist(1)).plot();
                
                if inst.show_edge                    
                    % edge plots
                    [~, max_dist] = sort(dist, 'descend');
                    set(inst.main_window.window, 'currentaxes', inst.axis_edges((idx - 1)*2 + 1));                
                    inst.main_window.traj.items(max_dist(1)).plot();
                    set(inst.main_window.window, 'currentaxes', inst.axis_edges((idx - 1)*2 + 2));                
                    inst.main_window.traj.items(max_dist(2)).plot();
                end
                
                set(inst.desc(idx), 'String', ['Cluster ' num2str(idx)]);
            end
        end
        
        function clustering_results_updated(inst, source, eventdata)
        end
    end       
end