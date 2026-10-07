function save_image(img, path)
%SAVE_IMAGE Menyimpan citra double [0,1] sebagai uint8.
folder = fileparts(path);
if ~isempty(folder) && ~exist(folder, 'dir')
    mkdir(folder);
end
imwrite(uint8(round(clip01(img) * 255)), path);
end
