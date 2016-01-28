function segments = trajectory_segmentation_constant_time( traj, tseg, ovlp)
    %SEGMENT_TRAJECTORY Splits the trajectory in segments of length
    % lseg with an overlap of ovlp %
    % Returns an array of instances of the same trajectory class (now repesenting segments)        
    n = size(traj.points, 1);
        
    % compute cumulative distance vector
    cumtime = zeros(1, n);
    cumdist = zeros(1, n);
    for i = 2:n
        cumdist(i) = cumdist(i - 1) + norm( traj.points(i, 2:3) - traj.points(i - 1, 2:3) );    
        cumtime(i) = cumtime(i - 1) + ( traj.points(i, 1) - traj.points(i - 1, 1) );        
    end

    % step size
    off = tseg*(1. - ovlp);
    % total number of segments - at least 1
    if cumtime(end) > tseg                
        nseg = ceil((cumtime(end) - tseg) / off) + 1;
        off = off + (cumtime(end) - tseg - off*(nseg - 1))/nseg;
    else
        nseg = 1;
    end
    % segments are trajectories again -> construct empty object
    segments = trajectories([]);

    for seg = 0:(nseg - 1)
        starti = 0;
        seg_off = 0;
        pts = [];
        if nseg == 1
            % special case: only 1 segment, don't discard it
            pts = traj.points;
        else
            for i = 1:n
               if cumtime(i) >= seg*off                           
                   if starti == 0
                       starti = i;
                   end
                   if cumtime(i) > (seg*off + tseg)
                       % done we are
                       break;
                   end
                   if isempty(pts)
                       seg_off = cumdist(i);
                   end
                   % otherwise append point to segment
                   pts = [pts; traj.points(i, :)];
               end
            end
        end
        
        if ~isempty(pts)       
            segments = segments.append(...
                trajectory(pts, traj.set, traj.track, traj.group, traj.id, traj.trial, traj.session, seg + 1, seg_off, starti, traj.trial_type) ...
            );
        end
    end            
end