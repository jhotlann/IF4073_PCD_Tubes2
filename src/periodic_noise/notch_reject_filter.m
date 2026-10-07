function H = notch_reject_filter(type, P, Q, centers, D0, n)
%NOTCH_REJECT_FILTER Fungsi transfer notch reject terpusat berukuran PxQ.
if nargin < 6
    n = 2;
end
K = size(centers, 1);
if isscalar(D0)
    D0 = repmat(D0, K, 1);
end
[~, U, V] = freq_distance(P, Q);
H = ones(P, Q);
for k = 1:K
    for s = [1 -1]
        Dk = sqrt((U - s * centers(k, 1)) .^ 2 + (V - s * centers(k, 2)) .^ 2);
        H = H .* notch_hp(type, Dk, D0(k), n);
        if centers(k, 1) == 0 && centers(k, 2) == 0
            break
        end
    end
end
end

function Hk = notch_hp(type, Dk, D0, n)
switch lower(type)
    case 'ideal'
        Hk = double(Dk > D0);
    case 'gaussian'
        Hk = 1 - exp(-(Dk .^ 2) / (2 * D0 ^ 2));
    case 'butterworth'
        Hk = 1 ./ (1 + (D0 ./ (Dk + eps)) .^ (2 * n));
    otherwise
        error('Jenis notch "%s" tidak dikenal.', type);
end
end
