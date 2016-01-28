function pts = trajectory_angular_velocity_impl( traj, x0, y0, varargin )
    %TRAJECTORY_ANGULAR_VELOCITY Compute mean angle of the trajectory    
    repr = process_options(varargin, 'DataRepresentation', base_config.DATA_REPRESENTATION_COORD);
    
    pts = repr.apply(traj);

    % distance to the centre
    d = [pts(:, 2) - x0, pts(:, 3) - y0];       
    
    % the total angular distance moved
    dA = [0];
    dt = [1e-5];
            
    for i = 2:size(d, 1) 
        atanA = atan2( d(i - 1, 2), d(i - 1, 1) );
        atanB = atan2( d(i, 2), d(i, 1) );
            
        % check quadrants
        qd1 = quadrant(d(i - 1, 1), d(i -1, 2) );
        qd2 = quadrant(d(i, 1), d(i, 2) ); 

        % cannot have a too large angle, or jumping more than 1 quadrant at
        % once        
        if ( abs(qd1 - qd2) <= 1 || (qd1 == 1 && qd2 ==4) || (qd1 == 4 && qd2 == 1) ) 
            if qd2 == 3 && qd1 == 2
                % moving from the 2nd to the 3rd quadrants
                atanB = 2*pi + atanB;
            elseif qd2 == 2 && qd1 == 3
                atanA = 2*pi + atanA;
            end

            dA = [dA, atanB - atanA];
        else
            % some kind of discontinuity, take last value
            dA = [dA, dA(end)];            
        end
        
        dt = [dt, pts(i, 1) - pts(i - 1, 1)];
    end
                
    pts = [ pts(:, 1), (dA ./ dt)' ];        
    
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