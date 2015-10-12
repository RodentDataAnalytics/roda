function pts = trajectory_arena_coord( traj, varargin )    
    [tol] = process_options(varargin, 'SimplificationTolerance', 0);
    
    pts = [];
    for i = 2:size(traj.points, 1)                
        dt = -(traj.points(1, 1) - traj.points(i - 1, 1));
        x = traj.points(i, 2) - traj.config.CENTRE_X;
        y = traj.points(i, 3) - traj.config.CENTRE_X;
        
        xx = x*cos(-dt*g_config.ROTATION_FREQUENCY) - y*sin(-dt*traj.config.ROTATION_FREQUENCY);
        yy = x*sin(-dt*g_config.ROTATION_FREQUENCY) + y*cos(-dt*traj.config.ROTATION_FREQUENCY);
        
        pts = [pts; traj.points(i, 1), xx + traj.config.CENTRE_X, yy + traj.config.CENTRE_Y, traj.points(i, 4:end)];
    end
 
    pts = trajectory_simplify_impl(pts, tol);    
end