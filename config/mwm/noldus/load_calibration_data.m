function cal_data = load_calibration_data(path, data_path)
%LOAD_CALIBRATION_DATA Summary of this function goes here
%   Detailed explanation goes here
    addpath(fullfile(fileparts(mfilename('fullpath')), '/calibration'));
    
    cal_data = [];
            
    % load calibration data            
    files = dir(path);                
    for j = 3:length(files)
        if files(j).isdir
           % get day and track number from directory
           temp = sscanf(files(j).name, 'day%d_track%d');
           day = temp(1);
           track = temp(2);
           % find corresponding track file
           fn = fullfile(data_path, sprintf('day%d_%.4d_00.csv', day, track));
           if ~exist(fn, 'file')
               error('Non-existent file');
           end
           cal_data = [cal_data; trajectory_calibration_data(fn, fullfile(path, files(j).name), 100, 100, 100)];                                      
        end
    end       
end