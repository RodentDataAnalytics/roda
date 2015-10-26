function [r, var] = trajectory_radius(traj, x0, y0, r, varargin)    
    [repr, f, f_avg, f_dis] = process_options(varargin, ...
        'DataRepresentation', base_config.DATA_REPRESENTATION_COORD, ...
        'TransformationFunc', [], ...
        'AveragingFunc', @(X) median(X), ...
        'DispertionFunc', @(X) iqr(X) );

    pts = repr.apply(traj);                                                   
    d = sqrt( power(pts(:, 2) - x0, 2) + power(pts(:, 3) - y0, 2) ) / r;       
    d(d == 0) = 1e-5; % avoid zero-radius
    if ~isempty(f)
        d = f(d);
    end
    r = f_avg(d);
    if nargout > 1
        var = f_dis(d);
    end
end