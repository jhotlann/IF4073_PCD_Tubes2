function [out, info] = restore_motion_blur(img, L, theta, method, opts)
%RESTORE_MOTION_BLUR Restorasi citra motion blur pada ranah frekuensi.
if nargin < 5
    opts = struct();
end
convention = 'image';
if isfield(opts, 'convention'), convention = opts.convention; end
psf = motion_psf(L, theta, convention);
pad = 2 * max(size(psf));
if isfield(opts, 'pad'), pad = opts.pad; end

[M, N, C] = size(img);
if pad > 0
    x = pad_image(img, [pad pad pad pad], 'symmetric');
else
    x = img;
end
[P, Q, ~] = size(x);
H = psf_to_otf(psf, P, Q);

out = zeros(M, N, C);
G = complex(zeros(P, Q, C));
Fhat = G;
for k = 1:C
    Gk = fft2(x(:, :, k));
    switch lower(method)
        case 'inverse'
            Fk = inverse_filter(Gk, H, opts);
        case 'wiener'
            K = 0.01;
            if isfield(opts, 'K'), K = opts.K; end
            Fk = wiener_filter(Gk, H, K);
        otherwise
            error('Metode "%s" tidak dikenal (inverse | wiener).', method);
    end
    fk = real(ifft2(Fk));
    out(:, :, k) = fk(pad + (1:M), pad + (1:N));
    G(:, :, k) = fftshift(Gk);
    Fhat(:, :, k) = fftshift(Fk);
end
out = clip01(out);
info = struct('psf', psf, 'H', fftshift(H), 'G', G, 'Fhat', Fhat, 'pad', pad);
end
