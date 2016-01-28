classdef map_clusters_window < handle
    properties(GetAccess = 'public', SetAccess = 'protected')
        % the configuration that the user selected (see /config folder)
        tags = [];
        mapping = [];
        result = 0;
        config = [];
        % window handle        
        window = []; 
        % controls
        listbox = [];
        ok_button = []
        change_button = [];
        cancel_button = [];
        nclusters = 0;
    end           
    
    methods
        function inst = map_clusters_window()
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout'));
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout/Patch'));            
        end
        
        function [res, new_mapping]  = show(inst, nclusters, tags, mapping, varargin)
            inst.result = 0;
            new_mapping = [];
            
            [tag_type] = process_options(varargin, 'TagType', base_config.TAG_TYPE_BEHAVIOUR_CLASS);
            
            inst.nclusters = nclusters;
            if tag_type > 0
                % filter the tags
            
                for i = 1:length(tags)
                    if tags(i).type == tag_type
                        inst.tags = [inst.tags, tags(i)];
                    end
                end
            else
                inst.tags = tags;
            end
            inst.mapping = mapping;
                            
            w = 400;
            h = 500;
            hb = 20;
            vb = 20;
            
            scr_sz = get(0, 'ScreenSize');
                         
            inst.window = dialog('name', 'Clusters <-> Classes', 'WindowStyle', 'modal', ...
                'Position', [ (scr_sz(3) - w)/2, (scr_sz(4) - h)/2, w, h] ...
            );                    
                          
            y = h - vb;
            y = y - 350;                        
            inst.tags_listbox = uicontrol('Parent', inst.window, 'Style', 'listbox', ...
                'Position', [hb, y, w - 2*hb, 350], 'Callback', {@inst.listbox_callback});
            y = y - 30;
            
            inst.change_button = uicontrol('Parent', inst.window, 'String', 'Change', ...
                'Callback', {@inst.change_callback}, 'Position', [hb, y, 60, 30]);            
            
            inst.ok_button = uicontrol('Parent', inst.window, 'String', 'Ok', ...
                'Callback', {@inst.ok_callback}, 'Position', [40, 20, 130, 30]);
            inst.cancel_button = uicontrol('Parent', inst.window, 'String', 'Cancel', ...
                'Callback', {@inst.cancel_callback}, 'Position', [230, 20, 130, 30]);
            
            inst.update;
            
            uiwait(inst.window);
            
            res = inst.result;            
            if res
                new_mapping = inst.mapping;
            end
        end       
        
        function update(inst)
            strs = {};
            for i = 1:inst.nclusters                                                
                strs = [strs, ['Cluster ' num2str(i) ' [' inst.tags(inst.mapping(i)).description ']']];
            end
            set(inst.listbox, 'Value', 1);            
            set(inst.listbox, 'String', strs);
            inst.listbox_callback;
        end
        
        function listbox_callback(inst, source, eventdata)
            sel = get(inst.tags_listbox, 'Value');            
            if ~isempty(sel) && sel > 0
                set(inst.change_button, 'Enable', 'on');
            else
                set(inst.change_button, 'Enable', 'off');
            end               
        end
        
        function change_callback(inst, source, eventdata)
            new_wnd = new_tag_window;
            if new_wnd.show(inst.config)
                inst.tags = [inst.tags, new_wnd.new_tag];
                inst.update;
            end
        end
                
        function cancel_callback(inst, source, eventdata)
            delete(inst.window);
        end
        
        function ok_callback(inst, source, eventdata)
            inst.result = 1;            
            delete(inst.window);                     
        end
    end    
end