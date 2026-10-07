function fig = new_figure(name, visible)
%NEW_FIGURE Membuat figure (dapat disembunyikan untuk pemrosesan batch).
if nargin < 2
    visible = true;
end
vis = 'off';
if visible
    vis = 'on';
end
fig = figure('Name', name, 'NumberTitle', 'off', 'Color', 'w', ...
    'Visible', vis, 'Position', [50 50 1400 800]);
try
    fig.Theme = 'light';
catch
end
end
