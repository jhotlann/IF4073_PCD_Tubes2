function img = rescale01(img)
%RESCALE01 Normalisasi min-max ke [0,1] (untuk menampilkan hasil HPF, mask, dsb.).
lo = min(img(:));
hi = max(img(:));
if hi - lo < eps
    img = zeros(size(img));
else
    img = (img - lo) / (hi - lo);
end
end
