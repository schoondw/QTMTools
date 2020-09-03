classdef labeladmin2
    %labeladmin2 Label object for naming and subreferencing subclass
    %   objects
    %   Use a superclass for objects to give them a label and be able to
    %   use it as a subreference for object arrays.
    
    properties
        Label string
    end
    
    methods
        function la = labeladmin2(lab)
            %labeladmin2 Construct an instance of this class
            %   Detailed explanation goes here
            
            if nargin < 1
                return; % return with default (empty) data
            end
            
            labstr = string(lab); % Convert to string
            
            % Input check (accepts all input, except input that converts to a string array)
            errid = 'labeladmin2:constructor';
            if numel(labstr) > 1
                error(errid,'Invalid input')
            end
            
            la.Label = labstr;
        end
        
        function idx = LabelIndex(obj,varargin)
            errid = 'labeladmin:LabelIndex';
            labels = parse_labels(errid, varargin{:});
            [present, idx] = ismember(labels, [obj.Label]);
            if sum(present) ~= length(labels)
                error(errid, 'One or several specified labels not present.')
            end
        end
        
        function present = LabelCheck(obj,varargin)
            errid = 'labeladmin:LabelCheck';
            labels = parse_labels(errid, varargin{:});
            present = ismember(labels, [obj.Label]);
        end

        function list = LabelList(obj)
            list = [obj.Label];
        end

        function n_out = numArgumentsFromSubscript(obj,s,~)
            % Overloading for calculating correct number of output
            % arguments for subsref
            
            errid = 'labeladmin:numArgumentsFromSubscript';
            n_out = numel(obj); % Default: total number of elements in array
            switch s(1).type
                case '()'
                    s1val = s(1).subs{1}; % Use first index value for test
                    if ischar(s1val) || isstring(s1val) || iscell(s1val) && ~contains(':',s1val) % Check first index value
                        LabelList = [obj.Label];
                        labels = parse_labels(errid, s(1).subs{:});
                        [~, obj_idx] = ismember(labels, LabelList);
                        
                        n_out = length(obj_idx);
                    else
                        n_out = length([s(1).subs{:}]);
                    end
            end
            
        end
        
        function varargout = subsref(obj,s) % Move to pose6d to make available for segment objects too
            % Overloading of subsref
            % Allow for using labels for subscripting of rigidbody arrays
            
            % Adapted from example in doc "Code Patterns for subsref and subsasgn Methods"
            
            % To do: - fix method calls like rb_array.LabelList (workaround: rb_array.LabelList())
            %        - fix label subreferencing for labeled objects which
            %          contain labeled properties (e.g. skeleton.Segments('Hips'))
            
            % To do (not urgent): fix subref types like "rb_array.Position(1)" (works for rb_array.Position, or rb_array(1).Position(1))
            
            errid = 'labeladmin:subsref';
            switch s(1).type
                case '.'
                    [varargout{1:nargout}] = builtin('subsref',obj,s);
                case '()'
                    s1val = s(1).subs{1}; % Use first index value for test
                    if ischar(s1val) || isstring(s1val) || iscell(s1val) && ~contains(':',s1val) % Check first index value
                        lablist = [obj.Label];
                        labs = parse_labels(errid, s(1).subs{:});
                        [present, obj_idx] = ismember(labs, lablist);
                        
                        if sum(present) ~= length(labs)
                            error(errid, 'One or several specified labels not present.')
                        else
                            s(1).subs = {obj_idx};
                        end
                    end
                    [varargout{1:nargout}] = builtin('subsref',obj,s);
                    
                otherwise
                    error(errid,'Not a valid indexing expression')
            end
        end % subsref
        
    end
end

% Helper functions

function labels = parse_labels(errid,varargin)
switch length(varargin)
    case 0
        labels = string([]);
        
    case 1
        siz = size(varargin{1});
        nel = prod(siz);
        
        if length(siz) > 2 || siz(1)~=1 && siz(2)~=1
            % Input should be single column or row
            error([errid, ':parse_input:nargin1'],...
                'Invalid input')
        end
        if isa(varargin{1},'cell')
            nchar = sum(cellfun(@ischar,varargin{1}));
            if nchar ~= nel
                error([errid, ':parse_input:nargin1'],...
                    'Invalid input')
            end
            labels = string(varargin{1}(:)'); % String array (row)
            
        elseif isa(varargin{1},'string')
            labels = varargin{1}(:)';
            
        elseif isa(varargin{1},'char')
            if siz(1) > 1
                error([errid, ':parse_input:nargin1'],...
                    'Invalid input')
            end
            labels = string(varargin{1});
            
        else
            error([errid, ':parse_input:nargin1'],...
                'Invalid input')
        end
        
    otherwise
        % comma separated char or string input
        if isa(varargin{1},'char') && ...
                sum(cellfun(@ischar,varargin))
            labels = string(varargin(:)');
            
        elseif isa(varargin{1},'string') && ...
                sum(cellfun(@isstring,varargin))
            labels = [varargin{:}];
            
        else
            error([errid, ':parse_input:nargin2'],...
                'Invalid input')
        end
end % switch

end % parse_input

