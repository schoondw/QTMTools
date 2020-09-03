classdef trajectory < labeladmin2
    %trajectory Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Label = ''
%         Position = vec3d.empty()
%         Residual = []
%         Type = []
        Position vec3d
        Residual double
        Type double
    end
    
    methods
        function traj = trajectory(pos,res,type,lab)
            %trajectory Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 1, pos = vec3d(); end
            if nargin < 2, res = []; end
            if nargin < 3, type = []; end
            if nargin < 4, lab = ""; end
            
            if ~isa(pos,'vec3d')
                pos = vec3d(squeeze(pos));
            end
            
            % Check sizes of input
            szp = size(pos);
            if szp(2) > szp(1)
                pos = pos.'; % Convert to column
                szp = szp([2 1]);
            end
            
            if szp(2)~=1 % Only accept single row/column of position data
                error('trajectory:constructor','Invalid input') 
            end
            
            nfr = szp(1);
            
            if isempty(res)
                res = NaN(szp);
            else
                res = res(:);
            end
            
            if length(res) ~= nfr
                error('trajectory:constructor','Invalid input')
            end
            
            if isempty(type)
                type = NaN(szp);
            else
                type = type(:);
            end
            
            if length(type) ~= nfr
                error('trajectory:constructor','Invalid input')
            end
            
            traj.Label = lab;
            traj.Position = pos;
            traj.Residual = res;
            traj.Type = type;
        end
        
        function d = distance(tr1,tr2)
            %function d = distance(tr1,tr2)
            %  Calculate distance between trajectories
            %  Output d: double
            d = distance(tr1.Position,tr2.Position);
        end
        
        function v = minus(tr1,tr2)
            %function v = minus(tr1,tr2)
            %  Calculate difference between trajectories
            %  Output v: vec3d object
            v = minus(tr1.Position, tr2.Position);
        end
        
        function v = plus(tr1,tr2)
            %function v = plus(tr1,tr2)
            %  Calculate difference between trajectories
            %  Output v: vec3d object
            v = plus(tr1.Position, tr2.Position);
        end
        
        function v = rdivide(arg1,arg2)
            %function v = rdivide(arg1,arg2)
            %  Calculate difference between trajectories
            %  Output v: vec3d object
            if isa(arg1,'trajectory')
                arg1 = arg1.Position;
            end
            if isa(arg2,'trajectory')
                arg2 = arg2.Position;
            end
            v = rdivide(arg1,arg2);
        end
        
        function v = times(arg1,arg2)
            %function v = times(arg1,arg2)
            %  Calculate difference between trajectories
            %  Output v: vec3d object
            if isa(arg1,'trajectory')
                arg1 = arg1.Position;
            end
            if isa(arg2,'trajectory')
                arg2 = arg2.Position;
            end
            v = times(arg1,arg2);
        end
        
    end
end

