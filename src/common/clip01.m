function img = clip01(img)
%CLIP01 Memotong nilai citra ke rentang [0,1].
img = min(max(img, 0), 1);
end
