global g_trajectories;    
% initialize data
cache_trajectories; 

trajs = [3, 34, 6, 40; ...
    1, 69, 5, 1088; ...
    1, 27, 3, 1335; ...
    3, 98, 6, 250; ...
    1, 67, 7, 74; ...
    2, 6, 2, 352];


for j = 1:size(trajs, 1)
    for i=1:length(g_trajectories.items)
        if g_trajectories.items(i).set == trajs(j, 1)  && g_trajectories.items(i).track == trajs(j, 2) && g_trajectories.items(i).trial == trajs(j, 3)
            seg = g_trajectories.items(i).sub_segment(trajs(j, 4), 250);
            l = seg.compute_feature(features.LONGEST_LOOP);
            fprintf('Loop: %d\n', l);
            break;
        end
    end
end