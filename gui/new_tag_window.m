classdef new_tag_window < handle
    properties(GetAccess = 'public', SetAccess = 'protected')
        % the configuration that the user selected (see /config folder)
        new_tag = [];
        result = 0;
        % window handle        
        window = []; 
        % controls
        abbrev_edit = [];
        description_edit = [];
        type_combo = [];
        ok_button = []
        cancel_button = [];
    end           
    
    methods
        function inst = new_tag_window()
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout'));
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout/Patch'));            
        end
        
        function res = show(inst, config)
            inst.result = 0;
                            
            w = 400;
            h = 250;
            hb = 20;
            vb = 20;
            
            scr_sz = get(0, 'ScreenSize');
                         
            inst.window = dialog('name', 'New tag', 'WindowStyle', 'modal', ...
                'Position', [ (scr_sz(3) - w)/2, (scr_sz(4) - h)/2, w, h] ...
            );                    
                          
            y = h - vb;
            y = y - 20;                        
            uicontrol('Parent', inst.window, 'Style', 'text', 'String', 'Abbreviation:', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);
            y = y - 16;
            inst.abbrev_edit = uicontrol('Parent', inst.window, 'Style', 'edit', 'String', '', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, 50, 25]);                        
            
            y = y - 30;
            uicontrol('Parent', inst.window, 'Style', 'text', 'String', 'Description:', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);
            y = y - 16;
            inst.description_edit = uicontrol('Parent', inst.window, 'Style', 'edit', 'String', '', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);                        
                                    
            y = y - 30;
            uicontrol('Parent', inst.window, 'Style', 'text', 'String', 'Type:', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);         
            y = y - 22;
            inst.type_combo = uicontrol('Parent', inst.window, 'Style', 'popupmenu', 'Position', [hb, y, w - 2*hb, 30], ...
                'String', config.TAG_TYPES_DESCRIPTION);
            
            inst.ok_button = uicontrol('Parent', inst.window, 'String', 'Ok', ...
                'Callback', {@inst.ok_callback}, 'Position', [40, 20, 130, 30]);
            inst.cancel_button = uicontrol('Parent', inst.window, 'String', 'Cancel', ...
                'Callback', {@inst.cancel_callback}, 'Position', [230, 20, 130, 30]);
                        
            uiwait(inst.window);
            
            res = inst.result;            
        end       
        
        
        function cancel_callback(inst, source, eventdata)
            delete(inst.window);
        end
        
        function ok_callback(inst, source, eventdata)
            abbrev = get(inst.abbrev_edit, 'String');
            if isempty(abbrev)
                msgbox('Please provide an abbreviation.');
                return;
            end
            if length(abbrev) > 3
                msgbox('Please limit the abbreviation to 3 characters.');
                return;
            end 
            
            desc = get(inst.description_edit, 'String');
            if isempty(desc)
                msgbox('Please provide a description.');
                return;
            end
            
            type = get(inst.type_combo, 'Value');
            
            % alles gut
            inst.new_tag = tag(abbrev, desc, type);
                        
            inst.result = 1;            
            delete(inst.window);                     
        end
    end    
end