%% Example basic operations
% Example of indexing and trajectory and vec3d methods

%% Read data

% Parameters
qtm_mat_file = 'Skeleton-Animation-ROM.mat';

% Read mocap data (from QTM Mat file)
mc = mocapdata(qtm_mat_file)





%% --- trajectory operations
methods(trajectory)


%% Help info (overloaded methods)
help trajectory/mean


%% Label admin functions (same for rigid bodies, skeletons, segments)
% List
mc.Trajectories.LabelList

% Check if a label exists
mc.Trajectories.LabelCheck('VF_HeadTop')

% Get index for a label
mc.Trajectories.LabelIndex('VF_HeadTop')


%% Isolate a trajectory (indexing options)
traj1 = mc.Trajectories(1);

traj123 = mc.Trajectories(1:3); 

labels = ["VF_HeadL", "VF_HeadR"]; % String array
% labels = {'VF_HeadL', 'VF_HeadR'} ; % Cell array
traj_sel = mc.Trajectories(labels);
% Indexing with char, strings, cells

%% Isolate components
x1 = traj1.x; % same for y, z; use .xyz for conversion to double array

figure
plot(x1)


%% Average of multiple trajectories (overloaded methods: mean, plot)
p_av = mean(mc.Trajectories,2); % Average across second dimension (1x42 trajectory array)

figure
plot(p_av, 'LineWidth', 2)

% - Overloaded functions accept same arguments as Matlab's original functions


%% Difference between two trajectories
p_diff = traj_sel(2) - traj_sel(1);

figure
plot(p_diff)

%% Distance between two trajectories
traj_dist = distance(traj_sel(1), traj_sel(2));

figure
plot(traj_dist)





%% --- vec3d operations (3D position vectors)
methods(vec3d)

%% Extract Position (vec3d) from Trajectories
p1 = mc.Trajectories(1).Position;

p123 = [mc.Trajectories(1:3).Position]; % Collect positions from multiple trajectories in an array

figure
plot(p123)

%% Subtraction
figure
subplot 211
plot(p1);

test = p1 - [0 0 1000];
% - Automatic type conversion [0 0 1000] to vec3d
% - Vectorized

subplot 212
plot(test);


