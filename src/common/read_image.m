function img = read_image(path)
%READ_IMAGE Membaca citra grayscale/berwarna sebagai double [0,1].
[img, map] = imread(path);
if ~isempty(map)
    img = reshape(map(double(img) + 1, :), [size(img) 3]);
end
img = to_double(img);
if size(img, 3) > 3
    img = img(:, :, 1:3);
end
end
