function p = project_paths()
%PROJECT_PATHS Lokasi folder proyek, dataset, dan hasil.
src = fileparts(fileparts(mfilename('fullpath')));
p.src = src;
p.root = fileparts(src);
p.dataset = fullfile(p.root, 'dataset');
p.results = fullfile(p.root, 'results');
end
