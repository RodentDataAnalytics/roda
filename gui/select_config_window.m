classdef select_config_window < handle
    properties(GetAccess = 'public', SetAccess = 'protected')
        % the configuration that the user selected (see /config folder)
        selected_config = [];
        % window handle
        window = [];   
        % other control handles
        config_combo = [];
        ok_button = [];
        cancel_button = [];
        datadir_edit = [];
        outdir_edit = [];
        % list of all configurations (instance of 'configurations' class)
        configs = [];
        % previously selected configuration x directories (to not force the
        % user to select it everytime)
        saved_selection = [];
        % file name used to store data between sessions
        persist_fn = [];
        % result of the dialog (1 if Ok, 0 if cancelled/error)
        result = 0;
    end           
    
    methods
        function inst = select_config_window()
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout'));
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout/Patch'));          
            inst.configs = configurations.instance;            
            inst.persist_fn = [globals.DATA_DIRECTORY '/' 'conf_sel.mat'];                        
        end
        
        function res = show(inst)
            inst.result = 0;
            
            % load previously selected data            
            if exist(inst.persist_fn, 'file')
                load(inst.persist_fn);       
                inst.saved_selection = tmp;
            else
                idx = 1;
                inst.saved_selection = containers.Map('KeyType', 'char', 'ValueType', 'any');
            end
       
            w = 400;
            h = 300;
            hb = 20;
            vb = 20;            
            
            scr_sz = get(0, 'ScreenSize');
             
            inst.window = dialog('name', 'Select configuration', ...
                'Position', [ (scr_sz(3) - w)/2, (scr_sz(4) - h)/2, w, h] ...
            );
                    
            y = h - vb;
            y = y - 20;
            uicontrol('Parent', inst.window, 'Style', 'text', 'String', 'Configuration:', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);
            y = y - 30;
            inst.config_combo = uicontrol('Parent', inst.window, 'Style', 'popupmenu', 'Position', [hb, y, w - 2*hb, 30], ...
                'String', inst.configs.names, 'Callback', {@inst.config_change_callback});
            if idx <= length(inst.configs.names)
                set(inst.config_combo, 'Value', idx);
            end
            
            y = y - 30;
            uicontrol('Parent', inst.window, 'Style', 'text', 'String', 'Data folder:', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);
            y = y - 25;
            inst.datadir_edit = uicontrol('Parent', inst.window, 'Style', 'edit', 'String', '', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb - 25, 25]);            
            uicontrol('Parent', inst.window, 'Style', 'pushbutton', 'String', '...', ...
                'HorizontalAlignment', 'left', 'Position', [w - hb - 25, y, 25, 25], 'Callback', {@inst.select_datadir_callback});
                        
            y = y - 30;
            uicontrol('Parent', inst.window, 'Style', 'text', 'String', 'Output folder:', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);
            y = y - 25;
            inst.outdir_edit = uicontrol('Parent', inst.window, 'Style', 'edit', 'String', '', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb - 25, 25]);            
            uicontrol('Parent', inst.window, 'Style', 'pushbutton', 'String', '...', ...
                'HorizontalAlignment', 'left', 'Position', [w - hb - 25, y, 25, 25], 'Callback', {@inst.select_outputdir_callback});
            
            inst.ok_button = uicontrol('Parent', inst.window, 'String', 'Ok', ...
                'Callback', {@inst.ok_callback}, 'Position', [40, 20, 130, 30]);
            inst.cancel_button = uicontrol('Parent', inst.window, 'String', 'Cancel', ...
                'Callback', {@inst.cancel_callback}, 'Position', [230, 20, 130, 30]);
                             
            config_change_callback(inst);
            uiwait(inst.window);
            
            res = inst.result;
        end
        
        function config_change_callback(inst, source, eventdata)
            % see if we already have pre-selected directories
            idx = get(inst.config_combo, 'value');
            inst.selected_config = inst.configs.items{idx};
            
            if isKey(inst.saved_selection, inst.selected_config.DESCRIPTION)
                dirs = inst.saved_selection(inst.selected_config.DESCRIPTION);
                set(inst.datadir_edit, 'String', dirs{1}); 
                set(inst.outdir_edit, 'String', dirs{2});
            else
                set(inst.datadir_edit, 'String', ''); 
                set(inst.outdir_edit, 'String', '');
            end
        end
    
        
        function select_datadir_callback(inst, source, eventdata)
            set(inst.datadir_edit, 'String', uigetdir(get(inst.datadir_edit, 'String'), 'Select data directory'));
        end
        
        function select_outputdir_callback(inst, source, eventdata)
            set(inst.outdir_edit, 'String', uigetdir(get(inst.outdir_edit, 'String'), 'Select output directory'));
        end        
        
        function cancel_callback(inst, source, eventdata)
            delete(inst.window);
        end
        
        function ok_callback(inst, source, eventdata)
            idx = get(inst.config_combo, 'value');
            
            % validate directories
            data_dir = get(inst.datadir_edit, 'String');
            out_dir = get(inst.outdir_edit, 'String');
            if ~exist(data_dir, 'dir')
                msgbox('Invalid data directory!');
                return;
            end
            if ~exist(out_dir, 'dir')
                msgbox('Invalid output directory!');
                return;
            end 
            
            % save selection for next time
            temp = {data_dir, out_dir};
            inst.saved_selection(inst.selected_config.DESCRIPTION) = temp;
            
            home_dir = globals.DATA_DIRECTORY;
            if ~exist(home_dir, 'dir')                
                mkdir(home_dir)
            end
            tmp = inst.saved_selection;
            save(inst.persist_fn, 'tmp', 'idx'); 
            
            % load data
            res = cache_load_trajectories(inst.selected_config, data_dir);
            if ~res
                msgbox('Error loading data');
                return;
            end
            
            % set other parameters
            inst.selected_config.set_output_directory(out_dir);
            inst.result = 1;
            
            delete(inst.window);                        
        end
    end    
end