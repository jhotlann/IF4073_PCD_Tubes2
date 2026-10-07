function H = bandreject_filter(type, P, Q, C0, W, n)
%BANDREJECT_FILTER Fungsi transfer bandreject terpusat berukuran PxQ.
if nargin < 6
    n = 2;
end
D = freq_distance(P, Q);
switch lower(type)
    case 'ideal'
        H = ones(P, Q);
        H(D >= C0 - W / 2 & D <= C0 + W / 2) = 0;
    case 'gaussian'
        H = 1 - exp(-((D .^ 2 - C0 ^ 2) ./ (D * W + eps)) .^ 2);
    case 'butterworth'
        den = D .^ 2 - C0 ^ 2;
        den(den == 0) = eps;
        H = 1 ./ (1 + ((D * W) ./ den) .^ (2 * n));
    otherwise
        error('Jenis bandreject "%s" tidak dikenal.', type);
end
end
