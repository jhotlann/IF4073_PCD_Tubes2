function H = lowpass_filter(type, P, Q, D0, n)
%LOWPASS_FILTER Fungsi transfer low-pass H(u,v) terpusat berukuran PxQ.
if nargin < 5
    n = 2;
end
D = freq_distance(P, Q);
switch lower(type)
    case 'ideal'
        H = double(D <= D0);
    case 'gaussian'
        H = exp(-(D .^ 2) / (2 * D0 ^ 2));
    case 'butterworth'
        H = 1 ./ (1 + (D / D0) .^ (2 * n));
    otherwise
        error('Jenis LPF "%s" tidak dikenal (ideal | gaussian | butterworth).', type);
end
end
