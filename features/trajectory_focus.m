function f = trajectory_focus( traj, x0, y0, varargin )        
    % the focus is computed based on the area of the circle with
    % perimeter = trajectory length           
    [~, ~, a, b] = trajectory_boundaries(traj, x0, y0, varargin{:});
    f = 1 - a*b/(trajectory_length(traj, varargin{:})^2 / (4*pi));    
end