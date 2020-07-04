%% Test transformations
% Read info from QTM exported MAT file and compare output to skeleton
% data in QTM data info window.

%% Read data
qtm_mat='Thor_ROM.mat';
%qtm_mat='5_airplanes.mat'; % File

% Read skeleton data
s = skeleton().readSkeletonData(qtm_mat);

%% Extract segment data from hip and spine and do some stuff with it
ph = s.Segments(1).Position; % position
qh = s.Segments(1).Rotation; % rotation (quaternion)

ps = s.Segments(2).Position;
qs = s.Segments(2).Rotation;

% Calculate spine relative to hips
% ps_h = vec3d(RotateVector(qh.inverse(),double(ps-ph))).'; % Position spine relative hips
ps_h = rotate_vec3d(ps-ph,qh.inverse()); % Position spine relative hips
qs_h = qh.inverse().*qs; % Rotation spine relative hips

% Convert orientation to Euler (x-y-z)
% Need to take negative of inverse, since QTM expresses attitude
% (representation of positions in local coordinate system), not
% rotation (rotation operation on vector in global coordinate system).
% So it is like rewinding the rotations.
% Compare to global segment data in QTM data info window
euler_h = -qh.inverse().EulerAngles('xyz')*180/pi;
euler_s = -qs.inverse().EulerAngles('xyz')*180/pi;

% Compare to local segment data in QTM data info window
euler_s_h = -qs_h.inverse().EulerAngles('xyz')*180/pi;

%% Same using skeleton and segment methods
% Talking about abstraction

% Extract segments from skeleton object
sh = s.getSegment('Hips');
ss = s.getSegment('Spine');

% Transform Spine segment to Hips segment
ss_h = global2local(ss,sh); % Spine segment relative to Hip segment

% Convert to Euler angles
euler_h = sh.eulerAngles('xyz');
euler_s = ss.eulerAngles('xyz');
euler_s_h = ss_h.eulerAngles('xyz');
