function show_image(ax, img, ttl)
%SHOW_IMAGE Menampilkan citra grayscale/RGB (tanpa imshow/Image Processing Toolbox).
if size(img, 3) == 3
    image(ax, clip01(img));
else
    imagesc(ax, img, [0 1]);
    colormap(ax, gray(256));
end
axis(ax, 'image', 'off');
if nargin > 2
    title(ax, ttl, 'Interpreter', 'none', 'FontSize', 9);
end
end
