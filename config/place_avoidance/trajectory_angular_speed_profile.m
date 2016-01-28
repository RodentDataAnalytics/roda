function pts = trajectory_angular_speed_profile(traj, x0, y0, varargin)
    pts = trajectory_angular_velocity_impl(traj, x0, y0, varargin{:});       
end