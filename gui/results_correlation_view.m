classdef results_correlation_view < handle
%RESULTS_CORRELATION Summary of this function goes here
%   Detailed explanation goes here
   
    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];    
        main_window = [];
        parent = [];
        axis = [];
        controls_box = [];
        feature_combo = [];
        plot_combo = []; 
        full_check = [];        
        strings = []
    end
    
    methods
        function inst = results_correlation_view(par, par_wnd)                        
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;            
            inst.main_window = inst.parent.parent;
        end
        
        function update(inst)           
            if isempty(inst.axis)                
                inst.axis = axes('Parent', uicontainer('Parent', inst.window));                
                inst.controls_box = uiextras.HBox('Parent', inst.window);
                set(inst.window, 'Sizes', [-1, 40]);
                
                feat = {};
                for i = 1:length(inst.main_window.config.SELECTED_FEATURES)                    
                    feat = [feat, inst.main_window.config.SELECTED_FEATURES(i).description];
                end
                
                % create other controls                            
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Plot:');            
                inst.plot_combo = uicontrol('Parent', inst.controls_box, ...
                                            'Style', 'popupmenu', ...
                                            'String', {'Features-Features', 'Features-Clusters', 'Groups-Clusters', 'Clusters-Clusters'}, ...                                            
                                            'Callback', @inst.update_plots);
                
               
                state = 'on';
                if isempty(inst.main_window.traj.parent)
                    state = 'off';
                end
                inst.full_check = uicontrol('Parent', inst.controls_box, 'Style', 'checkbox', 'String', 'Full trajectories', 'Enable', state, 'Callback', @inst.update_plots);
                set(inst.controls_box, 'Sizes', [100, 200, 100]);
            end

            inst.update_plots;
        end        

        function update_plots(inst, source, event_data)            
            inst.clear;
            plt = get(inst.plot_combo, 'value');
            if plt == 2
                set(inst.full_check, 'value', 0);
            end
            
            % grps = inst.parent.groups;
            full = get(inst.full_check, 'value');                                    
            
            if full
                traj = inst.main_window.traj.parent;                
            else
                traj = inst.main_window.traj;                
            end
            trials = arrayfun( @(t) t.trial, traj.items);       
            groups = arrayfun( @(t) t.group, traj.items);    
            if inst.parent.trial_type > 0
                types = arrayfun( @(t) t.trial_type, traj.items);    
            else
                types = zeros(1, traj.count);
            end
            
            if inst.parent.block_end < inst.parent.max_time || inst.parent.block_begin > 0
                t0 = arrayfun( @(idx) traj.items(idx).end_time, 1:traj.count );
                sel0 = (t0 >= inst.parent.block_begin & t0 <= inst.parent.block_end);
            else
                sel0 = ones(1, traj.count);                
            end
            
            vals = [];
            hor_str = {};
            ver_str = {};
            
            switch plt
                case 1
                    % feature-feature                    
                    feat_val = traj.compute_features(inst.main_window.config.SELECTED_FEATURES);  
                    vals = corrcoef(feat_val(sel0 & inst.parent.trials(trials) == 1 & types == inst.parent.trial_type, :));
                        
                    for fi = 1:length(inst.main_window.config.SELECTED_FEATURES)
                        % normalize feature                        
                        feat = inst.main_window.config.SELECTED_FEATURES(fi);
                        ver_str = [ver_str, [feat.description ' [' feat.abbreviation ']']];
                        hor_str = [hor_str, feat.abbreviation];
                    end                    
                case 2            
                    % features-clusters                    
                    if ~isempty(inst.main_window.clustering_results)
                        vals = zeros(length(inst.main_window.config.SELECTED_FEATURES), inst.main_window.clustering_results.nclusters);
                        for fi = 1:length(inst.main_window.config.SELECTED_FEATURES)
                            feat_val = traj.compute_features(inst.main_window.config.SELECTED_FEATURES(fi));                            
                            for ic = 1:inst.main_window.clustering_results.nclusters                                               
                                vals(fi, ic) = mean(feat_val(sel0 & inst.main_window.clustering_results.cluster_index == ic & inst.parent.trials(trials) == 1 & types == inst.parent.trial_type));
                            end
                            % normalize feature
                            vals(fi, :) = vals(fi, :) ./ repmat(norm(vals(fi, :)), 1, size(vals, 2));                                                  
                            ver_str = [ver_str, inst.main_window.config.SELECTED_FEATURES(fi).description];
                        end
                       hor_str = arrayfun( @(idx) sprintf('Cluster %d', idx), 1:inst.main_window.clustering_results.nclusters, 'UniformOutput', 0);                       
                    end           
                case 3
                    % groups-clusters
                    if ~isempty(inst.main_window.clustering_results)
                        vals = zeros(inst.main_window.config.GROUPS, inst.main_window.clustering_results.nclusters);
                        for gi = 1:inst.main_window.config.GROUPS                           
                            for ic = 1:inst.main_window.clustering_results.nclusters                                               
                                vals(gi, ic) = sum(sel0 & inst.main_window.clustering_results.cluster_index == ic & groups == gi & inst.parent.trials(trials) == 1 & types == inst.parent.trial_type);
                            end                                                        
                            % vals(gi, :) = vals(gi, :) ./ repmat(norm(vals(gi, :)), 1, size(vals, 2));                      
                        end
                        
                        % normalize feature
                        for ic = 1:inst.main_window.clustering_results.nclusters                                               
                            vals(:, ic) = vals(:, ic) ./ repmat(norm(vals(:, ic)), size(vals, 1), 1);                                                                   
                        end
                        hor_str = arrayfun( @(idx) sprintf('Cluster %d', idx), 1:inst.main_window.clustering_results.nclusters, 'UniformOutput', 0);                       
                        if isempty(inst.main_window.config.GROUPS_DESCRIPTION)
                            ver_str = arrayfun( @(idx) sprintf('Group %d', idx), 1:inst.main_window.config.GROUPS, 'UniformOutput', 0);                                          
                        else
                            ver_str = arrayfun( @(idx) sprintf('Group %s', inst.main_window.config.GROUPS_DESCRIPTION{idx}), 1:inst.main_window.config.GROUPS, 'UniformOutput', 0);                             
                        end
                    end
                case 4
                    % clusters-clusters
                    if ~isempty(inst.main_window.clustering_results)
                        % measure the correlation between two matrices
                        % defined by the first N elements of two clusters
                        % (where N is the size of the smallest cluster).
                        % Sort elements by their respective distance to the
                        % centroids
                        nc = inst.main_window.clustering_results.nclusters;
                          
                        feat_val = inst.main_window.config.clustering_feature_values;
                        
                        vals = zeros(nc, nc);
                        for ic = 1:nc
                            for jc = ic:nc
                                if ic == jc
                                    vals(ic, jc) = 1;
                                    vals(jc, ic) = 1;
                                else
                                    sel1 = find(inst.main_window.clustering_results.cluster_index == ic);
                                    sel2 = find(inst.main_window.clustering_results.cluster_index == jc);
                
                                    feat_norm1 = max(feat_val(sel1, :)) - min(feat_val(sel1, :));            
                                    feat_norm2 = max(feat_val(sel2, :)) - min(feat_val(sel2, :));            
                                    
                                    dist1 = sum(((feat_val(sel1, :) - repmat(inst.main_window.clustering_results.centroids(:, ic)', length(sel1), 1)) ./ repmat(feat_norm1, length(sel1), 1)).^2, 2);
                                    dist2 = sum(((feat_val(sel2, :) - repmat(inst.main_window.clustering_results.centroids(:, jc)', length(sel2), 1)) ./ repmat(feat_norm2, length(sel2), 1)).^2, 2);
                
                                    [~, ord] = sort(dist1);
                                    sel1 = sel1(ord);
                                    [~, ord] = sort(dist2);
                                    sel2 = sel2(ord);
                                    
                                    n1 = length(sel1);
                                    n2 = length(sel2);
                                    n = min(n1, n2);                                
                                    
                                    % compute the correlation between n
                                    % elements
                                    rho = corr2( feat_val(sel1(1:n), :), feat_val(sel2(1:n), :) );
                                    vals(ic, jc) = rho;
                                    vals(jc, ic) = rho;                                    
                                end
                            end
                        end
                        hor_str = arrayfun( @(idx) sprintf('Cluster %d', idx), 1:inst.main_window.clustering_results.nclusters, 'UniformOutput', 0);                       
                        ver_str = hor_str;
                    end
            end
            
            if ~isempty(vals)
                set(inst.main_window.window, 'currentaxes', inst.axis);
                cla;
                hold off;
                imagesc(abs(vals));            %# Create a colored plot of the matrix values
                colormap(flipud(gray));  %# Change the colormap to gray (so higher values are
                         %#   black and lower values are white)

                textStrings = num2str(vals(:),'%0.2f');  %# Create strings from the matrix values
                textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
                [x, y] = meshgrid(1:size(vals, 2), 1:size(vals, 1));   %# Create x and y coordinates for the strings
                inst.strings = text(x(:), y(:), textStrings(:), ...      %# Plot the strings
                                'HorizontalAlignment', 'center', 'Parent', inst.axis );
                midValue = mean(get(gca, 'CLim'));  %# Get the middle value of the color range
                textColors = repmat(vals(:) > midValue, 1, 3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
                set(inst.strings, {'Color'}, num2cell(textColors, 2));  %# Change the text colors

                set(gca,'XTick', 1:size(vals, 2), ...                         %# Change the axes tick marks
                        'XTickLabel', hor_str,...  %#   and tick labels
                        'YTick', 1:size(vals, 1), ...
                        'YTickLabel', ver_str, ...
                        'TickLength', [0 0]);
            end
        end
        
        function clear(inst)
            if ~isempty(inst.strings)
                delete(inst.strings);
                inst.strings = [];
            end
        end
    end        
end