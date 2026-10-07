function H = highpass_filter(type, P, Q, D0, n)
%HIGHPASS_FILTER Fungsi transfer high-pass H(u,v) terpusat berukuran PxQ.
if nargin < 5
    n = 2;
end
H = 1 - lowpass_filter(type, P, Q, D0, n);
end
