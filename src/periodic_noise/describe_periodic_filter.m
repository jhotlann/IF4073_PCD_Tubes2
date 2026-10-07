function s = describe_periodic_filter(c)
%DESCRIBE_PERIODIC_FILTER Deskripsi singkat konfigurasi penapis Bagian E.
if strcmpi(c.filter, 'notch')
    s = sprintf('notch %s D0=%s, %d pasang', c.type, ...
        strjoin(compose('%g', unique(c.D0(:)')), '/'), size(c.centers, 1));
else
    s = sprintf('bandreject %s C0=%.1f W=%g', c.type, c.C0, c.W);
end
if strcmpi(c.type, 'butterworth')
    s = sprintf('%s n=%g', s, c.n);
end
end
