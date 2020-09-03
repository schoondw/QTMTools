classdef skeleton < labeladmin2
    %skeleton Skeleton representation and methods for working with Qualisys
    %   skeletons.
    
    %   Further expand help info
    
    properties
        % Name     = ''
        % Segments = segment.empty()
        Segments segment
    end
    
%     properties (Access = private)
%         SegmentAdmin = labeladmin()
%     end
    
    methods
        % Create skeleton object from QTM skeleton structure
        function skel = skeleton(qsk)
            %skeleton Construct an instance of this class
            %   Detailed explanation goes here
            %   Input: QTM skeleton structure (single skeleton)
%             if nargin < 1
%                 return; % return with default (empty) data
%             end
            
            % skel.SegmentAdmin = labeladmin(qsk.SegmentLabels); % Add to label admin
            % skel.Name = qsk.SkeletonName;
            skel@labeladmin2(qsk.SkeletonName); % Does not work with the empty return statment above
            % skel.Label = qsk.SkeletonName;
            for k=qsk.NrOfSegments:-1:1 % In reverse order for allocation
                lab = qsk.SegmentLabels{k};
                pos = qsk.PositionData(:,k,:);
                qrot = qsk.RotationData(:,k,:);
                
                % segment_index = k;
                skel.Segments(k) = segment(pos,qrot,lab);
            end
        end % constructor
        
        % Separate overload of numArgumentsFromSubscript needed here?
        
        function varargout = subsref(skel,s)
            % Overloading of subsref for skeleton class to deal with
            % segments in skeletons
            errid = 'skeleton:subsref';
            switch s(1).type
                case '.'
                    if numel(s) > 1 && strcmp('Segments',s(1).subs) % Work around for nested labels objects (skeleton > segment)
                        s2val = s(2).subs{1};
                        if (ischar(s2val) || isstring(s2val) || iscell(s2val) && ~contains(':',s2val))
                            for k = numel(skel):-1:1 % number of skeletons as nargout (somehow not specified)
                                segm = skel(k).Segments;
                                varargout{k} = subsref(segm,s(2:end));
                            end
                        else
                            [varargout{1:nargout}] = builtin('subsref',skel,s);
                        end
                    else
                        [varargout{1:nargout}] = builtin('subsref',skel,s);
                    end
                    
                case '()'
                    if numel(s) > 2  && strcmp('Segments',s(2).subs)
                        s3val = s(3).subs{1};
                        if (ischar(s3val) || isstring(s3val) || iscell(s3val) && ~contains(':',s3val))
                            skel_sub=subsref@labeladmin2(skel,s(1));
                            for k = numel(skel_sub):-1:1
                                segm = skel_sub(k).Segments;
                                varargout{k} = subsref(segm,s(3:end));
                            end
                        else
                            [varargout{1:nargout}] = builtin('subsref',skel,s);
                        end
                    else
                        [varargout{1:nargout}] = builtin('subsref',skel,s);
                    end
                    
                otherwise
                    [varargout{1:nargout}] = builtin('subsref',skel,s);
                    
            end
        end % subsref
        
    end
    
end
