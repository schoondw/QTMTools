classdef mocapdata
    %mocapdata Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name = ''; % File, Timestamp, StartFrame, Frames, FrameRate
        Trajectories = trajectory.empty()
        RigidBodies = rigidbody.empty()
        Skeletons = skeleton.empty()
    end
    
    properties (Access = private)
        TrajAdmin = labeladmin()
        RBAdmin = labeladmin()
        SkelAdmin = labeladmin()
    end
    
    
    methods
        function mc = mocapdata(varargin)
            %mocapdata Construct an instance of this class
            %   Detailed explanation goes here
            qtm_header_flds = {'File','Timestamp',...
                'StartFrame','Frames','FrameRate'};
            
            switch nargin
                case 0
                    return; % Return with default (empty) data
                    
                case 1
                    % Parse data from QTM mat file
                    if ischar(varargin{1})
                        qtm = qtmread(qtm);
                    elseif isstruct(varargin{1}) && ...
                            sum(isfield(varargin{1},qtm_header_flds)) == length(qtm_header_flds)
                        qtm = varargin{1};
                    end
                    
                    % Parse trajectories
                    if isfield(qtm,'Trajectories') && ...
                            isfield(qtm.Trajectories,'Labeled')
                        traj_array = parse_trajectories(qtm.Trajectories.Labeled);
                        
                        mc.TrajAdmin = labeladmin({traj_array.Label});
                        mc.Trajectories = traj_array;
                    end
                    
                    % Similar for rigid bodies and skeletons
                    
            end
            
        end
        
        % To do: replace read functions by helper parse functions called by
        % constructor
        
%         % Parse labeled trajectories from QTM mat file
%         function mc = readTrajectories(mc,qtmmatfile)
%             %readTrajectories Summary of this method goes here
%             %   Detailed explanation goes here
%             if nargin < 2
%                 qtm = qtmread();
%             elseif ischar(qtmmatfile)
%                 qtm = qtmread(qtmmatfile);
%             elseif isstruct(qtmmatfile)
%                 qtm = qtmmatfile;
%             end
%             
%             if ~isfield(qtm,'Trajectories') || ...
%                     ~isfield(qtm.Trajectories,'Labeled')
%                 error('mocapdata:readTrajectories',...
%                     'QTM mat file does not contain labeled trajecotry data');
%             else
%                 trs=qtm.Trajectories.Labeled;
%             end
%             
%             t0 = mc.TrajAdmin.LabelCount;
%             mc.TrajAdmin = mc.TrajAdmin.AppendLabels(trs.Labels); % Add to label admin
%             
%             ntr = trs.Count;
%             for k=ntr:-1:1 % In reverse order for allocation
%                 lab = trs.Labels{k};
%                 pos = trs.Data(k,1:3,:);
%                 res = trs.Data(k,4,:);
%                 type = trs.Type(k,:);
%                 
%                 tr_index = t0 + k;
%                 mc.Trajectories(tr_index) = trajectory(pos,res,type,lab);
%             end
%         end
        
        function idx = getTrajIndex(mc,labs)
            %function idx = getTrajIndex(mc,labs)
            %  Get index to trajectory labels in same order as labs
            %  Input: labs can be a char, cell of char or string array
            idx = mc.TrajAdmin.LabelIndex(labs);
        end
        
        % Parse rigid bodies from QTM mat file
        function mc = readRigidBodies(mc,qtmmatfile)
            %readRigidBodies Summary of this method goes here
            %   Detailed explanation goes here
            if nargin < 2
                qtm = qtmread();
            elseif ischar(qtmmatfile)
                qtm = qtmread(qtmmatfile);
            elseif isstruct(qtmmatfile)
                qtm = qtmmatfile;
            end
            
            if ~isfield(qtm,'RigidBodies')
                error('mocapdata:readRigidBodies',...
                    'QTM mat file does not contain rigid body data');
            else
                rbs=qtm.RigidBodies;
            end
            
            r0 = mc.RBAdmin.LabelCount;
            mc.RBAdmin = mc.RBAdmin.AppendLabels(rbs.Name); % Add to label admin
            
            nrb = rbs.Bodies;
            for k=nrb:-1:1 % In reverse order for allocation
                lab = rbs.Name{k};
                pos = rbs.Positions(k,:,:);
                rot = rbs.Rotations(k,:,:);
                res = rbs.Residual(k,:,:);
                
                rb_index = r0 + k;
                mc.RigidBodies(rb_index) = rigidbody(pos,rot,res,lab);
            end
        end
        
        function idx = getRBIndex(mc,labs)
            %function idx = getRBIndex(mc,labs)
            %  Get index to rigid bodies in same order as labs
            %  Input: labs can be a char, cell of char or string array
            idx = mc.RBAdmin.LabelIndex(labs);
        end
        
        function mc = readSkeletons(mc,qtmmatfile)
            %readSkeletons Summary of this method goes here
            %   Detailed explanation goes here
            if nargin < 2
                qtm = qtmread();
            elseif ischar(qtmmatfile)
                qtm = qtmread(qtmmatfile);
            elseif isstruct(qtmmatfile)
                qtm = qtmmatfile;
            end
            
            if ~isfield(qtm,'Skeletons')
                error('mocapdata:readSkeletons',...
                    'QTM mat file does not contain skeleton data');
            end
            
            skels = qtm.Skeletons;
            nsk = length(skels);
            
            s0 = mc.SkelAdmin.LabelCount;
            mc.SkelAdmin = mc.SkelAdmin.AppendLabels({skels.SkeletonName}); % Add to label admin
            for k = nsk:-1:1
                sk_index = s0 + k;
                mc.Skeletons(sk_index) = skeleton(skels(k));
            end
            
        end
        
    end
end


% Helper functions
% - Read QTM mat file
function qtm=qtmread(fn)
% Read QTM MAT file
if nargin==0
    [fname,pname] = uigetfile({'*.mat', '.mat files'}, 'Load QTM mat file');
    fn = [pname fname];
end

S=load(fn);

% Parse S
sflds=fieldnames(S);
if length(sflds)>1
    error('mocapdata:qtmread',...
        ['Wrong format of file: %s\n'...
        'Only one variable (QTM data structure) is expected in a .mat file exported by QTM.'], fname)
else
    qtm=S.(sflds{1});
    if ~isstruct(qtm)
        error('mocapdata:qtmread',...
            'No data structure found in file: %s', fname)
    end
end
end % qtmread


function traj_array = parse_trajectories(qtmstruct)
% Parse labeled trajectory data
% Input:
% - qtm data struct
% - qtm.Trajectories.Labeled struct

traj_flds = {'Count','Labels','Data','Type'};

if isfield(qtmstruct,'Trajectories') && ...
        isfield(qtmstruct.Trajectories,'Labeled')
    trs=qtmstruct.Trajectories.Labeled;
elseif sum(isfield(qtmstruct,traj_flds)) == length(traj_flds)
    trs = qtmstruct;
else
    error('mocapdata:parse_trajectories','Invalid input')
end

ntr = trs.Count;
for k=ntr:-1:1 % In reverse order for allocation
    lab = trs.Labels{k};
    pos = trs.Data(k,1:3,:);
    res = trs.Data(k,4,:);
    type = trs.Type(k,:);
    
    tr_index = k;
    traj_array(tr_index) = trajectory(pos,res,type,lab);
end
end % parse_trajectories
