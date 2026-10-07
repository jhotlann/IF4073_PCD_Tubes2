function [out, info] = restore_periodic_noise(img, cfg)
%RESTORE_PERIODIC_NOISE Restorasi derau periodik dengan bandreject/notch reject.
n = 2;
if isfield(cfg, 'n'), n = cfg.n; end
switch lower(cfg.filter)
    case 'bandreject'
        Hfun = @(P, Q) bandreject_filter(cfg.type, P, Q, cfg.C0, cfg.W, n);
    case 'notch'
        Hfun = @(P, Q) notch_reject_filter(cfg.type, P, Q, cfg.centers, cfg.D0, n);
    otherwise
        error('Penapis "%s" tidak dikenal (bandreject | notch).', cfg.filter);
end
[out, info] = apply_frequency_filter(img, Hfun, 'none');
out = clip01(out);
end
