function [out, info] = highpass_image(img, type, D0, n, padMode)
%HIGHPASS_IMAGE Penapisan high-pass pada ranah frekuensi.
if nargin < 4 || isempty(n)
    n = 2;
end
if nargin < 5
    padMode = 'symmetric';
end
[out, info] = apply_frequency_filter(img, @(P, Q) highpass_filter(type, P, Q, D0, n), padMode);
end
