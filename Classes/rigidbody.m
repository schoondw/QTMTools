classdef rigidbody < pose6d
    %rigidbody Rigid body representation and methods for working with
    %   Qualisys rigid bodies.
    
    %   Further expand help info
    
    properties
        Parent = ''     % Parent system (some type of pose6d) [char]
        Residual = [];  % Rigid body residual
    end
    
    methods
        function rb = rigidbody(pos,qrot,res,lab,par)
            if nargin < 1, pos=vec3d(); end
            if nargin < 2, qrot=quaternion(); end
            if nargin < 3, res=[]; end
            if nargin < 4, lab=''; end
            if nargin < 5, par=''; end
            rb@pose6d(pos,qrot,lab);
            rb.Residual = squeeze(res);
            %rb.Label = lab;
            rb.Parent = par;
        end
        
        function rbloc = global2local(rb,ref)
            %function rbloc = global2local(rb,ref)
            %   Transform segment data to reference segment coordinates.
            %   When the Position and Rotation properties of rb and ref
            %   are not the same size, calculation uses binary singleton
            %   expansion (for example tranform rb relative to fixed
            %   reference).
            rbloc = global2local@pose6d(rb,ref);
            rbloc.Parent = ref.Label;
        end
        
        function lst = getlabels(rb)
            % Get labels of rigid bodies (array)
            lst = {rb.Label};
        end
        
        function n_out = numArgumentsFromSubscript(obj,s,~)
            % Overloading for calculating correct number of output
            % arguments for subsref
            
            errid = 'rigidbodies:numArgumentsFromSubscript';
            n_out = numel(obj); % Default: total number of elements in array
            switch s(1).type
                case '()'
                    s1val = s(1).subs{1}; % Use first index value for test
                    if ischar(s1val) || isstring(s1val) || iscell(s1val) && ~contains(':',s1val) % Check first index value
                        LabelList = {obj.Label};
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
            
            % To do: fix method calls like rb_array.getlabels
            
            % To do (not urgent): fix subref types like "rb_array.Position(1)" (works for rb_array.Position, or rb_array(1).Position(1))
            
            errid = 'rigidbodies:subsref';
            switch s(1).type
                case '.'
                    [varargout{1:nargout}] = builtin('subsref',obj,s);
                case '()'
                    s1val = s(1).subs{1}; % Use first index value for test
                    if ischar(s1val) || isstring(s1val) || iscell(s1val) && ~contains(':',s1val) % Check first index value
                        LabelList = {obj.Label};
                        labels = parse_labels(errid, s(1).subs{:});
                        [present, obj_idx] = ismember(labels, LabelList);
                        
                        if sum(present) ~= length(labels)
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
        
    end %  methods
    
end % classdef rigidbody

% Helper functions

function labels = parse_labels(errid,varargin) % Move to pose6d with subsref
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

% Check for duplicates
if length(unique(labels)) < length(labels)
    error([errid, ':parse_input:check'],...
        'Duplicate labels not allowed.')
end

end % parse_labels
