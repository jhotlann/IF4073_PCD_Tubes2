function psf = motion_psf(L, theta, convention)
%MOTION_PSF PSF motion blur linear sepanjang L piksel dengan sudut theta (derajat).
if nargin < 3
    convention = 'image';
end
L = max(1, L);
half = (L - 1) / 2;
phi = theta * pi / 180;
c = cos(phi);
s = sin(phi);

rx = ceil(abs(half * c)) + 1;
ry = ceil(abs(half * s)) + 1;
[x, row] = meshgrid(-rx:rx, -ry:ry);
if strcmpi(convention, 'math')
    y = -row;
else
    y = row;
end

t = x * c + y * s;
t = max(-half, min(half, t));
dist = hypot(x - t * c, y - t * s);

psf = max(0, 1 - dist);
psf = psf / sum(psf(:));

while size(psf, 1) > 1 && ~any(psf([1 end], :), 'all')
    psf = psf(2:end-1, :);
end
while size(psf, 2) > 1 && ~any(psf(:, [1 end]), 'all')
    psf = psf(:, 2:end-1);
end
end
