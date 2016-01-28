classdef cluster_prototypes_view < handle
    properties(Constant)        
        PROTOTYPES_CENTROIDS = 1;
        PROTOTYPES_BOUNDARIES = 2;
        PROTOTYPES_RANDOM = 3;
        
        PROTOTYPES_FILTER = {'Centroids', 'Boundaries', 'Random'};
        PROTOTYPES_COUNT = [1, 4, 9, 16, 25];                
    end
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];    
        parent = [];
        main_window = [];
        grid = [];
        grid_box = [];
        sub_grids = [];
        sub_panels = [];
        desc = [];
        axis = [];
        axis_edges = [];
        controls_box = [];
        nprot_combo = [];
        prot_filter_combo = [];
        
        prev_n = 0;
        prev_filter = 0;
        prev_nprot = 0;        
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
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', '# of prototypes:');                                                        
                inst.nprot_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', ...
                    'String', arrayfun (@(n) num2str(n), inst.PROTOTYPES_COUNT, 'UniformOutput', 0), 'Callback', @inst.update_callback);
                
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Filter:');                                        
                inst.prot_filter_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', ...
                    'String', cluster_prototypes_view.PROTOTYPES_FILTER, 'Callback', @inst.update_callback);                
                set(inst.window, 'Sizes', [-1, 60]);                    
                set(inst.controls_box, 'Sizes', [100, 100, 100, 100]);
            end
            
            filter = get(inst.prot_filter_combo, 'Value');
            nprot = inst.PROTOTYPES_COUNT(get(inst.nprot_combo, 'Value'));
            
            if ~isempty(inst.main_window.clustering_results) && ...
                    (inst.prev_n ~= inst.main_window.clustering_results.nclusters || ...
                     inst.prev_filter ~= filter || inst.prev_nprot ~= nprot)
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
                elseif n <= 9
                    nr = 3;
                    nc = 3;
                elseif n <= 12
                    nr = 3;
                    nc = 4;
                elseif n <= 15
                    nr = 3;
                    nc = 5;
                elseif n <= 20
                    nr = 4;
                    nc = 5;
                elseif n <= 25
                    nr = 5;
                    nc = 5;  
                elseif n <= 36
                    nr = 6;
                    nc = 6;
                else
                    error('need to update the list above');
                end 
                        
                inst.grid = uiextras.Grid('Parent', inst.grid_box);               
                inst.axis = [];                
                inst.axis_edges = [];
                inst.desc = [];
                inst.sub_panels = [];
                inst.sub_grids = [];
                                
                for i = 1:n                    
                    panel = uiextras.Panel('Parent', inst.grid, 'BorderType', 'etchedout');                        
                    vbox = uiextras.VBox('Parent', panel);
                    % create sub-grid
                    inst.sub_grids = [inst.sub_grids, uiextras.Grid('Parent', vbox)];
                    
                    for j = 1:nprot
                        pan = uiextras.Panel('Parent', inst.sub_grids(i), 'BorderType', 'etchedin');
                        inst.sub_panels = [inst.sub_panels, pan]; 
                        inst.axis = [inst.axis, axes('Parent', uicontainer('Parent', pan))];                                                                                                            
                    end
                    set(inst.sub_grids(i), 'RowSizes', -1*ones(1, sqrt(nprot)), 'ColumnSizes', -1*ones(1, sqrt(nprot)));                                                                
                
                    inst.desc = [inst.desc, uicontrol('Parent', vbox, 'Style', 'text')];
                    set(vbox, 'Sizes', [-1, 20]);
                end                                
                
                set(inst.grid, 'RowSizes', -1*ones(1, nr), 'ColumnSizes', -1*ones(1, nc));                                                                
                inst.prev_n = inst.main_window.clustering_results.nclusters;
                inst.prev_nprot = nprot;
                inst.prev_filter = filter;
            end                                    
            if ~isempty(inst.main_window.clustering_results)
                inst.update_plots;
            end
        end       
        
        function update_plots(inst, source, event_data) 
            set(inst.main_window.window, 'pointer', 'watch');
            drawnow;
            
            feat_val = inst.main_window.config.clustering_feature_values;
            
            for idx = 1:length(inst.sub_grids)                                                                
                hold off;                
                
                % get the samples
                sel = find(inst.main_window.clustering_results.cluster_index == idx);    
                if isempty(sel)
                else                    
                    feat_norm = max(feat_val(sel, :)) - min(feat_val(sel, :));            
                    dist = sum(((feat_val(sel, :) - repmat(inst.main_window.clustering_results.centroids(:, idx)', length(sel), 1)) ./ repmat(feat_norm, length(sel), 1)).^2, 2);

                    nprot = length(inst.axis) / length(inst.sub_grids);
                    switch get(inst.prot_filter_combo, 'Value')
                        case inst.PROTOTYPES_CENTROIDS
                            % sort by the distance to the centre - closest
                            [~, order] = sort(dist);                        
                        case inst.PROTOTYPES_BOUNDARIES
                            % sort by the distance to the centre - farthest
                            [~, order] = sort(dist, 'descend');                        
                        case inst.PROTOTYPES_RANDOM
                            % random selection
                            order = randperm(length(sel));
                        otherwise
                            error('Uhhh - fix me');
                    end

                    for i = 1:nprot                                                
                        set(inst.main_window.window, 'currentaxes', inst.axis( (idx - 1)*nprot + i));   
                        axis tight;
                        inst.main_window.traj.items(order(i)).plot(inst.main_window.config);                                                    
                    end
                end
                desc = ['Cluster ' num2str(idx)];
                iclass = inst.main_window.clustering_results.cluster_class_map(idx);
                if iclass > 0
                    desc = [desc ' [' inst.main_window.clustering_results.classes(iclass).description ']'];
                end
                set(inst.desc(idx), 'String', desc);
            end
            set(inst.main_window.window, 'pointer', 'arrow');
        end
        
        function clustering_results_updated(inst, source, eventdata)
        end
        
        function update_callback(inst, source, eventdata)
            inst.update;
        end        
        
    end       
end