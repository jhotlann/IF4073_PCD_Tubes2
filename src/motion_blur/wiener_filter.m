function Fhat = wiener_filter(G, H, K)
%WIENER_FILTER Penapis Wiener parametrik (spektrum TIDAK terpusat).
denom = abs(H) .^ 2 + max(K, 0);
denom(denom == 0) = eps;
Fhat = conj(H) ./ denom .* G;
end
