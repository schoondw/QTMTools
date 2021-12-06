%% Example rigid body operations
% Example of indexing and trajectory and vec3d methods

%% Read data

% Parameters
qtm_mat_file = '6d_and_analog.mat';

% Read mocap data (from QTM Mat file)
mc = mocapdata(qtm_mat_file)





%% --- rigidbody operations
methods(rigidbody)


%% Label admin functions (same for rigid bodies, skeletons, segments)
% List
mc.RigidBodies.LabelList

% Check if a label exists
mc.RigidBodies.LabelCheck('L-frame')

% Get index for a label
mc.RigidBodies.LabelIndex('Object')

%% Isolate rigid body "Object"

rb_obj = mc.RigidBodies('Object');

