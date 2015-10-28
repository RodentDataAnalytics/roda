function ang = trajectory_angular_distance_shock( traj, x0, y0, shock_area_angle, varargin )
    %TRAJECTORY_ANGLE Compute mean angle of the trajectory    
    if traj.session > 0
        central_ang = shock_area_angle(traj.session);    
        ang = trajectory_mean_angle(traj, x0, y0, 'DirX', cos(central_ang), 'DirY', sin(central_ang) );        
    else
        ang = NaN;
    end    
end