classdef trajectory < handle
    %TRAJECTORY Stores points of a trajectory or segment of trajectory
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        config = [];
        points = [];
        % trajectory/segment identification
        set = -1;
        track = -1;
        group = -1;
        id = -1;
        trial = -1;
        trial_type = -1;
        segment = -1;
        offset = -1;        
        session = -1;
        start_time = -1;
        end_time = -1;
        start_index = -1;        
    end
    
    properties(GetAccess = 'protected', SetAccess = 'protected')        
        feat_val_ = [];    
        hash_ = -1;
    end
    
    methods
        % constructor
        function traj = trajectory(cfg, pts, set, track, group, id, trial, segment, off, starti, trial_type)
            traj.config = cfg;
            traj.points = pts;                       
            traj.set = set;
            traj.track = track;
            traj.start_index = starti;
            traj.group = group;
            traj.id = id;
            traj.trial = trial;
            assert(~isempty(segment));
            traj.segment = segment;
            traj.offset = off;            
            tot = 0;
            for i = 1:length(traj.config.TRIALS_PER_SESSION)
                tot = tot + traj.config.TRIALS_PER_SESSION(i);
                if trial <= tot
                    traj.session = i;
                    break;
                end
            end
            traj.start_time = pts(1, 1);
            traj.end_time = pts(end, 1);
            if nargin > 10
                traj.trial_type = trial_type;
            else
                traj.trial_type = traj.config.TRIAL_TYPE(trial);
            end
        end
        
        % returns the full trajectory (or segment identification)
        function [ ident ] = identification(traj)
            ident = [traj.group, traj.id, traj.trial, traj.segment];
        end
        
        function set_trial(inst, new_trial, trial_type)
            inst.trial = new_trial;
            inst.hash_ = -1;
            if nargin > 2
                inst.trial_type = trial_type;          
            else
                inst.trial_type = inst.config.TRIAL_TYPE(inst.trial);
            end
        end
        
        function set_track(inst, new_track)
            inst.track = new_track;
            inst.hash_ = -1;
        end
        
        function set_group(inst, new_group)
            inst.group = new_group;
            inst.hash_ = -1;
        end
        
        function cache_feature_value(inst, feat, val)
            if isempty(inst.feat_val_)
                inst.feat_val_ = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
            end                   
            inst.feat_val_(feat) = val;            
        end
        
        function ret = has_feature_value(inst, feat)
            ret = ~isempty(inst.feat_val_) && inst.feat_val_.isKey(feat);
        end
        
        function out = hash_value(traj)       
            if traj.hash_ == -1                                          
                % compute hash
                len = 0;
                if traj.offset ~= -1
                    % length taken only into account when offset is used
                    len = traj.compute_feature(inst.config.FEATURE_LENGTH);
                end
                traj.hash_ = trajectory.compute_hash(traj.set, traj.session, traj.track, traj.offset, len);
            end
            out = traj.hash_;
        end
        
        % returns the data set and track number where the data originated
        function [ ident ] = data_identification(traj)
            ident = [traj.set, traj.session, traj.track];
        end                              
                        
        function [ segment ] = sub_segment(traj, beg, len)
            %SUB_SEGMENT returns a segment from the trajectory
            pts = [];
            dist = 0;
            starti = 0;
            for i = 2:length(traj.points)
               dist = dist + norm( traj.points(i, 2:3) - traj.points(i - 1, 2:3) );
               if dist >= beg
                   if starti == 0
                       starti = i;
                   end
                   if dist > beg + len
                       % done we are
                       break;
                   end
                   % append point to segment
                   pts = [pts; traj.points(i, :)];
               end
            end
             
            segment = trajectory(traj.config, pts, traj.set, traj.track, traj.group, traj.id, traj.trial, 0, beg, starti);   
        end
        
        function C = centre(traj)           
            if isempty(traj.centre_)
                traj.centre_ = trajectory_centre(traj.points);
            end
            C = traj.centre_;
        end
        
        function pts = central_points(traj, p)
            C = traj.centre;
        
            % then we compute the distance of each point to the center
            d = sqrt(power(traj.points(:, 2) - C(1), 2) + power(traj.points(:, 3) - C(2), 2));

            % now sort the values by the distance
            [~, ind] = sort(d);    
            % sort the points now    
            pts = traj.points(ind, :);
            % select only the first p percent of them
            pts = pts(1:floor(p*size(traj.points, 1)), :);
        end    
        
        function [ V ] = compute_features(traj, feat)
        %COMPUTE_FEATURES Computes a set of features for a trajectory
        %   COMPUTE_FEATURES(traj, [F1, F2, ... FN]) computes features F1, F2, ..
        %   FN for trajectory traj (features are identified by config defined 
        %   at the beginning of this class    
            V = [];
            for i = 1:length(feat)
                V = [V, traj.compute_feature(feat(i))];
            end
        end            
        
        function val = compute_feature(inst, feat)
            % see if value already cached
            if isempty(inst.feat_val_) || ~inst.feat_val_.isKey(feat)
                par = inst.config.FEATURES{feat};                
                f = str2func(par{3}); % function name
                idx = 1; % return value index
                if length(par) > 3
                    idx = par{4};
                end
                switch idx
                    case 1
                        val = f(inst, par{5:end});
                    case 2
                        [~, val] = f(inst, par{5:end});
                    case 3
                        [~, ~, val] = f(inst, par{5:end});
                    case 4
                        [~, ~, ~, val] = f(inst, par{5:end});
                    case 5
                        [~, ~, ~, ~, val] = f(inst, par{5:end});
                    otherwise
                        error('need more of those');
                end
                                               
                % cache value for next time
                inst.cache_feature_value(feat, val);
            else
                val = inst.feat_val_(feat);
            end           
        end    
        
        function plot(inst, varargin)
            addpath(fullfile(fileparts(mfilename('fullpath')), '/extern'));
            [clr, arn, ls, lw] = process_options(varargin, ...
                'Color', [0 0 0], 'DrawArena', 1, 'LineSpec', '-', 'LineWidth', 1);
            if arn
                axis off;
                daspect([1 1 1]);                      
                rectangle('Position',[inst.config.CENTRE_X - inst.config.ARENA_R, inst.config.CENTRE_Y - inst.config.ARENA_R, inst.config.ARENA_R*2, inst.config.ARENA_R*2],...
                    'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);
                hold on;
                axis square;
                % see if we have a platform to draw
                if exist('inst.config.PLATFORM_X')
                    rectangle('Position',[inst.config.PLATFORM_X - inst.config.PLATFORM_R, inst.config.PLATFORM_Y - inst.config.PLATFORM_R, 2*inst.config.PLATFORM_R, 2*inst.config.PLATFORM_R],...
                        'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);             
                end
            end
            plot(inst.points(:,2), inst.points(:,3), ls, 'LineWidth', lw, 'Color', clr);           
            set(gca, 'LooseInset', [0,0,0,0]);
        end      
        
        function pts = simplify(inst, tol)
            pts = trajectory_simplify_impl(inst.points, tol);
        end
        
        function pts = data_representation(inst, idx, varargin)
            assert(idx <= length(inst.config.DATA_REPRESENTATION));
            % dispatch the call to the function registered globally
            att = inst.config.DATA_REPRESENTATION{idx};
            f = str2func(att{3});
            pts = f(inst, att{4:end}, varargin{:});
        end
        
        function segs = partition(inst, idx, varargin)
            assert(idx <= length(inst.config.SEGMENTATIONS));
            att = inst.config.SEGMENTATIONS{idx};
            f = str2func(att{2});
            segs = f(inst, att{3:end}, varargin{:});
        end
    end
    
    methods(Static)
        % compute a hash for a trajectory segment
        % defined here as it is useful in other situations as well
        function hash = compute_hash(set, session, track, offset, len) 
            % compute hash            
            hash = hash_value(set);
            hash = hash_combine(hash, hash_value(session));
            hash = hash_combine(hash, hash_value(track));
            hash = hash_combine(hash, hash_value(floor(offset)));
            hash = hash_combine(hash, hash_value(floor(len)));
        end
    end
    
    methods(Access = 'protected')
        function compute_boundary(traj)
            if traj.focus_ == -1                
                if isempty(traj.centralpts_)
                    traj.centralpts_ = traj.central_points(1.);
                end
                [traj.focus_, traj.ecentre_, traj.a_, traj.b_, traj.inc_] = trajectory_focus(traj.centralpts_, traj.compute_feature(features.LENGTH));
            end
        end
    end    
end
    
