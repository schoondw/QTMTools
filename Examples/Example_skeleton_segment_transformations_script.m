%% Test transformations
% Read info from QTM exported MAT file and compare output to skeleton
% data in QTM data info window.

%% Read data

% Parameters
qtm_mat_file = 'Skeleton-Animation-ROM.mat';

% Read mocap data
mc = mocapdata(qtm_mat_file);

%% Segment parent-child transformations

% Copy first skeleton
s = mc.Skeletons(1);

% Copy segments from skeleton object
s_hips = s.Segments('Hips');
s_spine = s.Segments('Spine');

% Transform Spine segment relative to Hips segment using the local2global method.
% Parent property in s_spine_local is set to "Hips".
s_spine_local = s_spine.global2local(s_hips);
% Alternative: s_spine_local = global2local(s_spine, s_hips);

% Convert to Euler angles in degrees (QTM convention: xyz)
euler_hips = s_hips.eulerAngles('xyz');
euler_spine = s_spine.eulerAngles('xyz');
euler_spine_local = s_spine_local.eulerAngles('xyz');

% Compare results with segment data in the QTM data info window (global and
% local coordinates)
