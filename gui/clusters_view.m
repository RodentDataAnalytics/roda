classdef clusters_view < handle
    %RESULTS_SINGLE_FEATURES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];    
        parent = [];
        main_window = [];
        grid = [];
        panels = [];
        axis = [];
        controls_box = [];       
        cluster_combo = [];
        feat1_combo = [];                
        feat2_combo = [];        
        feat3_combo = [];        
    end
    
    methods
        function inst = clusters_view(par, par_wnd)            
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;
            inst.main_window = inst.parent.parent;
        end
               
        function update(inst)
            if isempty(inst.grid)                
                inst.grid = uiextras.Grid('Parent', inst.window);
                inst.controls_box = uiextras.HBox('Parent', inst.window);
                set(inst.window, 'Sizes', [-1, 40]);                
                inst.axis = [];
                
                for i = 1:9
                    if i == 1 || i == 5 || i == 9
                        uicontrol('Parent', inst.grid, 'Style', 'text', 'String', '-');        
                    else
                        hbox = uicontainer('Parent', inst.grid);
                        inst.axis = [inst.axis, axes('Parent', hbox)];                    
                    end
                end                                
                
                set(inst.grid, 'RowSizes', [-1 -1 -1], 'ColumnSizes', [-1 -1 -1]);
                
                % create other controls            
                feat = {};
                for i = 1:length(inst.main_window.features)
                    att = inst.main_window.config.FEATURES{inst.main_window.features(i)};
                    feat = [feat, att{2}];
                end
                
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Feature 1:');            
                inst.feat1_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', feat, 'Callback', @inst.update_plots);
                set(inst.feat1_combo, 'value', 1);
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Feature 2:');            
                inst.feat2_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', feat, 'Callback', @inst.update_plots);
                set(inst.feat2_combo, 'value', 2);
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Feature 3:');            
                inst.feat3_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', feat, 'Callback', @inst.update_plots);
                set(inst.feat3_combo, 'value', 3);
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Cluster:');            
                inst.cluster_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', '', 'Callback', @inst.update_plots);
                
                
                set(inst.controls_box, 'Sizes', [80, 120, 80, 120, 80, 120, 80, 120]);
                
                inst.clustering_results_updated;
            else                                    
                inst.update_plots;
            end
        end       
        
        function update_plots(inst, source, event_data)            
            feat1 = get(inst.feat1_combo, 'value');
            feat2 = get(inst.feat2_combo, 'value');
            feat3 = get(inst.feat3_combo, 'value');
            
            clus = get(inst.cluster_combo, 'value') - 1;           
            if clus > 0
                % filter by cluster
                cluster_mask = (inst.main_window.clustering_results.cluster_index == clus);
            else
                cluster_mask = ones(1, inst.main_window.traj.count);
            end            
                                        
            comb = [ feat1 feat2; feat1 feat3; feat2 feat1; feat2 feat3; feat3 feat1; feat3 feat2];
            idx = 1;
            for i = 2:9
                if i == 5 || i == 9
                    continue;
                end
                
                % store values for possible later significance test                            
                vals = {};
                
                set(inst.main_window.window, 'currentaxes', inst.axis(idx));                
                hold off;                
                % plot all values in light gray first
                leg = {'Undefined'};
                h = plot(inst.main_window.features_values(:, comb(idx, 1)), inst.main_window.features_values(:, comb(idx, 2)), 'o', 'Color', [.6 .6 .6]);
                set(h,'MarkerEdgeColor','none','MarkerFaceColor', [.6 .6 .6]);
                hold on;                
                
                if clus == 0 && ~isempty(inst.main_window.clustering_results)
                    % plot each cluster individually with different colors
                    
                    clrs = cmapping(inst.main_window.clustering_results.nclusters, jet);
                    for c = 1:inst.main_window.clustering_results.nclusters
                        sel = find(inst.main_window.clustering_results.cluster_index == c);                        
                        h = plot(inst.main_window.features_values(sel, comb(idx, 1)), inst.main_window.features_values(sel, comb(idx, 2)), 'o', 'Color', clrs(c, :));
                        set(h,'MarkerEdgeColor','none','MarkerFaceColor', clrs(c, :));
                        hold on;
                        desc = ['C' num2str(c)];
                        cn = inst.main_window.clustering_results.cluster_class_map(c);
                        if cn > 0
                            desc = [desc '(' inst.main_window.clustering_results.classes(cn).description ')'];
                        end
                        leg = [leg, desc];
                    end                    
                    legend(leg, 'Location', 'eastoutside');
                else                            
                    for g = 1:inst.main_window.config.GROUPS
                        sel_pos = find(cluster_mask);

                        % plot cluster
                        h = plot(inst.main_window.features_values(sel_pos, comb(idx, 1)), inst.main_window.features_values(sel_pos, comb(idx, 2)), 'o', 'Color', inst.main_window.groups_colors(g, :));                    
                        set(h,'MarkerEdgeColor','none','MarkerFaceColor', inst.main_window.groups_colors(g, :));
                        vals = [vals, [inst.main_window.features_values(sel_pos, comb(idx, 1)), inst.main_window.features_values(sel_pos, comb(idx, 2))]];                        
                        
                        hold on;
                    end                    
                end
                att = inst.main_window.config.FEATURES{inst.main_window.features(comb(idx, 1))};
                xlabel(att{2});
                att = inst.main_window.config.FEATURES{inst.main_window.features(comb(idx, 2))};
                ylabel(att{2});                    
                idx = idx + 1;             
            end
        end   
        
        function clustering_results_updated(inst, source, eventdata)                        
            strings = {'** all **'};            
            for i = 1:inst.main_window.clustering_results.nclusters
                if inst.main_window.clustering_results.cluster_class_map(i) == 0
                    lbl = inst.main_window.config.UNDEFINED_TAG_ABBREVIATION;
                else
                    lbl = inst.main_window.clustering_results.classes(inst.main_window.clustering_results.cluster_class_map(i)).abbreviation;
                end
                nclus = sum(inst.main_window.clustering_results.cluster_index == i);
                strings = [strings, sprintf('#%d (''%s'', N=%d)', i, lbl, nclus)];  
            end
            
            set(inst.cluster_combo, 'String', strings, 'Callback', @inst.update_plots, 'Value', 1);            
            
            if ~isempty(inst.grid)           
                inst.update_plots;
            end
        end
    end       
end