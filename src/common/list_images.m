function files = list_images(folder)
%LIST_IMAGES Daftar path lengkap citra (png/jpg/tif/bmp) dalam folder, terurut.
exts = {'*.png', '*.jpg', '*.jpeg', '*.tif', '*.tiff', '*.bmp'};
files = {};
for k = 1:numel(exts)
    d = dir(fullfile(folder, exts{k}));
    files = [files, fullfile({d.folder}, {d.name})]; %#ok<AGROW>
end
files = unique(files);
end
