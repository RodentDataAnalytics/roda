function [r, var] = trajectory_radius(traj, x0, y0, r, varargin)    
    [repr, f, f_avg, f_dis] = process_options(varargin, ...
        'DataRepresentation', base_config.DATA_REPRESENTATION_COORD, ...
        'TransformationFunc', [], ...
        'AveragingFunc', function_wrapper('Mean', '@(x) mean(x)'), ...
        'DispertionFunc', function_wrapper('IQR', '@(x) iqr(x)'));

    pts = repr.apply(traj);                                                   
    d = sqrt( power(pts(:, 2) - x0, 2) + power(pts(:, 3) - y0, 2) ) / r;       
    d(d == 0) = 1e-5; % avoid zero-radius
    if ~isempty(f)
        d = f.apply(d);
    end
    r = f_avg.apply(d);
    if nargout > 1
        var = f_dis.apply(d);
    end
end