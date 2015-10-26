function eff = trajectory_efficiency( traj, platx, platy )
    min_path = norm( traj.points(1, 2) - platx, traj.points(1,3) - platy);
    len = base_config.FEATURE_LENGTH.compute(traj);
    if len ~= 0
        eff = min_path / len;
    else
        eff = 0.;
    end        
end