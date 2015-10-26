classdef edit_tags_window < handle
    properties(GetAccess = 'public', SetAccess = 'protected')
        % the configuration that the user selected (see /config folder)
        tags = [];
        result = 0;
        % window handle        
        window = []; 
        % controls
        tags_listbox = [];
        ok_button = []
        del_button = [];
        new_button = [];
        cancel_button = [];
    end           
    
    methods
        function inst = edit_tags_window()
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout'));
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout/Patch'));            
        end
        
        function res = show(inst, config)
            inst.result = 0;
            inst.tags = config.TAGS;
                            
            w = 400;
            h = 500;
            hb = 20;
            vb = 20;
            
            scr_sz = get(0, 'ScreenSize');
                         
            inst.window = dialog('name', 'Edit tags', ...
                'Position', [ (scr_sz(3) - w)/2, (scr_sz(4) - h)/2, w, h] ...
            );                    
                          
            y = h - vb;
            y = y - 350;                        
            inst.tags_listbox = uicontrol('Parent', inst.window, 'Style', 'listbox', ...
                'Position', [hb, y, w - 2*hb, 350], 'Callback', {@inst.tags_listbox_callback});
            y = y - 30;
            
            inst.new_button = uicontrol('Parent', inst.window, 'String', 'New', ...
                'Callback', {@inst.new_callback}, 'Position', [hb, y, 60, 30]);            
            inst.del_button = uicontrol('Parent', inst.window, 'String', 'Delete', ...
                'Callback', {@inst.delete_callback}, 'Position', [2*hb + 60, y, 60, 30]);                        
            
            inst.ok_button = uicontrol('Parent', inst.window, 'String', 'Ok', ...
                'Callback', {@inst.ok_callback}, 'Position', [40, 20, 130, 30]);
            inst.cancel_button = uicontrol('Parent', inst.window, 'String', 'Cancel', ...
                'Callback', {@inst.cancel_callback}, 'Position', [230, 20, 130, 30]);
            
            inst.update;
            
            uiwait(inst.window);
            
            res = inst.result;
            if res
                config.set_tags(inst.tags);
            end
        end       
        
        function update(inst)
            strs = {};
            for i = 1:length(inst.tags)
                tmp = inst.tags(i);
                strs = [strs, [tmp.abbreviation ' - ' tmp.description '[' tmp.type ']']];
            end
            set(inst.tags_listbox, 'Value', 1);            
            set(inst.tags_listbox, 'String', strs);
            inst.tags_listbox_callback;
        end
        
        function tags_listbox_callback(inst, source, eventdata)
            sel = get(inst.tags_listbox, 'Value');            
            if ~isempty(sel) && sel > 0
                set(inst.del_button, 'Enable', 'on');
            else
                set(inst.del_button, 'Enable', 'off');
            end               
        end
        
        function new_callback(inst, source, eventdata)
            
        end
        
        function delete_callback(inst, source, eventdata)
            sel = get(inst.tags_listbox, 'Value');            
            inst.tags(sel) = [];
            inst.update;
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