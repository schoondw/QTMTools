function idx = volume_selection(data,type,varargin)
% function idx = volume_selection(data,type,varargin)
% 
% Output: boolean index to data inside specified volume.
% 
% Input:
% - data: array of trajectory, rigidbody or vec3d objects.
% - type: type of volume
% - volume parameters, depending on type
% 
% type: all (select all)
% No parameters
% 
% type: box
% Parameters: [xmin xmax], [ymin ymax], [zmin zmax], [x0 y0 z0] (optional)
% 
% type: sphere
% Parameters: r, [x0 y0 zo] (optional)
% 
% type: ellipsoid
% Parameters: [rx, ry, rz], [x0, y0, z0] (optional)
% 
% type: orthant (ray, quadrant or octant, depending on sign pattern)
% Parameters: [sx, sy, sz], [x0, y0, z0] (optional)
% - sx, sy, sz is sign: -1, 1 or 0 when not used.

% Refs:
% - https://en.wikipedia.org/wiki/Ellipsoid
% - https://en.wikipedia.org/wiki/Orthant

% Parse input
% - trajectory array
if isa(data,'trajectory')
    p = [data.Position];
elseif isa(data,'rigidbody')
    p = [data.Position];
elseif isa(data,'vec3d')
    p = data;
else
    error('Unknown input')
end

switch type
    case 'all'
        idx = true(size(p));
        
    case 'box'
        % Parameters
        xlim = varargin{1};
        ylim = varargin{2};
        zlim = varargin{3};
        
        % If center specified
        if length(varargin)>3
            p = p - varargin{4};
        end
        
        idx = ...
            p.xData>xlim(1) & p.xData<xlim(2) & ...
            p.yData>ylim(1) & p.yData<ylim(2) & ...
            p.zData>zlim(1) & p.zData<zlim(2);
        
    case 'sphere'
        R = varargin{1};
        
        % If center specified
        if length(varargin)>1
            p = p - varargin{2};
        end
        
        r = norm(p);
        idx = r < R;
        
    case 'ellipsoid'
        % Parameters
        R_el = varargin{1};
        
        % If center specified
        if length(varargin)>1
            p = p - varargin{2};
        end
        
        r = norm(p);
        lambda = atan2(p.yData,p.xData);
        gamma = asin(p.zData./r); % around xy plane
        
        % Ellipsoid radius as a function of lambda and gamma (ref.
        % https://en.wikipedia.org/wiki/Ellipsoid)
        R = prod(R_el)./sqrt(R_el(3)^2.*(R_el(2)^2.*cos(lambda).^2 + R_el(1)^2.*sin(lambda).^2).*cos(gamma).^2 + ...
            R_el(1)^2*R_el(2)^2.*sin(gamma).^2);
        idx = r < R;
        
    case 'orthant'
        sign_pattern = vec3d(varargin{1});
        
        % If center specified
        if length(varargin)>1
            p = p - varargin{2};
        end
        
        orth_dims = norm(sign_pattern).^2; % Number of dimensions used (rays, quadrants, octants)
        idx = dot(sign(p),sign_pattern) > 0.9*orth_dims; % Use factor 0.9 for robustness agains rounding errors (eps)
end
