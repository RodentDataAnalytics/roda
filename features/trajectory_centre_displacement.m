function val = trajectory_centre_displacement( traj, repr )
    if nargin > 1
        [x, y] = trajectory_boundaries(traj, repr);
    else
        [x, y] = trajectory_boundaries(traj);
    end
        
    val = sqrt( (x - traj.config.CENTRE_X)^2 + (y - traj.config.CENTRE_Y)^2) / traj.config.ARENA_R;
end