function eff = trajectory_efficiency( traj )
    min_path = norm( traj.points(1, 2) - traj.config.PLATFORM_X, traj.points(1,3) - traj.config.PLATFORM_Y);
    len = traj.compute_feature(traj.config.FEATURE_LENGTH);
    if len ~= 0
        eff = min_path / len;
    else
        eff = 0.;
    end        
end