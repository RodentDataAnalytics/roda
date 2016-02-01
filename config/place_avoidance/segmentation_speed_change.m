function segments = segmentation_speed_change(traj, dtrepr, dt_min, varargin)
    segments = trajectories([]);
    
    pts = dtrepr.apply(traj);
    pts = [pts(:, 1), medfilt1(pts(:, 2), 5)]; 
    tmin = 1;    
        
    %%%%%%%%%%%%%
    
    % break into sub-segments
    pti = 1;
    n = size(pts, 1);
    new_seg = 1;
    while new_seg
        new_seg = 0;
        for i = pti:n            
            if pts(i, 1) - pts(pti, 1) < tmin
                continue;
            end
            
            % compute median speed
            vm = median( abs(pts(pti:i, 2)) );
            vsd = vm / 0.645;
            
            % see if we crossed the "threshold"
            if abs(pts(i, 2)) > (vm + 3*vsd)
                % look for a "peak" point within 1 sec
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
                    segments = segments.append(trajectory(traj.points(pti:ptf, :), traj.set, traj.track, traj.group, traj.id, traj.trial, traj.session, 1, 0, 1, traj.trial_type));            
                end
                pti = ptf + 1;        
                new_seg = 1;
                break;
            end
        end
    end    
    
    % see if we want to append segments 
    if pts(n, 1) - pts(pti, 1) > dt_min                 
        segments = segments.append(trajectory(traj.points(pti:n, :), traj.set, traj.track, traj.group, traj.id, traj.trial, traj.session, 1, 0, 1, traj.trial_type));            
    end        
end