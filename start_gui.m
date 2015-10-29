%% Initialize the WEKA library (java stuff)
% somewhere in the loading procedure the global variables are cleared and
% this messes up everything so don't call it more than once
addpath(fullfile(fileparts(mfilename('fullpath')),'/extern/'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/extern/weka'));
weka_init;
% add needed folders to the path
addpath(fullfile(fileparts(mfilename('fullpath')),'/features'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/data_representation'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/config'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/utility'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/gui'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/extern'));
        

% ask the user if he wants to load or create a configuration
resp = questdlg('Would you like to create a new configuration or load an existing one?', ...
    'Configuration', 'Create new', 'Load existing', 'Cancel', 'Create new');

persist_fn = fullfile(globals.DATA_DIRECTORY, 'start_gui.mat');                        
if exist(persist_fn, 'file')
    load(persist_fn);       
else
    fn = [];
    pn = [];
end        

% force loading all of the configurations
% to make sure that all of the needed directories are known
configurations.instance();

switch resp
    case 'Cancel'
        return;
    case 'Load existing'        
        [fn, pn] = uigetfile('*.mat', 'Select configuration', [pn fn]);
        if fn == 0
            return;
        end
        % load it
        cfg = base_config.load_from_file([pn fn]);        
    case 'Create new'        
        % create new new configuration
        new_cfg_dlg = select_config_window;
        if ~new_cfg_dlg.show
            disp('Aborted.');
            return;
        end
        cfg = new_cfg_dlg.selected_config;
        % save it already
        cfg.save_to_file();          
        % save also last folder
        pn = [cfg.OUTPUT_DIR globals.PATH_SEPARATOR];
        fn = cfg.SAVED_FILE_NAME;        
end

% save directory / file name for next time
save(persist_fn, 'fn', 'pn');       

% show main window
main = main_window(cfg);
main.show();