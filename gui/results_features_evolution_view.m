classdef results_features_evolution_view < handle
    %RESULTS_SINGLE_FEATURES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];    
        parent = [];
        main_window = [];
        axis = [];
        controls_box = [];
        feature_combo = [];
        plot_combo = []; 
        full_check = [];        
    end
    
    methods
        function inst = results_features_evolution_view(par, par_wnd)                        
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;            
            inst.main_window = inst.parent.parent;
        end
        
        function update(inst)            
            if isempty(inst.axis)                
                inst.axis = [inst.axis, axes('Parent', inst.window)];                
                inst.controls_box = uiextras.HBox('Parent', inst.window);
                set(inst.window, 'Sizes', [-1, 40]);
                
                feat = {};
                for i = 1:length(inst.main_window.features)
                    att = inst.main_window.config.FEATURES{inst.main_window.features(i)};
                    feat = [feat, att{2}];
                end
                
                % create other controls            
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Feature:');            
                inst.feature_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', feat, 'Callback', @inst.update_plots);
                
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Plot:');            
                inst.plot_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', {'Lines + 95% CI', 'Lines', 'Box-plot'}, 'Callback', @inst.update_plots);
                set(inst.controls_box, 'Sizes', [100, 200, 100, 200]);
                
                state = 'on';
                if isempty(inst.main_window.traj.parent)
                    state = 'off';
                end
                inst.full_check = uicontrol('Parent', inst.controls_box, 'Style', 'checkbox', 'String', 'Full trajectories', 'Enable', state, 'Callback', @inst.update_plots);
            end

            inst.update_plots;
        end        

        function update_plots(inst, source, event_data)            
            plt = get(inst.plot_combo, 'value');
            grps = inst.parent.groups;
            full = get(inst.full_check, 'value');            
            feat = get(inst.feature_combo, 'value');
            
            if full
                traj = inst.main_window.traj.parent;                
            else
                traj = inst.main_window.traj;                
            end
            
            t0 = arrayfun( @(idx) traj.items(idx).end_time, 1:traj.count );                
            if inst.parent.block_end < inst.parent.max_time || inst.parent.block_begin > 0
                sel0 = (t0 >= inst.parent.block_begin & t0 <= inst.parent.block_end);
            else
                sel0 = ones(1, traj.count);                
            end            
            
            feat_val = traj.compute_features(inst.main_window.features(feat));                
            groups = arrayfun( @(t) t.group, traj.items);       
            trials = arrayfun( @(t) t.trial, traj.items);         
            if inst.parent.trial_type > 0
                types = arrayfun( @(t) t.trial_type, traj.items);    
            else
                types = zeros(1, traj.count);
            end
            
            vals = {};
            xlbls = {};
            set(inst.main_window.window, 'currentaxes', inst.axis);
            cla;            
            hold off;
            for g = 1:length(grps)
                if ~grps(g) 
                    continue;
                end
                if g == 1
                    sel = sel0;
                else
                    sel = sel0 & (groups == g - 1);                        
                end
                % collect all the values for each trial
                vals_trial = {};
                for t = 1:inst.main_window.config.TRIALS
                    % filter per trial
                    if inst.parent.trials(t) == 1
                        if inst.parent.blocks > 1
                            for b = 1:inst.parent.blocks                                
                                vals_trial = [vals_trial, ...
                                    feat_val(sel & trials == t & types == inst.parent.trial_type & ...
                                        t0 >= inst.parent.block_begin + (b - 1)*inst.parent.block_length & ...
                                        t0 <= inst.parent.block_begin + b*inst.parent.block_length ...                                        
                                )];
                            
                                if g == 1
                                    xlbls = [xlbls, ['T' num2str(t) '|' num2str(b) ]];
                                end
                            end
                        else                            
                            vals_trial = [vals_trial, feat_val(sel & trials == t & types == inst.parent.trial_type)];
                            if g == 1
                                xlbls = [xlbls, ['T' num2str(t)]];
                            end
                        end
                    end
                end
                
                switch(plt)
                    case 1
                        % average each value                        
                        shadedErrorBar( 1:length(vals_trial) ....
                            , arrayfun( @(idx) mean(vals_trial{idx}), 1:length(vals_trial)) ...
                            , arrayfun( @(idx) 1.95*std(vals_trial{idx})/sqrt(length(vals_trial{idx})), 1:length(vals_trial)) ...
                            , {'Color', inst.parent.groups_colors(g, :), 'LineWidth', 2}, 1);
                        set(gca, 'XTick', 1:length(vals_trial), 'XTickLabel', xlbls);
                    case 2    
                        % average each value                        
                        plot( 1:length(vals_trial) ....
                            , arrayfun( @(idx) mean(vals_trial{idx}), 1:length(vals_trial)) ...
                            , '-', 'Color', inst.parent.groups_colors(g, :), 'LineWidth', 2, 'XTickLabel', xlbls);                                                        
                    case 3                        
                end
                
                hold on;
            end                
        end
    end        
end