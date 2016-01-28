function [vm, vv] = trajectory_angular_velocity( traj, x0, y0, varargin )
    %TRAJECTORY_ANGULAR_VELOCITY Compute mean angle of the trajectory    
    pts = trajectory_angular_velocity_impl( traj, x0, y0, varargin{:} ); 
    
    % mean and variances
    vm = mean(pts(:, 2));
    vv = var(pts(:, 2));
end