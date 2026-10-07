function H = psf_to_otf(psf, P, Q)
%PSF_TO_OTF Fungsi degradasi H(u,v) dari PSF, berukuran PxQ (TIDAK terpusat).
[m, n] = size(psf);
pad = zeros(P, Q);
pad(1:m, 1:n) = psf;
pad = circshift(pad, [-floor(m / 2), -floor(n / 2)]);
H = fft2(pad);
end
