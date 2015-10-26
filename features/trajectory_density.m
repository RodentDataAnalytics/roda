function f = trajectory_density( traj, x0, y0, varargin )        
    % the focus is computed based on the area of the circle with
    % perimeter = trajectory length           
    [~, ~, a, b] = trajectory_boundaries(traj, x0, y0, varargin{:});
    f = trajectory_length(traj, varargin{:}) / (a*b);    
end