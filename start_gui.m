%% Initialize the WEKA library (java stuff)
% somewhere in the loading procedure the global variables are cleared and
% this messes up everything so don't call it more than once
addpath(fullfile(fileparts(mfilename('fullpath')),'/extern/weka'));
weka_init;
% add needed folders to the path
addpath(fullfile(fileparts(mfilename('fullpath')),'/features'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/data_representation'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/config'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/utility'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/gui'));

% ask the user if he wants to load or create a configuration
resp = questdlg('Would you like to create a new configuration or load an existing one?', ...
    'Configuration', 'Create new', 'Load existing', 'Cancel', 'Create new');

switch resp
    case 'Cancel'
        return;
    case 'Load existing'        
        fn = uigetfile('*.cfg', 'Select configuration');
        if ~isempty(fn)
            return;
        end
        % load it
        cfg = base_config.load_from_file(fn);        
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
end

% show main window
main = main_window(cfg);
main.show();