function [out, info] = apply_frequency_filter(img, Hspec, padMode)
%APPLY_FREQUENCY_FILTER Penapisan G(u,v) = H(u,v) F(u,v) per kanal warna.
if nargin < 3
    padMode = 'symmetric';
end
[M, N, C] = size(img);
if strcmpi(padMode, 'none')
    P = M; Q = N;
else
    P = 2 * M; Q = 2 * N;
end

if isa(Hspec, 'function_handle')
    H = Hspec(P, Q);
else
    H = Hspec;
end
if ~isequal(size(H), [P Q])
    error('Ukuran H (%dx%d) tidak sesuai dengan ukuran padding (%dx%d).', ...
        size(H, 1), size(H, 2), P, Q);
end

out = zeros(M, N, C);
F = complex(zeros(P, Q, C));
G = F;
for k = 1:C
    if strcmpi(padMode, 'none')
        fp = img(:, :, k);
    else
        fp = pad_image(img(:, :, k), [0 P-M 0 Q-N], padMode);
    end
    F(:, :, k) = fftshift(fft2(fp));
    G(:, :, k) = H .* F(:, :, k);
    gp = real(ifft2(ifftshift(G(:, :, k))));
    out(:, :, k) = gp(1:M, 1:N);
end

info = struct('H', H, 'F', F, 'G', G, 'P', P, 'Q', Q, 'padMode', padMode);
end
