function test(pts) 
    figure(1);
    pts = [pts(:, 1), medfilt1(pts(:, 2), 5)]; 
    plot(pts(:, 1), pts(:, 2));
    tmin = 10;
        
    %%%%%%%%%%%%%
    
    % break into sub-segments
    segs = {};
    pti = 1;
    off = 1;
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
            if abs(pts(i, 2)) > (vm + 5*vsd)
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
                segs = [segs, pts(pti:ptf, :)];
                pti = ptf + 1;        
                new_seg = 1;
                break;
            end
        end
    end    
    
    % see if we want to append segments 
    if pts(n, 1) - pts(pti, 1) < tmin
        if ~isempty(segs)
            segs{length(segs)} = [segs{length(segs)}; pts(pti:n, :)];
        end
    else
        segs = [segs, pts(pti:n, :)];
    end
    
    for i = 1:length(segs)
        figure(i + 1);
        tmp = segs{i};
        plot(tmp(:, 1), tmp(:, 2));
    end 
    
    function qd = quadrant(x, y)
        if x > 0
            if y > 0
                qd = 1;
            else
                qd = 4;
            end
        else
            if y > 0
                qd = 2;
            else
                qd = 3;
            end
        end
    end
end