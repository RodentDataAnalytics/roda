function val = trajectory_centre_displacement( traj, x0, y0, r, repr )
    if nargin > 3
        [x, y] = trajectory_boundaries(traj, repr);
    else
        [x, y] = trajectory_boundaries(traj);
    end
        
    val = sqrt( (x - x0)^2 + (y - y0)^2) ) / r;
end