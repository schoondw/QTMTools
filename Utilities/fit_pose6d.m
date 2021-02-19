function [PQ,RMSE,DIST]=fit_pose6d(trajs,pose_def)
%function [PQ,RMSE,DIST]=fit_pose6d(trajs,pose_def)
%
% Adapted from rb_attitude (QTMTools-v1)
% 
% Function for tracking of rigid body with known marker configuration.
% Calculation of rotation and translation per frame based on a least-square
% fit procedure.
%
% Automatically leaves out missing markers. A warning is displayed
% afterwards in case 
% 
% Input arguments:
% - trajs: trajectory or vec3d array (frames x markers)
% - pose_def: vec3d array (1 x markers)
% 
% Output arguments:
% - PQ: fitted pose (pose6d)
% - RMSE: residual (RMS error of fit)
% - DIST: distance between individual fitted markers and their definition

% Internal representation:
% - rb_traj: QTM trajectory representation (multidim. array: marker x coord x
%            frame), markers should be in same order as in rb_def
% - rb_def: local marker configuration of rigid body (XYZ x markers,
%           no virtual markers)
% 

% Developer notes:
% 2012-07-26: Fourth output argument DETR replaced by DIST

% Convert to internal representation (3 x N for xyz and frames)
if isa(trajs,'trajectory')
    pos_array = [trajs.Position];
elseif isa(trajs,'vec3d')
    pos_array = trajs;
else
    error('QTMTools:fit_pose6d:invalid_input','Input argument trajs should be trajectory or vec3d array (frames x markers).')
end

nframes = size(pos_array,1);
nmarkers = size(pos_array,2);
rb_traj = permute(double(pos_array),[3 1 2]);

if size(pose_def,1) > 1
    error('QTMTools:fit_pose6d:invalid_input','Input argument trajs should be vec3d array (1 x markers).')
elseif size(pose_def,2) ~= nmarkers
    error('QTMTools:fit_pose6d:invalid_input','Inconsistent number of markers (second dimension) trajs and pose_def.')
end

if isa(pose_def,'vec3d')
    rb_def = squeeze(double(pose_def));
else
    error('QTMTools:fit_pose6d:invalid_input','Input argument trajs should be vec3d array (1 x markers).')
end

% nframes=size(rb_traj,3);
% nmarkers=size(rb_def,2);

RQ=nan(9,nframes);
TQ=nan(3,nframes);
RMSE=nan(1,nframes);
DIST=nan(nmarkers,nframes);
% DETR=zeros(1,nframes);
% MISS_IND=false(1,nframes);
MISS_COUNT=0;

for ifr=1:nframes
    rb_frame=squeeze(permute(rb_traj(:,:,ifr),[3 2 1]));
    
    % filter gaps
    i_missing=isnan(rb_frame(1,:));
    n_missing=sum(i_missing);
    
    if (nmarkers-n_missing) < 3
        % MISS_IND(ifr)=true;
        MISS_COUNT=MISS_COUNT+1;
        continue
    end
    
    rb_def_fr=rb_def;
    rb_def_fr(:,i_missing)=[];
    rb_frame(:,i_missing)=[];
    
    [R_frame,T_frame,res,detr,rb_loc]=rb_attitude_frame(rb_frame,rb_def_fr);
    RQ(:,ifr)=R_frame(:);
    TQ(:,ifr)=T_frame;
    RMSE(ifr)=res;
    % DETR(ifr)=detr;
    
    % rb_ref=repmat(T_frame,1,n_fr)+R_frame*rb_def_fr;
    % DIST(~i_missing,ifr) = sqrt(sum((rb_frame-rb_ref).^2));
    DIST(~i_missing,ifr)=sqrt(sum((rb_loc-rb_def_fr).^2));
end

PQ = pose6d(TQ,RQ);

% Aftermath
if MISS_COUNT>0
    warning('QTMTools:MissingFrames','%d missing frames',MISS_COUNT);
end


function [R,T,RMSE,detR,rb_frame_loc]=rb_attitude_frame(rb_frame,rb_def)
%
% rb_frame and rb_def:
% - rows (3): XYZ coordinates
% - column: markers
%

% Checks
[mdef,ndef] = size(rb_def);
[mframe,nframe] = size(rb_frame);

if mdef~=3 || mframe~=3
    error('Size of first dimension should be three (XYZ)!')
end

if ndef~=nframe
    error('Number of markers in tracked body and its definition should be the same!')
end

% Center of mass
cm_def = mean(rb_def,2);
cm_frame = mean(rb_frame,2);
%cm_def=zeros(3,1);
%cm_frame=cm_def;

% Rotation matrix (fit marker configuration to rb_def)
G = (rb_frame-cm_frame*ones(1,ndef))*(rb_def-cm_def*ones(1,ndef))'/ndef;
mu = sqrt(sort(eig(G'*G)));
t = sign(det(G));
% R = (adj(G)'+(mu(3)+mu(2)+t*mu(1))*G) ...
%     *inv(G'*G+(mu(3)*mu(2)+t*mu(1)*(mu(3)+mu(2)))*eye(3));
R = (adj(G)'+(mu(3)+mu(2)+t*mu(1))*G) ...
    / (G'*G+(mu(3)*mu(2)+t*mu(1)*(mu(3)+mu(2)))*eye(3));

% if any(abs(imag(R))>eps) % in earlier version 1e-6
%     fprintf('Warning %s: Rotation matrix complex. Imaginary part removed.\n',mfilename);
%     % disp(['Warning : R complex. Imaginary part removed (magnitude ' num2str(norm(imag(R))) ')'])
% end 
R = real(R); % Make sure that possible (small) imaginary components are removed.

% if det(R)~=1
%     fprintf('Warning %s: det(R) not equal to 1 (det(R) - 1 = %g\n)', mfilename, det(R)-1);
% end

% RMSE is computed as the root of the average total position deviation of the points
rb_frame_loc = cm_def*ones(1,ndef)+R\(rb_frame-cm_frame*ones(1,ndef)); 
RMSE = sqrt(sum(sum((rb_frame_loc-rb_def).^2))/ndef);


% Output
T = cm_frame-R*cm_def; % Translation of origin (not CM!)
detR=det(R); % Check: should be +1



% --------------------
function  G_adj=adj(G)
% Calculate adjoint of 3x3 matrix
% N.B. Returns transposed adjoint matrix!
[m,n]=size(G);
if m ~= 3 || n ~= 3
   error('G should be a 3x3 martrix')
end
G_adj = [cross(G(:,2),G(:,3)) cross(G(:,3),G(:,1)) cross(G(:,1),G(:,2))]';

