function S = log_spectrum(F)
%LOG_SPECTRUM Magnitude spectrum log(1+|F|) ternormalisasi [0,1] untuk ditampilkan.
S = log(1 + mean(abs(F), 3));
S = rescale01(S);
end
