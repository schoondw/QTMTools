%% Example violin bowing
% Example of indexing and trajectory and vec3d methods

%% Read data

% Parameters
qtm_mat_file = 'ViolinBowing_Strings0001.mat';

% Read mocap data (from QTM Mat file)
mc = mocapdata(qtm_mat_file);

% Extract parameters (shortcuts)
fs=mc.FrameRate;

%% Bowing parameters
% Adapted from JASA (Schoonderwaldt et al., 2009, https://doi.org/10.1121/1.3227640)

% Bow relative to Violin (6dof)
bow_rel = mc.RigidBodies('Bow').global2local(mc.RigidBodies('Violin'));

xb = bow_rel.unitVectors('x'); % Unit vector array x of the bow

% - Bow velocity (original definition)
% vbow = dot(cdiff(bow_rel.Position),xb).*fs; % JASA definition

% - Bow velocity (improved definition)
zb = bow_rel.unitVectors('z');
xvt = normalize(cross([0 1 0],zb)); % Unit vector of transversal bowing direction (in bowing plane, perpendicular to string)
vbow = dot(cdiff(bow_rel.Position),xvt).*fs; % Correct transversal bow velocity (perpendicular to string and z_bow, same as x_bow when bowing perpendicular to string)

% Used methods
% - global2local (pose6d): transform to local coordinates of (moving) reference
% - unitVectors (pose6d): extract unit vectors
% - normalize, dot, cross (vec3d): vector operations
% - cdiff (vec3d): central differentation (3-point) for calculation of velocity

% - Bow inclination
bow_incl = acos(dot(xb,[0 0 1]))-pi/2;

figure
subplot 211
plot(vbow)

subplot 212
plot(bow_incl)
