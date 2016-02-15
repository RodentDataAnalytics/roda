function ang = trajectory_mean_angle_signed( traj, x0, y0, ang0, varargin )
    %TRAJECTORY_ANGLE Compute mean angle of the trajectory    
    [repr, mirr] = process_options(varargin, 'DataRepresentation', base_config.DATA_REPRESENTATION_COORD, 'Mirror', 0);
    pts = repr.apply(traj);
    
    if ~isscalar(ang0)
        ang0 = ang0(traj.trial);
    end
    ang0 = 2*pi - ang0;

    d = [pts(:, 2) - x0, pts(:, 3) - y0];
    % normalize it
    norm_d = sqrt( d(:,1).^2 + d(:,2).^2);
    norm_d(norm_d == 0) =1e-5;
    
    d = d ./ repmat(norm_d, 1, 2);
        
    v = [sum(d(:, 1)); sum(d(:, 2))];
        
    % rotate point to the ref angle
    v = [cos(ang0) -sin(ang0); sin(ang0) cos(ang0)] * v;
    
    ang = atan2(v(2), v(1));       
    
    if ang < 0
        ang = 2*pi + ang;
    % if mirr
    %     ang = ang - pi;
    % end
end