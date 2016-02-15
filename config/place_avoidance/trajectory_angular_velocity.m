function [vm, vv, min_, max_] = trajectory_angular_velocity( traj, x0, y0, varargin )
    %TRAJECTORY_ANGULAR_VELOCITY Compute mean angle of the trajectory    
    pts = trajectory_angular_velocity_impl( traj, x0, y0, varargin{:} ); 
    
    pts = [pts(:, 1), medfilt1(pts(:, 2), 5)];
    
    % mean and variances
    vm = median(pts(:, 2));
    vv = iqr(pts(:, 2));
    max_ = max(pts(:, 2));
    min_ = min(pts(:, 2));
end