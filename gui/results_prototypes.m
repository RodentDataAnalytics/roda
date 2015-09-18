classdef results_prototypes < handle
    %RESULTS_SINGLE_FEATURES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];    
        parent = [];
        grid = [];
        panels = [];
        axis = [];
        controls_box = [];                          
    end
    
    methods
        function inst = results_prototypes(par, par_wnd)
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;
        end
               
        function update(inst)
            global g_config;            
            if isempty(inst.grid) && ~isempty(inst.parent.results)
                n = inst.parent.results.nclusters;
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
                        
                inst.grid = uiextras.Grid('Parent', inst.window);
                inst.controls_box = uiextras.HBox('Parent', inst.window);
                set(inst.window, 'Sizes', [-1, 40]);                
                inst.axis = [];
                                
                for i = 1:n
                    hbox = uiextras.VBox('Parent', inst.grid);
                    inst.axis = [inst.axis, axes('Parent', hbox)];                                        
                end                                
                
                set(inst.grid, 'RowSizes', -1*ones(1, nr), 'ColumnSizes', -1*ones(1, nc));                                                                
            end                                    
            if ~isempty(inst.parent.results)
                inst.update_plots;
            end
        end       
        
        function update_plots(inst, source, event_data) 
            global g_config;
            feat_val = inst.parent.traj.compute_features(g_config.CLUSTERING_FEATURE_SET);           
            
            for idx = 1:length(inst.axis)                                                                
                set(inst.parent.window, 'currentaxes', inst.axis(idx));                
                hold off;                
                
                % get the sample closest to the centre of the cluster                                
                sel = find(inst.parent.results.cluster_index == idx);                  
                feat_norm = max(feat_val(sel, :)) - min(feat_val(sel, :));
            
                dist = sum(((feat_val(sel, :) - repmat(inst.parent.results.centroids(:, idx)', length(sel), 1)) ./ repmat(feat_norm, length(sel), 1)).^2, 2);
                
                [~, min_dist] = sort(dist);
                                
                inst.parent.traj.items(min_dist(1)).plot();
            end
        end
    end       
end