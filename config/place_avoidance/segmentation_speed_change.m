function segments = segmentation_speed_change(traj, dtrepr, dt_min, varargin)
    segments = trajectories([]);
    
    pts = dtrepr.apply(traj);
    pts = [pts(:, 1), medfilt1(pts(:, 2), 5)]; 
    tmin = 1;    
    
    sel = process_options(varargin, 'Selection', '');
    first_seg = (isempty(sel) || strcmp(sel, 'AfterShock'));
    other_seg = (isempty(sel) || strcmp(sel, 'NotAfterShock'));
    
    %%%%%%%%%%%%%
    
    % break into sub-segments
    pti = 1;
    n = size(pts, 1);
    new_seg = 1;
    cum_dist = [0]; 
    % need the cummulative distances first
    for i = 2:n
        cum_dist(i) = cum_dist(i - 1) + sqrt(sum( (traj.points(i, 2:3) - traj.points(i - 1, 2:3)).^2 ));
    end
    while new_seg
        new_seg = 0;
        for i = pti:n                                      
            if pts(i, 1) - pts(pti, 1) < tmin
                continue;
            end            
            
            % compute median speed
            vm = median( pts(pti:i, 2) );
            
            % see if we crossed the "threshold"
            if abs(pts(i, 2) - vm) > .4
                % look for a "peak" point within 1 sec
                if i < n
                    j = i + 1;
                    ptf = j;
                    while j < n && pts(j, 1) - pts(i, 1) <= .5  
                        if pts(i, 2) > 0
                            if pts(j, 2) > pts(i, 2)
                                ptf = j;
                            end
                        else
                            if pts(j, 2) < pts(i, 2)
                                ptf = j;
                            end
                        end
                        j = j + 1;
                    end     
                    % see if we are long enough
                    if pts(ptf, 1) - pts(pti, 1) > dt_min                             
                        segments = segments.append(trajectory(traj.points(pti:ptf, :), traj.set, traj.track, traj.group, traj.id, traj.trial, traj.session, traj.segment, traj.offset + cum_dist(pti), traj.start_index + pti, traj.trial_type));            
                    end
                    pti = min(ptf + 1, n);        
                    new_seg = 1;
                    break;
                end                
            end
        end
    end    
    
    % see if we want to append segments 
    if pts(n, 1) - pts(pti, 1) > dt_min                 
        segments = segments.append(trajectory(traj.points(pti:n, :), traj.set, traj.track, traj.group, traj.id, traj.trial, traj.session, traj.segment, traj.offset + cum_dist(pti), traj.start_index + pti, traj.trial_type));            
    end      
    
    if ~other_seg           
        if segments.count > 1
            if segments.items(1).offset > 0 && segments.items(1).offset == traj.offset 
                % take just the first
                segments = trajectories(segments.items(1) );        
            else
                segments = trajectories([]);
            end            
        else
            if segments.count == 1 && segments.items(1).offset > traj.offset
                % this is the first part of the trajectory (i.e. not after a
                %shock); just ignore it
                segments = trajectories([]);
            end
        end
    end
    if ~first_seg
        if segments.count > 1
            if segments.items(1).offset > 0                
                segments = trajectories(segments.items(2:end));           
            end
        end
    end
end