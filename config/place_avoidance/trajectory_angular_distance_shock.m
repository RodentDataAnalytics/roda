function ang = trajectory_angular_distance_shock( traj, varargin )
    %TRAJECTORY_ANGLE Compute mean angle of the trajectory    
    if traj.session > 0
        central_ang = traj.config.SHOCK_AREA_ANGLE(traj.session);    
        ang = trajectory_mean_angle(traj, 'DirX', cos(central_ang), 'DirY', sin(central_ang) );        
    else
        ang = NaN;
    end    
end