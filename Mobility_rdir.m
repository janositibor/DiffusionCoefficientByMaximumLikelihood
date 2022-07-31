function [varargout] = Mobility_rdir(rootdir,varargin)

if ~exist('rootdir','var'),
  rootdir = '*';
end
prepath = '';       % the path before the wild card
wildpath = '';      % the path wild card
postpath = rootdir; % the path after the wild card
I = find(rootdir==filesep,1,'last');

if filesep == '\'
  anti_filesep = '/';
else
  anti_filesep = '\';
end
if isempty(I) && ~isempty(strfind(rootdir, anti_filesep))
  error([mfilename, ':FileSep'],...
    'Use correct directory separator "%s".', filesep)
end

if ~isempty(I),
  prepath = rootdir(1:I);
  postpath = rootdir(I+1:end);
  I = find(prepath=='*',1,'first');
  if ~isempty(I),
    postpath = [prepath(I:end) postpath];
    prepath = prepath(1:I-1);
    I = find(prepath==filesep,1,'last');
    if ~isempty(I),
      wildpath = prepath(I+1:end);
      prepath = prepath(1:I);
    end;
    I = find(postpath==filesep,1,'first');
    if ~isempty(I),
      wildpath = [wildpath postpath(1:I-1)];
      postpath = postpath(I:end);
    end;
  end;
end;

if isempty(wildpath)
  
  D = dir([prepath postpath]);
  excl = isdotdir(D) | issvndir(D);
  D(excl) = [];
  if isdir([prepath postpath]);
    fullpath = [prepath postpath];
  else
    fullpath = prepath;
  end
  
  is_dir = [D.isdir]';
  D = [D(is_dir); D(~is_dir)];
  
  for ii = 1:length(D)
    D(ii).name = fullfile(fullpath, D(ii).name);
  end
  
elseif strcmp(wildpath,'**')
  D = Mobility_rdir([prepath postpath(2:end)]);
  D_sd = dir([prepath '*']);
  excl = isdotdir(D_sd) | issvndir(D_sd) | ~([D_sd.isdir]');
  D_sd(excl) = [];
  c_D = arrayfun(@(x) Mobility_rdir([prepath x.name filesep wildpath postpath]),...
    D_sd, 'UniformOutput', false);
  D = [D; cell2mat( c_D ) ];
  
else
  D_sd = dir([prepath wildpath]);
  excl = isdotdir(D_sd) | issvndir(D_sd) | ~([D_sd.isdir]');
  D_sd(excl) = [];
    
  if ~isdir(prepath) || ( numel(D_sd)==1 && strcmp(D_sd.name, prepath))
    prepath = '';
  end
  
  Dt = dir('');
  c_D = arrayfun(@(x) Mobility_rdir([prepath x.name postpath]),...
    D_sd, 'UniformOutput', false);
  D = [Dt; cell2mat( c_D ) ];
  
end

nb_before_filt = length(D);
warning_msg = '';
if (nargin>=2 && ~isempty(varargin{1})),
  try
    if isa(varargin{1}, 'function_handle')
        test_tf = arrayfun(varargin{1}, D);
    else
        test_tf = evaluate(D, varargin{1});
    end
    
    D = D(test_tf);
    
  catch
    if isa(varargin{1}, 'function_handle')
      test_expr = func2str(varargin{1});
    else
      test_expr = varargin{1};
    end
    
    warning_msg = sprintf('Invalid TEST "%s" : %s', test_expr, lasterr);
  end
end

common_path = '';
if (nargin>=3 && ~isempty(varargin{2})),
  arg2 = varargin{2};
  if ischar(arg2)
    common_path = arg2;    
  elseif (isnumeric(arg2) || islogical(arg2)) && arg2
    common_path = prepath;    
  end
  
  rm_path = regexptranslate('escape', common_path);

  start = regexp({D.name}', ['^', rm_path]);
  
  is_common = not( cellfun(@isempty, start) );
  if all(is_common)
    for k = 1:length(D)
      D(k).name = regexprep(D(k).name, ['^', rm_path], '');
    end
    
  else
    common_path = '';
  end
end

nout = nargout;
if nout == 0
  if isempty(D)
    if nb_before_filt == 0
      fprintf('%s not found.\n', rootdir)
    else
      fprintf('No item matching filter.\n')
    end
  else
    
    if ~isempty(common_path)
     fprintf('All in : %s\n', common_path) 
    end
    
    pp = {'' 'k' 'M' 'G' 'T'};
    for ii = 1:length(D)
      if D(ii).isdir
        disp(sprintf(' %29s %-64s','',D(ii).name));
      else
        sz = D(ii).bytes;
        if sz > 0
          ss = min(4,floor(log2(sz)/10));
        else
          ss = 0;
        end
        disp(sprintf('%4.0f %1sb  %20s  %-64s ',...
          sz/1024^ss, pp{ss+1}, datestr(D(ii).datenum, 0), D(ii).name));
      end
    end
  end
elseif nout == 1
  varargout{1} = D;
else
  varargout{1} = D;
  varargout{2} = common_path;
end;
if ~isempty(warning_msg)
  warning([mfilename, ':InvalidTest'],...
    warning_msg); % ap aff
end

function tf = issvndir(d)
is_dir = [d.isdir]';
is_svn = strcmp({d.name}, '.svn')';
tf = (is_dir & is_svn);

function tf = isdotdir(d)
is_dir = [d.isdir]';
is_dot = strcmp({d.name}, '.')';
is_dotdot = strcmp({d.name}, '..')';
tf = (is_dir & (is_dot | is_dotdot) );

function tf = evaluate(d, expr)
name = {d.name}'; %#ok<NASGU>
date = {d.date}'; %#ok<NASGU>
datenum = [d.datenum]'; %#ok<NASGU>
bytes = [d.bytes]'; %#ok<NASGU>
isdir = [d.isdir]'; %#ok<NASGU>
tf = eval(expr); % low risk since done in a dedicated subfunction.
if iscell(tf)
  tf = not( cellfun(@isempty, tf) );
end