function [fig, ps] = compare_periodic_filters(img, ref, cands, name, visible)
%COMPARE_PERIODIC_FILTERS Membandingkan beberapa penapis/parameter Bagian E.
if nargin < 5
    visible = true;
end
nc = numel(cands);
fig = new_figure(['E perbandingan - ' name], visible);
tl = tiledlayout(fig, 2, nc, 'TileSpacing', 'compact', 'Padding', 'loose');
title(tl, ['Perbandingan penapis: ' name], 'Interpreter', 'none');
outs = cell(1, nc);
infos = cell(1, nc);
ps = nan(1, nc);
for k = 1:nc
    [outs{k}, infos{k}] = restore_periodic_noise(img, cands{k});
    if ~isempty(ref)
        ps(k) = psnr_value(ref, outs{k});
    end
end
for k = 1:nc
    show_image(nexttile(tl), infos{k}.H, describe_periodic_filter(cands{k}));
end
for k = 1:nc
    ttl = '';
    if ~isempty(ref)
        ttl = sprintf('PSNR %.2f dB', ps(k));
    end
    show_image(nexttile(tl), outs{k}, ttl);
end
end
