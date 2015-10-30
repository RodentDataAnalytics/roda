function val = trajectory_cv_inner_radius(traj, x0, y0, varargin)
    % need first the centre of the trajectory
    [x0, y0] = trajectory_boundaries(traj, x0, y0, varargin{:});

    [r, iqr] = trajectory_radius(traj, 'CentreX', x0, 'CentreY', y0, varargin{:});    
    val = r / iqr;                    
end