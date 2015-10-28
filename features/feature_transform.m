function x = feature_transform(traj, f, feat)   
    % return transformed value
    x = f.apply(traj.compute_feature(feat));
end