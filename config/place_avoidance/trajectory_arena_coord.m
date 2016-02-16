function pts = trajectory_arena_coord( traj, x0, y0, f, varargin )    
    [tol] = process_options(varargin, 'SimplificationTolerance', 0);
    
    pts = traj.points(1, :);
    for i = 2:size(traj.points, 1)                
        dt = traj.points(i - 1, 1) - traj.points(1, 1);
        x = traj.points(i, 2) - x0;
        y = traj.points(i, 3) - y0;
        
        xx = x*cos(-2*pi*dt*f/60) - y*sin(-2*pi*dt*f/60);
        yy = x*sin(-2*pi*dt*f/60) + y*cos(-2*pi*dt*f/60);
        
        pts = [pts; traj.points(i, 1), xx + x0, yy + y0, traj.points(i, 4:end)];
    end
 
    pts = trajectory_simplify_impl(pts, tol);    
end