classdef clustering_statistics_view < handle
    %CLUSTERING_STATISTICS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        window = [];    
        parent = [];
        main_window = [];
        grid = [];
        panels = [];
        clustering_results = [];
        
        unknown_plot = [];        
        errors_plot = [];
        final_nclus = [];
        cluster_sizes_plot = [];
    end
    
    methods
        function inst = clustering_statistics_view(par, par_wnd)            
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;
            inst.main_window = inst.parent.parent;
        end
               
        function update(inst)
            if isempty(inst.grid) && ~isempty(inst.parent.clustering_results)              
                inst.grid = uiextras.Grid('Parent', inst.window);
                
                hbox = uiextras.VBox('Parent', inst.grid);                   
                inst.unknown_plot = axes('Parent', uicontainer('Parent', hbox));
                uicontrol('Parent', hbox, 'Style', 'text', 'String', '% Unknown');
                set(hbox, 'Sizes', [-1, 20]);
                
                hbox = uiextras.VBox('Parent', inst.grid);                        
                inst.errors_plot = axes('Parent', uicontainer('Parent', hbox));
                uicontrol('Parent', hbox, 'Style', 'text', 'String', '% Errors');
                set(hbox, 'Sizes', [-1, 20]);
                
                hbox = uiextras.VBox('Parent', inst.grid);                        
                inst.final_nclus = axes('Parent', uicontainer('Parent', hbox));
                uicontrol('Parent', hbox, 'Style', 'text', 'String', 'Final # clusters');                
                set(hbox, 'Sizes', [-1, 20]);
                
%                 hbox = uiextras.VBox('Parent', inst.grid);                        
%                 inst.cluster_sizes_plot = axes('Parent', uicontainer('Parent', hbox));                                                                  
%                 uicontrol('Parent', hbox, 'Style', 'text', 'String', 'Cluter size distr.');                                                
%                 set(hbox, 'Sizes', [-1, 20]);
%                 
                set(inst.grid, 'RowSizes', [-1 -1], 'ColumnSizes', [-1 -1]);                                               
            end                                 
            
            if ~isempty(inst.parent.clustering_results)
                inst.update_plots;
            end
        end
        
        function update_plots(inst)            
            n = length(inst.parent.clustering_results);
            nclus = inst.parent.clusters_min:inst.parent.clusters_max;
            
            %% unknown plot
            unk = arrayfun( @(idx) inst.parent.clustering_results(idx).punknown, 1:n)*100;
            set(inst.main_window.window, 'currentaxes', inst.unknown_plot);                
            plot(nclus, unk, '-k', 'LineWidth', 2);   
            
            %% errors plot
            err = arrayfun( @(idx) inst.parent.clustering_results(idx).perrors, 1:n)*100;
            set(inst.main_window.window, 'currentaxes', inst.errors_plot);                
            plot(nclus, err, '-k', 'LineWidth', 2);
            
            %% final clusters plot
            nclus_final = arrayfun( @(idx) inst.parent.clustering_results(idx).nclusters, 1:n);            
            set(inst.main_window.window, 'currentaxes', inst.final_nclus);                
            plot(nclus, nclus_final, '-k', 'LineWidth', 2);   
            inst.clustering_results_updated;            
        end 
        
        function clustering_results_updated(inst, source, eventdata)            
%             szs = inst.main_window.clustering_results.cluster_sizes;            
%             set(inst.main_window.window, 'currentaxes', inst.cluster_sizes_plot);                
%             hist(szs, 10);
        end
    end    
end