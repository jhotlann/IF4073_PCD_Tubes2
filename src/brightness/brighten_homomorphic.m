function [out, info] = brighten_homomorphic(img, gammaL, gammaH, D0, c, gain, padMode)
%BRIGHTEN_HOMOMORPHIC Peningkatan kecerahan dengan penapisan homomorfik.
if nargin < 6 || isempty(gain)
    gain = 1;
end
if nargin < 7
    padMode = 'symmetric';
end
offset = 1 / 255;
z = log(img + offset);

[M, N, C] = size(img);
if strcmpi(padMode, 'none')
    P = M; Q = N;
else
    P = 2 * M; Q = 2 * N;
end
H = homomorphic_filter(P, Q, gammaL, gammaH, D0, c);
dc = [floor(P / 2) + 1, floor(Q / 2) + 1];

out = zeros(M, N, C);
F = complex(zeros(P, Q, C));
S = F;
for k = 1:C
    if strcmpi(padMode, 'none')
        zp = z(:, :, k);
    else
        zp = pad_image(z(:, :, k), [0 P-M 0 Q-N], padMode);
    end
    F(:, :, k) = fftshift(fft2(zp));
    Sk = H .* F(:, :, k);
    Sk(dc(1), dc(2)) = Sk(dc(1), dc(2)) + P * Q * log(gain);
    S(:, :, k) = Sk;
    sp = real(ifft2(ifftshift(Sk)));
    out(:, :, k) = exp(sp(1:M, 1:N)) - offset;
end
out = clip01(out);
info = struct('H', H, 'F', F, 'G', S, 'P', P, 'Q', Q, 'padMode', padMode);
end
