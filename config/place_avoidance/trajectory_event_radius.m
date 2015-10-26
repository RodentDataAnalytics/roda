function ret = trajectory_event_radius( traj, x0, y0, rarena, state, varargin )    
    [repr, col] = process_options(varargin, 'DataRepresentation', base_config.DATA_REPRESENTATION_COORD, ...
                                            'StateColumn', 4);                                                    
                                                
    pts = repr.apply(traj);    
    r = [];
    
    for i = 1:size(pts, 1)                
        if pts(i, col) == state
            r = [r, sqrt( (pts(i, 2) - x0)^2 + (pts(i, 3) - y0)^2 ) / rarena];            
        end        
    end   
    
    ret = mean(r);
end