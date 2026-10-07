function H = homomorphic_filter(P, Q, gammaL, gammaH, D0, c)
%HOMOMORPHIC_FILTER Fungsi transfer homomorfik terpusat berukuran PxQ.
D = freq_distance(P, Q);
H = (gammaH - gammaL) * (1 - exp(-c * (D .^ 2) / (D0 ^ 2))) + gammaL;
end
