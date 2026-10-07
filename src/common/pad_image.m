function out = pad_image(img, pads, mode)
%PAD_IMAGE Padding citra 2D/3D tanpa Image Processing Toolbox.
[M, N, C] = size(img);
r = (1 - pads(1)):(M + pads(2));
c = (1 - pads(3)):(N + pads(4));
switch lower(mode)
    case 'zero'
        out = zeros(numel(r), numel(c), C, 'like', img);
        out(pads(1) + (1:M), pads(3) + (1:N), :) = img;
        return
    case 'replicate'
        r = min(max(r, 1), M);
        c = min(max(c, 1), N);
    case 'symmetric'
        r = mirror_index(r, M);
        c = mirror_index(c, N);
    otherwise
        error('pad_image: mode "%s" tidak dikenal', mode);
end
out = img(r, c, :);
end

function idx = mirror_index(idx, n)
k = mod(idx - 1, 2 * n);
k(k >= n) = 2 * n - 1 - k(k >= n);
idx = k + 1;
end
