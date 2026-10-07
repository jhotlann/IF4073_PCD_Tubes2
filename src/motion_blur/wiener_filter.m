function Fhat = wiener_filter(G, H, K)
%WIENER_FILTER Penapis Wiener parametrik (spektrum TIDAK terpusat).
Fhat = conj(H) ./ (abs(H) .^ 2 + K) .* G;
end
