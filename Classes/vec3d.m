classdef vec3d
    %vec3d 3D vector representation and methods.
    %   All you need for your 3D mocap data
    %   
    %   Partly adapted from (and dependent on):
    %     Mark Tincknell (2020). quaternion
    %     (https://www.mathworks.com/matlabcentral/fileexchange/33341-quaternion),
    %     MATLAB Central File Exchange. Retrieved May 27, 2020.
    
    properties  (SetAccess = protected)
        e = zeros(3,1);
    end
    
    properties (Dependent)
        x
        y
        z
    end
    
    methods
        function p = vec3d(varargin)
            %function p = vec3d(vec)
            %  Construct an instance of this class
            perm = [];
            sqz  = false;
            switch nargin
                
                case 0  % nargin == 0
                    p.e = zeros(3,1);
                    return;
                    
                case 1  % nargin == 1
                    siz = size( varargin{1} );
                    nel = prod( siz );
                    if nel == 0
                        p	= vec3d.empty;
                        return;
                    elseif isa( varargin{1}, 'vec3d' )
                        p   = varargin{1};
                        return;
                    end
                    [arg3, dim3, perm3] = finddim( varargin{1}, 3 );
                    if dim3 > 0
                        siz(dim3)   = 1;
                        nel         = prod( siz );
                        if dim3 > 1
                            perm    = perm3;
                        else
                            sqz     = true;
                        end
                        for iel = nel : -1 : 1
                            p(iel).e = chop( arg3(:,iel) );
                        end
                    else
                        error( 'vec3d:constructor:nargin1', ...
                            'Invalid input' );
                    end
                    
                otherwise
                    error( 'vec3d:constructor:input', ...
                        'Invalid input' );
            end
            
            if nel == 0
                p   = vec3d.empty;
            end
            p   = reshape( p, siz );
            if ~isempty( perm )
                p   = ipermute( p, perm );
            end
            if sqz
                p   = squeeze( p );
            end
        end %vec3d
        
        function x = get.x(p)
            x = p.e(1);
        end
        
        function y = get.y(p)
            y = p.e(2);
        end
        
        function z = get.z(p)
            z = p.e(3);
        end
        
        function d = distance(p1,p2)
            %function d = distance(p1,p2)
            %   Calculate distance between p1 and p2.
            %   When p1 and p2 are not the same size calculation uses
            %   binary singleton expansion (for example
            %   distance between array p1 to fixed point p2).
            d = norm(p2-p1);
        end
        
        function pr = rotate_vec3d(p,q)
            %function pr = rotate_vec3d(p,q)
            %   Rotates vector using quaternion.RotateVector
            %   When p and q are not the same size calculation uses binary
            %   singleton expansion (for example rotation of array p
            %   relative to fixed reference).
            sp = size(p);
            pr = vec3d(q.RotateVector(double(p))); % Use quaternion.RotateVector
            pr = reshape(pr,sp);
        end
        
        % Overload standard methods
        function n = abs( p )
            n   = p.norm;
        end % abs
        
        function p3 = cross( p1, p2 )
            si1 = size( p1 );
            si2 = size( p2 );
            ne1 = prod( si1 );
            ne2 = prod( si2 );
            if (ne1 == 0) || (ne2 == 0)
                p3  = vec3d.empty;
                return;
            elseif ne1 == 1
                siz = si2;
            elseif ne2 == 1
                siz = si1;
            elseif isequal( si1, si2 )
                siz = si1;
            else
                error( 'vec3d:cross:baddims', ...
                    'Matrix dimensions must agree' );
            end
            d3 = bsxfun( @cross, [p1.e], [p2.e] );
            p3 = vec3d(d3);
            p3 = reshape( p3, siz );
        end % cross
        
        function pd = diff( p, ord, dim )
            %function pd = diff( p, ord, dim )
            %  vec3d array difference, ord is the order of difference (default = 1)
            %  dim defaults to first dimension of length > 1
            if isempty( p )
                pd  = p;
                return;
            end
            if (nargin < 2) || isempty( ord )
                ord = 1;
            end
            if ord <= 0
                pd  = p;
                return;
            end
            if (nargin < 3) || isempty( dim )
                [p, dim, perm]  = finddim( p, -2 );
            elseif dim > 1
                ndm  = ndims( p );
                perm = [ dim : ndm, 1 : dim-1 ];
                p    = permute( p, perm );
            end
            siz = size( p );
            if siz(1) <= 1
                pd  = vec3d.empty;
                return;
            end
            pd  = vec3d.zeros( [(siz(1)-1), siz(2:end)] );
            for is = 1 : siz(1)-1
                pd(is,:) = p(is+1,:) - p(is,:);
            end
            ord = ord - 1;
            if ord > 0
                pd  = diff( pd, ord, 1 );
            end
            if dim > 1
                pd  = ipermute( pd, perm );
            end
        end % diff
        
        function d = dot( p1, p2 )
            % function d = dot( p1, p2 )
            % vec3d element dot product: d = dot( p1.e, p2.e ), using binary
            % singleton expansion of vec3d arrays
            % dn = dot( p1, p2 )/( norm(p1) * norm(p2) ) is the cosine of the angle in
            % 3D space between 3D vectors p1.e and p2.e
            d   = squeeze( sum( bsxfun( @times, double( p1 ), double( p2 )), 1 ));
        end % dot
        
        function d = double( p )
            siz = size( p );
            d   = reshape( [p.e], [3 siz] );
            d   = chop( d );
        end % double
        
        function l = isnan( p )
            % function l = isnan( p ), l = any( isnan( p.e ))
            d   = [p.e];
            l   = reshape( any( isnan( d ), 1 ), size( p ));
        end % isnan
        
        function pm = mean( p )
            % To be added (including all mean arguments)
            error('vec3d:mean',...
                'Method not implemented yet.')
        end
        
        function p3 = minus( p1, p2 )
            si1 = size( p1 );
            si2 = size( p2 );
            ne1 = prod( si1 );
            ne2 = prod( si2 );
            if (ne1 == 0) || (ne2 == 0)
                p3  = vec3d.empty;
                return;
            elseif ne1 == 1
                siz = si2;
            elseif ne2 == 1
                siz = si1;
            elseif isequal( si1, si2 )
                siz = si1;
            else
                error( 'vec3d:minus:baddims', ...
                    'Matrix dimensions must agree' );
            end
            d3 = bsxfun( @minus, [p1.e], [p2.e] );
            p3 = vec3d(d3);
            p3 = reshape( p3, siz );
        end % minus
        
        function n = norm(p)
            n   = shiftdim( sqrt( sum( double( p ).^2, 1 )), 1 );
        end % norm
        
        function [p, n] = normalize( p )
            % function [p, n] = normalize( p )
            % p = vectors with norm == 1 (unless p == 0), n = former norms
            siz = size( p );
            nel = prod( siz );
            if nel == 0
                if nargout > 1
                    n   = zeros( siz );
                end
                return;
            end
            d   = double( p );
            n   = sqrt( sum( d.^2, 1 ));
            if all( n(:) == 1 )
                if nargout > 1
                    n   = shiftdim( n, 1 );
                end
                return;
            end
            n3  = repmat( n, [3, ones(1,ndims(n)-1)] );
            ne0 = (n3 ~= 0) & (n3 ~= 1);
            d(ne0)  = d(ne0) ./ n3(ne0);
            % p   = reshape( quaternion( d(1,:), d(2,:), d(3,:), d(4,:) ), siz );
            p   = reshape( vec3d( d ), siz );
            if nargout > 1
                n   = shiftdim( n, 1 );
            end
        end % normalize
        
        function p3 = plus( p1, p2 )
            si1 = size( p1 );
            si2 = size( p2 );
            ne1 = prod( si1 );
            ne2 = prod( si2 );
            if (ne1 == 0) || (ne2 == 0)
                p3  = vec3d.empty;
                return;
            elseif ne1 == 1
                siz = si2;
            elseif ne2 == 1
                siz = si1;
            elseif isequal( si1, si2 )
                siz = si1;
            else
                error( 'vec3d:plus:baddims', ...
                    'Matrix dimensions must agree' );
            end
            d3 = bsxfun( @plus, [p1.e], [p2.e] );
            p3 = vec3d(d3);
            p3 = reshape( p3, siz );
        end % plus
        
        function pq = power( p, q )
            %function pq = power( p, q )
            %  vec3d power: pq = p.^q
            sip = size( p );
            siq = size( q );
            nep = prod( sip );
            neq = prod( siq );
            if (nep == 0) || (neq == 0)
                pq  = vec3d.empty;
                return;
            elseif ~isequal( sip, siq ) && (nep ~= 1) && (neq ~= 1)
                error( 'vec3d:power:baddims', ...
                    'Matrix dimensions must agree' );
            end
            dq = double(p).^q;
            pq = vec3d(dq);
            pq = reshape( pq, sip );
        end % power
        
        function ps = sum( p, dim )
            % function ps = sum( p, dim )
            % vec3d array sum over dimension dim
            % dim defaults to first dimension of length > 1
            if isempty( p )
                ps  = p;
                return;
            end
            if (nargin < 2) || isempty( dim )
                [p, dim, perm]  = finddim( p, -2 );
            elseif dim > 1
                ndm  = ndims( p );
                perm = [ dim : ndm, 1 : dim-1 ];
                p    = permute( p, perm );
            end
            siz = size( p );
            ps  = reshape( p(1,:), [1 siz(2:end)] );
            for is = 2 : siz(1)
                ps(1,:) = ps(1,:) + p(is,:);
            end
            if dim > 1
                ps  = ipermute( ps, perm );
            end
        end % sum
        
        function pr = sqrt( p )
            pr  = p.^0.5;
        end % sqrt
        
    end %methods
    
    methods(Static)
        
        function p = zeros( varargin )
            % function q = vec3d.zeros( siz )
            if isempty( varargin )
                siz = [1 1];
            elseif numel( varargin ) > 1
                siz = [varargin{:}];
            elseif isempty( varargin{1} )
                siz = [0 0];
            elseif numel( varargin{1} ) > 1
                siz = varargin{1};
            else
                siz = [varargin{1} varargin{1}];
            end
            if prod( siz ) == 0
                p = reshape( vec3d.empty, siz );
            else
                p = vec3d(zeros([3 siz]));
                p = reshape(p,siz);
            end
        end % vec3d.zeros
        
    end % methods(Static)
end % class def vec3d

% Helper functions
function out = chop( in, tol )
%function out = chop( in, tol )
% Replace values that differ from an integer by <= tol by the integer
% Inputs:
%  in       input array
%  tol      tolerance, default = eps(16)
% Output:
%  out      input array with integer replacements, if any
if (nargin < 2) || isempty( tol )
    tol = eps(16);
end
out = double( in );
rin = round( in );
lx  = abs( rin - in ) <= tol;
out(lx) = rin(lx);
end % chop

function [aout, dim, perm] = finddim( ain, len )
%function [aout, dim, perm] = finddim( ain, len )
% Find first dimension in ain of length len, permute ain to make it first
% Inputs:
%  ain(s1,s2,...)   data array, size = [s1, s2, ...]
%  len              length sought, e.g. s2 == len
%                   if len < 0, then find first dimension >= |len|
% Outputs:
%  aout(s2,...,s1)  data array, permuted so first dimension is length len
%  dim              dimension number of length len, 0 if ain has none
%  perm             permutation order (for permute and ipermute) of aout,
%                   e.g. [2, ..., 1]
% Notes: if no dimension has length len, aout = ain, dim = 0, perm = 1:ndm
%        ain = ipermute( aout, perm )
siz  = size( ain );
ndm  = length( siz );
if len < 0
    dim  = find( siz >= -len, 1, 'first' );
else
    dim  = find( siz == len, 1, 'first' );
end
if isempty( dim )
    dim  = 0;
end
if dim < 2
    aout = ain;
    perm = 1 : ndm;
else
% Permute so that dim becomes the first dimension
    perm = [ dim : ndm, 1 : dim-1 ];
    aout = permute( ain, perm );
end
end % finddim