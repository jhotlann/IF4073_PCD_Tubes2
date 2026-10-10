function Fhat = inverse_filter(G, H, opts)
%INVERSE_FILTER Inverse filtering F^(u,v) = G(u,v) / H(u,v) (spektrum TIDAK terpusat).
if nargin < 3
    opts = struct();
end
thr = get_opt(opts, 'threshold', 0);
D0 = get_opt(opts, 'radius', Inf);
n = get_opt(opts, 'order', 10);

Hs = H;
if thr > 0
    small = abs(Hs) < thr;
    Hs(small) = thr * exp(1i * angle(Hs(small)));
end
Hs(Hs == 0) = eps;
Fhat = G ./ Hs;

if isfinite(D0) && D0 > 0
    [P, Q] = size(G);
    D = ifftshift(freq_distance(P, Q));
    Fhat = Fhat ./ (1 + (D / D0) .^ (2 * n));
end
end

function v = get_opt(s, name, default)
if isfield(s, name) && ~isempty(s.(name))
    v = s.(name);
else
    v = default;
end
end
