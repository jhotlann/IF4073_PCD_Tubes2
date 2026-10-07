function [out, info] = smooth_image(img, type, D0, n, padMode)
%SMOOTH_IMAGE Image smoothing/blurring pada ranah frekuensi dengan LPF.
if nargin < 4 || isempty(n)
    n = 2;
end
if nargin < 5
    padMode = 'symmetric';
end
[out, info] = apply_frequency_filter(img, @(P, Q) lowpass_filter(type, P, Q, D0, n), padMode);
out = clip01(out);
end
