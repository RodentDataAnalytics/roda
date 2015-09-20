classdef cluster_prototypes_view < handle
    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];    
        parent = [];
        grid = [];
        grid_box = [];
        panels = [];
        axis = [];
        controls_box = [];                          
        prev_n = 0;        
    end
    
    methods
        function inst = cluster_prototypes_view(par, par_wnd)
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;
        end
                       
        function update(inst)     
            if isempty(inst.grid_box)
                inst.grid_box = uiextras.VBox('Parent', inst.window);
                inst.controls_box = uiextras.HBox('Parent', inst.window);
                set(inst.window, 'Sizes', [-1, 40]);       
            end
            
            if ~isempty(inst.parent.clustering_results) && inst.prev_n ~= inst.parent.clustering_results.nclusters
                if ~isempty(inst.grid)
                    delete(inst.grid);
                end
                n = inst.parent.clustering_results.nclusters;                
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
                                
                for i = 1:n
                    hbox = uiextras.VBox('Parent', inst.grid);
                    inst.axis = [inst.axis, axes('Parent', hbox)];                                        
                end                                
                
                set(inst.grid, 'RowSizes', -1*ones(1, nr), 'ColumnSizes', -1*ones(1, nc));                                                                
            end                                    
            if ~isempty(inst.parent.clustering_results)
                inst.update_plots;
            end
        end       
        
        function update_plots(inst, source, event_data) 
            feat_val = inst.parent.traj.compute_features(inst.parent.features_cluster);           
            
            for idx = 1:length(inst.axis)                                                                
                set(inst.parent.window, 'currentaxes', inst.axis(idx));                
                hold off;                
                
                % get the sample closest to the centre of the cluster                                
                sel = find(inst.parent.clustering_results.cluster_index == idx);                  
                feat_norm = max(feat_val(sel, :)) - min(feat_val(sel, :));
            
                dist = sum(((feat_val(sel, :) - repmat(inst.parent.clustering_results.centroids(:, idx)', length(sel), 1)) ./ repmat(feat_norm, length(sel), 1)).^2, 2);
                
                [~, min_dist] = sort(dist);
                                
                inst.parent.traj.items(min_dist(1)).plot();
            end
        end
    end       
end