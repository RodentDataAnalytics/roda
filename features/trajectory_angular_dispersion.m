function ret = trajectory_angular_dispersion( traj, x0, y0, varargin )
    %TRAJECTORY_ANGLE Compute mean angle of the trajectory    
    repr = process_options(varargin, 'DataRepresentation', base_config.DATA_REPRESENTATION_COORD);
    
    pts = repr.apply(traj);

    d = [pts(:, 2) - x0, pts(:, 3) - y0];
    % normalize it
    d = d ./ repmat(sqrt( d(:,1).^2 + d(:,2).^2), 1, 2);
        
    % use always the (1, 0) direction as basis
    u = [1, 0];
    ang_min = [];
    ang_max = [];
    
    for i = 1:size(d, 1)
        ang = abs(acos(dot(u, d(i, :))/(norm(u)*norm(d(i, :)))));  
        if d(i, 2) < 0
            ang = -ang;
        end
        if isempty(ang_min) || ang < ang_min
            ang_min = ang;
        end
        if isempty(ang_max) || ang > ang_max
            ang_max = ang;
        end
    end
    ret = ang_max - ang_min;
end