classdef skeleton
    %skeleton Skeleton representation and methods for working with Qualisys
    %   skeletons.
    
    %   Further expand help info
    
    properties
        Name     = ''
        Segments = segment.empty()
    end
    
    properties (Access = private)
        SegmentAdmin = labeladmin()
    end
    
    methods
        % Create skeleton object with empty data
        function skel = skeleton(qsk)
            %skeleton Construct an instance of this class
            %   Detailed explanation goes here
            %   Input: QTM skeleton structure (single skeleton)
            if nargin < 1
                return; % return with default (empty) data
            end
            
            skel.SegmentAdmin = labeladmin(qsk.SegmentLabels); % Add to label admin
            skel.Name = qsk.SkeletonName;
            for k=qsk.NrOfSegments:-1:1 % In reverse order for allocation
                lab = qsk.SegmentLabels{k};
                pos = qsk.PositionData(:,k,:);
                qrot = qsk.RotationData(:,k,:);
                
                segment_index = k;
                skel.Segments(segment_index) = segment(pos,qrot,lab);
            end
        end
        
        % Parse from QTM mat file
        function skel = readSkeletonData(skel,qtmmatfile,skeleton_index)
            %readSkeletonData Summary of this method goes here
            %   Detailed explanation goes here
            if nargin < 2
                qtm=qtmread();
            elseif ischar(qtmmatfile)
                qtm=qtmread(qtmmatfile);
            elseif isstruct(qtmmatfile) && isfield(qtmmatfile,'Skeletons')
                qtm = qtmmatfile;
            elseif isstruct(qtmmatfile) && isfield(qtmmatfile,'SkeletonName')
                qtm.Skeletons = qtmmatfile;
            end
            
            if nargin < 3
                skeleton_index = 1;
            end
            
            if ~isfield(qtm,'Skeletons')
                error('QTM mat file does not contain skeleton data');
            else
                qsk=qtm.Skeletons(skeleton_index);
            end
            
            s0 = skel.SegmentAdmin.LabelCount;
            skel.SegmentAdmin = skel.SegmentAdmin.AppendLabels(qsk.SegmentLabels); % Add to label admin
            skel.Name = qsk.SkeletonName;
            for k=qsk.NrOfSegments:-1:1 % In reverse order for allocation
                lab = qsk.SegmentLabels{k};
                pos = qsk.PositionData(:,k,:);
                qrot = qsk.RotationData(:,k,:);
                
                segment_index = s0 + k;
                skel.Segments(segment_index) = segment(pos,qrot,lab);
            end
        end
        
        function showSegmentInfo(skel,lab)
            if ~skel.SegmentAdmin.LabelCheck(lab)
                fprintf('Segment "%s" not present.\n',lab);
            else
                segment_index = skel.SegmentAdmin.LabelIndex(lab);
                disp(skel.Segments(segment_index));
            end
        end
        
        function seg = getSegment(skel,lab)
            if ~skel.SegmentAdmin.LabelCheck(lab)
                error('skeleton:get_segment',...
                    'No segment with label ''%s'' found in skeleton object.',lab);
            else
                segment_index = skel.SegmentAdmin.LabelIndex(lab);
                seg = skel.Segments(segment_index);
            end
        end
        
        function sl = getSegmentList(skel)
            sl = skel.SegmentAdmin.Labels;
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
    error('skeleton:qtmread',...
        ['Wrong format of file: %s\n'...
        'Only one variable (QTM data structure) is expected in a .mat file exported by QTM.'], fname)
else
    qtm=S.(sflds{1});
    if ~isstruct(qtm)
        error('skeleton:qtmread',...
            'No data structure found in file: %s', fname)
    elseif ~isfield(qtm,'Skeletons')
        error('skeleton:qtmread',...
            'No Skeleton data found in file: %s', fname)
    end
end
end % qtmread
