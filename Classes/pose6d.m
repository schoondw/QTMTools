classdef pose6d
    %pose6d Pose (6DOF) data representation.
    
    %   Further expand help info
    
    properties
        Position vec3d                % Position data: vec3d array
        Rotation quaternion           % Rotation data: quaternion array
    end
    
    methods
        function p = pose6d(pos,rot)
            %pose6d Construct an instance of this class
            %   Detailed explanation goes here
            % if nargin < 3, lab = ''; end
            
            rot_tol = eps('single'); % Use higher tolerance for single precision (float) representation of 6dof rotation matrix in QTM
            
            switch nargin
                case 0
                    pos = vec3d();
                    rot = quaternion.eye(1);
                    
                case 2
                    if isempty(pos)
                        pos = vec3d();
                    elseif ~isa(pos,'vec3d')
                        pos = vec3d(squeeze(pos));
                    end
                    
                    if isempty(rot)
                        rot = quaternion.eye(1);
                    elseif ~isa(rot,'quaternion')
                        rot = parse_qtm_rot(rot, rot_tol);
                    end
                    
                otherwise
                    error('pose6d:constructor','Invalid input')
            end
            
            szp = size(pos);
            if szp(2) > szp(1)
                pos = pos.'; % Convert to column
                szp = szp([2 1]);
            end
            
            szr = size(rot);
            if szr(2) > szr(1)
                rot = rot.'; % Convert to column. Important: use non-conjugate transpose for quaternion!
                szr = szr([2 1]);
            end
            
            if szp(2)~=1 || szr(2)~=1
                error('pose6d:constructor','Invalid input')
            end
            
            % Expand to same size if one of the inputs is a vector and the
            % other a single element
            if szp(1) ~= szr(1)
                nfr = max(szp(1),szr(1));
                if szp(1) == 1
                    pos = repmat(pos,nfr,1);
                elseif szr(1) == 1
                    rot = repmat(rot,nfr,1);
                else
                    error('pose6d:constructor','Invalid input')
                end
            end
            
            % p.Label = lab;
            p.Position = pos;
            p.Rotation = rot;
        end
        
        function p_loc = global2local(p,ref)
            %function sloc = global2local(p,ref)
            %   Transform segment data to reference segment coordinates.
            %   When the Position and Rotation properties of s and sref
            %   are not the same size, calculation uses binary singleton
            %   expansion (for example tranform s relative to fixed
            %   reference). 
            p_loc = p;
            p_loc.Position = rotate_vec3d(p.Position-ref.Position,...
                ref.Rotation.inverse()); % position relative to reference
            p_loc.Rotation = ref.Rotation.inverse().*p.Rotation; % rotation relative to reference
        end
        
        function angles = eulerAngles(p,ax)
            %function angles = eulerAngles(p,ax)
            %   Returns Euler angles of coordinate system in degrees.
            %   For qualisys standard, use ax = 'xyz'.
            %   The Euler angles may differ from QTM when using a custom
            %   Euler definition in QTM.
            if nargin < 2, ax = 'xyz'; end
            angles = -p.Rotation.inverse().EulerAngles(ax)*180/pi;
            % Note: For attitude representation corresponding to QTM the
            % rotations need to be "rewinded".
        end
        
        function uv = unitVectors(p,ax)
            %function uv = unitVectors(p,ax)
            %   Returns selected unit vector(s) of coordinate system in degrees.
            %   ax can be 'x','y','z' or combinations, e.g, 'xyz'
            [~,ind] = ismember(lower(ax),'xyz');
            R = RotationMatrix(p.Rotation);
            uv = vec3d(R(:,ind,:)); % Unit vectors of lcs expressed in reference cs are columns in the rotation matrix
            
            su = size(uv);
            if su(2) > su(1)
                uv = uv.'; % Should make frames the first dimension
            end
        end
        
    end
end

% --- Helper functions
function qrot = parse_qtm_rot(rot,tol)
% Convert qtm rotation (matrix or quaternion) to quaternion
if nargin<2, tol=eps; end

rot = squeeze(rot);
siz = size(rot);

if length(siz) > 2
    error('pose6d:parse_qtm_rot','Invalid input')
end

switch siz(1)
    case 4 % QTM quaternion XYZW
        qrot = quaternion(rot([4 1 2 3],:)); % Real part comes first in quaternion, last in QTM export
        
    case 9 % QTM unfolded rotation matrix
        qrot = quaternion.rotationmatrix(...
            reshape(rot,3,3,[]),tol);
        
    otherwise
        error('pose6d:parse_qtm_rot','Invalid input')
end

end
