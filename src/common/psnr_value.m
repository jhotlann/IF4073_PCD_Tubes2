function [p, m] = psnr_value(ref, img)
%PSNR_VALUE Menghitung PSNR (dB) dan MSE antara citra acuan dan citra uji (rentang [0,1]).
d = clip01(img) - ref;
m = mean(d(:) .^ 2);
p = 10 * log10(1 / max(m, eps));
end
