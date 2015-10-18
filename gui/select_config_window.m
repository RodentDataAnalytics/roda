classdef select_config_window < handle
    properties(GetAccess = 'public', SetAccess = 'protected')
        % the configuration that the user selected (see /config folder)
        selected_config = [];
        % window handle
        window = [];   
        % other control handles    
        description_edit = [];
        config_combo = [];
        subconfig_combo = [];        
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
            h = 350;
            hb = 20;
            vb = 20;            
            
            scr_sz = get(0, 'ScreenSize');
             
            inst.window = dialog('name', 'Create new configuration', ...
                'Position', [ (scr_sz(3) - w)/2, (scr_sz(4) - h)/2, w, h] ...
            );
                                
            y = h - vb;
            y = y - 20;            
            inst.description_edit = uicontrol('Parent', inst.window, 'Style', 'text', 'String', 'Name:', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);
            y = y - 16;
            inst.description_edit = uicontrol('Parent', inst.window, 'Style', 'edit', 'String', '', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);                        
            
            y = y - 30;
            uicontrol('Parent', inst.window, 'Style', 'text', 'String', 'Base configuration:', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);
            y = y - 22;
            inst.config_combo = uicontrol('Parent', inst.window, 'Style', 'popupmenu', 'Position', [hb, y, w - 2*hb, 30], ...
                'String', inst.configs.names, 'Callback', {@inst.config_change_callback});
            if idx <= length(inst.configs.names)
                set(inst.config_combo, 'Value', idx);
            end
            
            y = y - 30;
            uicontrol('Parent', inst.window, 'Style', 'text', 'String', 'Sub-configuration:', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);
            y = y - 22;
            inst.subconfig_combo = uicontrol('Parent', inst.window, 'Style', 'popupmenu', 'Position', [hb, y, w - 2*hb, 30]);
            
            y = y - 30;
            uicontrol('Parent', inst.window, 'Style', 'text', 'String', 'Data folder:', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);
            y = y - 16;
            inst.datadir_edit = uicontrol('Parent', inst.window, 'Style', 'edit', 'String', '', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb - 25, 25]);            
            uicontrol('Parent', inst.window, 'Style', 'pushbutton', 'String', '...', ...
                'HorizontalAlignment', 'left', 'Position', [w - hb - 25, y, 25, 25], 'Callback', {@inst.select_datadir_callback});
                        
            y = y - 30;
            uicontrol('Parent', inst.window, 'Style', 'text', 'String', 'Output folder:', ...
                'HorizontalAlignment', 'left', 'Position', [hb, y, w - 2*hb, 25]);
            y = y - 16;
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
            
            % update sub-config combo
            subconfs = inst.selected_config.TAGS_CONFIG;
            strs = {};
            for i = 1:length(subconfs)
                strs = [strs, subconfs{i}(1)];
            end            
            set(inst.subconfig_combo, 'String', strs);
            
            if isKey(inst.saved_selection, inst.selected_config.DESCRIPTION)
                props = inst.saved_selection(inst.selected_config.DESCRIPTION);
                set(inst.datadir_edit, 'String', props{1}); 
                set(inst.outdir_edit, 'String', props{2});
                set(inst.subconfig_combo, 'Value', props{3});
            else
                set(inst.datadir_edit, 'String', ''); 
                set(inst.outdir_edit, 'String', '');
                set(inst.subconfig_combo, 'Value', 1);
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
            sub_idx = get(inst.subconfig_combo, 'value');
            
            % need a description
            desc = get(inst.description_edit, 'String');
            if isempty(desc)
                msgbox('Please provide a description.');
                return;
            end
            
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
            temp = {data_dir, out_dir, sub_idx};
            inst.saved_selection(inst.selected_config.DESCRIPTION) = temp;
            
            home_dir = globals.DATA_DIRECTORY;
            if ~exist(home_dir, 'dir')                
                mkdir(home_dir)
            end
            tmp = inst.saved_selection;
            save(inst.persist_fn, 'tmp', 'idx'); 
                        
            inst.selected_config.set_description(desc);
            inst.selected_config.set_subconfig(inst.selected_config.TAGS_CONFIG{sub_idx});                       
            
            % load the data
            h = waitbar(0, 'Importing data...', 'CreateCancelBtn', 'setappdata(gcbf, ''cancel'', 1);');
            setappdata(h, 'cancel', 0);            
            cache_load_trajectories(inst.selected_config, data_dir, ...
                'ProgressCallback', ...
                @(mess, prog) return2nd(waitbar(prog, h, mess), getappdata(h, 'cancel')) ...
                );
            delete(h);
                                    
            % set other parameters            
            inst.selected_config.set_output_directory(out_dir);
            inst.result = 1;
            
            delete(inst.window);                        
        end
    end    
end