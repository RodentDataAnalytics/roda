function [ x, y, a, b, inc ] = trajectory_boundaries( traj, varargin )
    x = 0;
    y = 0;
    a = 0;    
    b = 0;
    inc = 0;
     
    repr = process_options(varargin, 'DataRepresentation', base_config.DATA_REPRESENTATION_COORD);
        
    if repr.hash_value ~= base_config.DATA_REPRESENTATION_COORD.hash_value
        % we have a special data representation - don't look for
        % pre-computed values
        pts = repr.apply(traj);                    
        if size(pts, 1) > 3
            [A, cntr] = min_enclosing_ellipsoid(pts(:, 2:3)', 1e-2);
            x = cntr(1);
            y = cntr(2);                
            if sum(isnan(A)) == 0
                [a, b, inc] = ellipse_parameters(A);
            end
        end
    else
        centre_x = base_config.FEATURE_BOUNDARY_CENTRE_X;
        centre_y = base_config.FEATURE_BOUNDARY_CENTRE_Y;
        r_min = base_config.FEATURE_BOUNDARY_RADIUS_MIN;
        r_max = base_config.FEATURE_BOUNDARY_RADIUS_MAX;
        inc = base_config.FEATURE_BOUNDARY_INCLINATION;
        
        % see we have cached values
        if traj.has_feature_value(centre_x)
            x = centre_x.compute(traj);
            y = centre_y.compute(traj);
            a = r_min.compute(traj);
            b = r_max.compute(traj);
            inc = inc.compute(traj);
        else
            if size(traj.points, 1) > 3
                [A, cntr] = min_enclosing_ellipsoid(traj.points(:, 2:3)', 1e-1);
                x = cntr(1);
                y = cntr(2);
                if (sum(isinf(A)) + sum(isnan(A))) == 0
                    [a, b, inc] = ellipse_parameters(A);
                end
                % cache values
                traj.cache_feature_value(centre_x, x);
                traj.cache_feature_value(centre_y, y);
                traj.cache_feature_value(r_min, a);
                traj.cache_feature_value(r_max, b);
                traj.cache_feature_value(inc, inc);                
            end
        end
    end                    
end