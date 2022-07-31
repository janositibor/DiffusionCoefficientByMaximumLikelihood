function Mobility_path()

file = matlab.desktop.editor.getActiveFilename;
[ut,name,ext] = fileparts(file);

if ispc
  % Windows is not case-sensitive
  onPath = ~isempty(strfind(lower(path),lower(ut)));
else
  onPath = ~isempty(strfind(path,'H:\Documents\MATLAB;'));
end

if ~onPath
	oldpath = path;
	path(oldpath,ut);
	fprintf('Added: %s\n',ut);

	savepath
	fprintf('Path saved\n');
end