function [D, U, V] = freq_distance(P, Q)
%FREQ_DISTANCE Matriks jarak D(u,v) dari pusat spektrum (setelah fftshift).
u = (0:P-1) - floor(P / 2);
v = (0:Q-1) - floor(Q / 2);
[V, U] = meshgrid(v, u);
D = sqrt(U .^ 2 + V .^ 2);
end
