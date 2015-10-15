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

% select configuration
sel_cfg = select_config_window;
if ~sel_cfg.show
    disp('Aborted.');
    return;
end

% show main window
main = main_window(sel_cfg.selected_config);
main.show();