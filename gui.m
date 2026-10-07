function gui()
% GUI - Aplikasi Pemrosesan Citra Ranah Frekuensi (Tugas 2 IF4073 PCD)
% Studio Minimalis: Dark-viewport axes, crisp typography, preset dataset, & live PSNR.

% 1. Setup paths
thisDir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(thisDir, 'src')));

% 2. Main Window
fig = figure('Name', 'IF4073 PCD — Pemrosesan Citra Ranah Frekuensi', ...
    'NumberTitle', 'off', 'MenuBar', 'none', 'Toolbar', 'none', ...
    'Units', 'pixels', 'Position', [60 40 1280 780], ...
    'Color', [0.94 0.95 0.97]);

% 3. Header Strip (Sleek Minimalist Branding)
pnlHead = uipanel(fig, 'Position', [0 0.935 1 0.065], ...
    'BackgroundColor', [0.08 0.11 0.16], 'BorderType', 'none');

% 4. Tab Container
tg = uitabgroup(fig, 'Position', [0.008 0.008 0.984 0.922]);

build_tab_lpf(uitab(tg, 'Title', '  B. Low-Pass Filter  '));
build_tab_hpf(uitab(tg, 'Title', '  C. High-Pass Filter  '));
build_tab_bright(uitab(tg, 'Title', '  D. Brightness  '));
build_tab_periodic(uitab(tg, 'Title', '  E. Periodic Noise  '));
build_tab_motion(uitab(tg, 'Title', '  F. Motion Blur  '));
end

%% ======================= TAB B: LOW-PASS FILTER =======================
function build_tab_lpf(tab)
state = struct('img', [], 'imgPath', '', 'ref', []);
[pnl, axIn, axSp, axH, axOut, txtStatus] = create_standard_layout(tab, 'B. Low-Pass Filtering');

% Controls
populate_presets(pnl, 'B_smoothing_blurring_frequency', @on_preset_selected);
uicontrol(pnl, 'Style', 'pushbutton', 'String', '+ Pilih Berkas Citra...', ...
    'Position', [14 555 202 32], 'Callback', @on_browse, ...
    'BackgroundColor', [0.92 0.94 0.98], 'ForegroundColor', [0.12 0.22 0.40], ...
    'FontWeight', 'bold', 'FontSize', 9);

create_label(pnl, 'Jenis Penapis (LPF):', 525);
popType = create_popup(pnl, {'gaussian', 'butterworth', 'ideal'}, 498);

create_label(pnl, 'Cutoff Frequency (D0):', 465);
edtD0 = create_edit(pnl, '45', 438);

create_label(pnl, 'Order (n) [Butterworth]:', 405);
edtN = create_edit(pnl, '2', 378);

btnRun = create_primary_button(pnl, 'Terapkan Low-Pass Filter', 315, @on_process);

    function on_preset_selected(path)
        load_image_file(path);
    end

    function on_browse(~, ~)
        p = pick_image_file();
        if ~isempty(p), load_image_file(p); end
    end

    function load_image_file(path)
        state.imgPath = path;
        state.img = read_image(path);
        state.ref = try_get_reference(path);
        render_viewport(axIn, state.img, 'Citra Masukan');
        clear_viewports({axSp, axH, axOut});
        update_status(txtStatus, state.img, state.imgPath, ~isempty(state.ref));
    end

    function on_process(~, ~)
        if isempty(state.img), show_alert('Buka atau pilih citra uji terlebih dahulu.'); return; end
        ftype = get_popup_string(popType);
        D0 = str2double(edtD0.String);
        n = str2double(edtN.String);

        set(btnRun, 'String', 'Memproses...', 'Enable', 'off'); drawnow;
        [out, info] = smooth_image(state.img, ftype, D0, n);
        set(btnRun, 'String', 'Terapkan Low-Pass Filter', 'Enable', 'on');

        render_viewport(axIn, state.img, 'Citra Masukan');
        render_viewport(axSp, log_spectrum(info.F), 'Spektrum Masukan |F(u,v)|');
        render_viewport(axH, info.H, sprintf('Filter H(u,v) [%s, D0=%g]', ftype, D0));

        outTitle = 'Citra Hasil Smoothing';
        if ~isempty(state.ref)
            psnrVal = psnr_value(state.ref, out);
            outTitle = sprintf('Hasil LPF (PSNR: %.2f dB)', psnrVal);
        end
        render_viewport(axOut, out, outTitle);
    end
end

%% ======================= TAB C: HIGH-PASS FILTER =======================
function build_tab_hpf(tab)
state = struct('img', [], 'imgPath', '');
[pnl, axIn, axSp, axH, axOut, txtStatus] = create_standard_layout(tab, 'C. High-Pass Filtering');

populate_presets(pnl, 'C_high_pass_filtering_frequency', @on_preset_selected);
uicontrol(pnl, 'Style', 'pushbutton', 'String', '+ Pilih Berkas Citra...', ...
    'Position', [14 555 202 32], 'Callback', @on_browse, ...
    'BackgroundColor', [0.92 0.94 0.98], 'ForegroundColor', [0.12 0.22 0.40], ...
    'FontWeight', 'bold', 'FontSize', 9);

create_label(pnl, 'Jenis Penapis (HPF):', 525);
popType = create_popup(pnl, {'gaussian', 'butterworth', 'ideal'}, 498);

create_label(pnl, 'Cutoff Frequency (D0):', 465);
edtD0 = create_edit(pnl, '40', 438);

create_label(pnl, 'Order (n) [Butterworth]:', 405);
edtN = create_edit(pnl, '2', 378);

btnRun = create_primary_button(pnl, 'Terapkan High-Pass Filter', 315, @on_process);

    function on_preset_selected(path)
        load_image_file(path);
    end

    function on_browse(~, ~)
        p = pick_image_file();
        if ~isempty(p), load_image_file(p); end
    end

    function load_image_file(path)
        state.imgPath = path;
        state.img = read_image(path);
        render_viewport(axIn, state.img, 'Citra Masukan');
        clear_viewports({axSp, axH, axOut});
        update_status(txtStatus, state.img, state.imgPath, false);
    end

    function on_process(~, ~)
        if isempty(state.img), show_alert('Buka atau pilih citra uji terlebih dahulu.'); return; end
        ftype = get_popup_string(popType);
        D0 = str2double(edtD0.String);
        n = str2double(edtN.String);

        set(btnRun, 'String', 'Memproses...', 'Enable', 'off'); drawnow;
        [out, info] = highpass_image(state.img, ftype, D0, n);
        set(btnRun, 'String', 'Terapkan High-Pass Filter', 'Enable', 'on');

        render_viewport(axIn, state.img, 'Citra Masukan');
        render_viewport(axSp, log_spectrum(info.F), 'Spektrum Masukan |F(u,v)|');
        render_viewport(axH, info.H, sprintf('Filter H(u,v) [%s, D0=%g]', ftype, D0));
        render_viewport(axOut, rescale01(out), 'Citra Hasil HPF (Rescaled [0,1])');
    end
end

%% ======================= TAB D: BRIGHTNESS =======================
function build_tab_bright(tab)
state = struct('img', [], 'imgPath', '', 'ref', []);
[pnl, axIn, axSp, axH, axOut, txtStatus] = create_standard_layout(tab, 'D. Homomorphic Brightening');

populate_presets(pnl, 'D_brightness_frequency', @on_preset_selected);
uicontrol(pnl, 'Style', 'pushbutton', 'String', '+ Pilih Berkas Citra...', ...
    'Position', [14 555 202 32], 'Callback', @on_browse, ...
    'BackgroundColor', [0.92 0.94 0.98], 'ForegroundColor', [0.12 0.22 0.40], ...
    'FontWeight', 'bold', 'FontSize', 9);

create_label(pnl, 'gammaL (Gain Rendah/Iluminasi):', 525);
edtGL = create_edit(pnl, '0.5', 498);

create_label(pnl, 'gammaH (Gain Tinggi/Reflektansi):', 465);
edtGH = create_edit(pnl, '1.6', 438);

create_label(pnl, 'Cutoff Frequency (D0):', 405);
edtD0 = create_edit(pnl, '35', 378);

create_label(pnl, 'Slope / Sharpness (c):', 345);
edtC = create_edit(pnl, '1.0', 318);

create_label(pnl, 'DC Offset Multiplier (Gain):', 285);
edtGain = create_edit(pnl, '1.25', 258);

btnRun = create_primary_button(pnl, 'Tingkatkan Kecerahan', 200, @on_process);

    function on_preset_selected(path)
        load_image_file(path);
    end

    function on_browse(~, ~)
        p = pick_image_file();
        if ~isempty(p), load_image_file(p); end
    end

    function load_image_file(path)
        state.imgPath = path;
        state.img = read_image(path);
        state.ref = try_get_reference(path);
        render_viewport(axIn, state.img, 'Citra Gelap (Input)');
        clear_viewports({axSp, axH, axOut});
        update_status(txtStatus, state.img, state.imgPath, ~isempty(state.ref));
    end

    function on_process(~, ~)
        if isempty(state.img), show_alert('Buka atau pilih citra uji terlebih dahulu.'); return; end
        gL = str2double(edtGL.String);
        gH = str2double(edtGH.String);
        D0 = str2double(edtD0.String);
        c = str2double(edtC.String);
        gain = str2double(edtGain.String);

        set(btnRun, 'String', 'Memproses...', 'Enable', 'off'); drawnow;
        [out, info] = brighten_homomorphic(state.img, gL, gH, D0, c, gain);
        set(btnRun, 'String', 'Tingkatkan Kecerahan', 'Enable', 'on');

        render_viewport(axIn, state.img, 'Citra Asli');
        render_viewport(axSp, log_spectrum(info.F), 'Spektrum Domain Log');
        render_viewport(axH, rescale01(info.H), 'Mask Homomorfik H(u,v)');

        outTitle = 'Citra Hasil Homomorfik';
        if ~isempty(state.ref)
            psnrVal = psnr_value(state.ref, out);
            outTitle = sprintf('Hasil Cerah (PSNR: %.2f dB)', psnrVal);
        end
        render_viewport(axOut, out, outTitle);
    end
end

%% ======================= TAB E: PERIODIC NOISE =======================
function build_tab_periodic(tab)
state = struct('img', [], 'imgPath', '', 'spec', [], 'M', 0, 'N', 0, 'ref', []);

pnl = uipanel(tab, 'Title', '  E. Restorasi Derau Periodik  ', ...
    'Units', 'normalized', 'Position', [0.012 0.02 0.205 0.95], ...
    'BackgroundColor', [1 1 1], 'ForegroundColor', [0.12 0.16 0.24], ...
    'FontWeight', 'bold', 'FontSize', 10, 'FontName', 'Segoe UI', ...
    'BorderType', 'line', 'HighlightColor', [0.86 0.89 0.93]);

% 5-Axes Clean Layout
axIn    = create_styled_axes(tab, [0.235 0.53 0.24 0.41]);
axSpIn  = create_styled_axes(tab, [0.490 0.53 0.24 0.41]);
axH     = create_styled_axes(tab, [0.745 0.53 0.24 0.41]);
axSpOut = create_styled_axes(tab, [0.360 0.07 0.29 0.41]);
axOut   = create_styled_axes(tab, [0.670 0.07 0.29 0.41]);

txtStatus = uicontrol(pnl, 'Style', 'text', 'String', 'Status: Siap', ...
    'Position', [12 12 205 36], ...
    'BackgroundColor', [0.96 0.97 0.99], 'ForegroundColor', [0.35 0.42 0.52], ...
    'FontSize', 8, 'FontName', 'Segoe UI', 'HorizontalAlignment', 'left');

populate_presets(pnl, 'E_periodic_noise_restoration', @on_preset_selected);
uicontrol(pnl, 'Style', 'pushbutton', 'String', '+ Pilih Berkas Citra...', ...
    'Position', [14 555 202 32], 'Callback', @on_browse, ...
    'BackgroundColor', [0.92 0.94 0.98], 'ForegroundColor', [0.12 0.22 0.40], ...
    'FontWeight', 'bold', 'FontSize', 9);

create_label(pnl, 'Metode Penapis:', 525);
popFilter = create_popup(pnl, {'notch', 'bandreject'}, 498);
set(popFilter, 'Callback', @on_filter_changed);

create_label(pnl, 'Bentuk Karakteristik:', 465);
popShape = create_popup(pnl, {'gaussian', 'butterworth', 'ideal'}, 438);

% Controls Notch
lblNotch = create_label(pnl, 'Pusat Notch (u,v; ...) baris:', 405);
edtCenters = create_edit(pnl, '38 0; 0 38', 378);

btnPick = uicontrol(pnl, 'Style', 'pushbutton', ...
    'String', '⊕ Klik Spektrum Interaktif', ...
    'Position', [14 340 202 30], 'Callback', @on_pick_points, ...
    'BackgroundColor', [0.94 0.97 0.95], 'ForegroundColor', [0.08 0.45 0.25], ...
    'FontWeight', 'bold', 'FontSize', 8.5);

lblD0 = create_label(pnl, 'Radius Notch (D0):', 308);
edtD0 = create_edit(pnl, '8', 282);

% Controls Bandreject
lblC0 = create_label(pnl, 'Frekuensi Radial (C0):', 405);
edtC0 = create_edit(pnl, '45', 378);
set(lblC0, 'Visible', 'off'); set(edtC0, 'Visible', 'off');

lblW = create_label(pnl, 'Lebar Pita (W):', 345);
edtW = create_edit(pnl, '10', 318);
set(lblW, 'Visible', 'off'); set(edtW, 'Visible', 'off');

% Order
lblN = create_label(pnl, 'Order (n) [Butterworth]:', 250);
edtN = create_edit(pnl, '2', 224);

btnRun = create_primary_button(pnl, 'Restorasi Derau Periodik', 165, @on_process);

    function on_filter_changed(~, ~)
        isNotch = (popFilter.Value == 1);
        if isNotch
            set([lblNotch, edtCenters, btnPick, lblD0, edtD0], 'Visible', 'on');
            set([lblC0, edtC0, lblW, edtW], 'Visible', 'off');
            set(lblN, 'Position', [14 250 202 18]);
            set(edtN, 'Position', [14 224 202 24]);
        else
            set([lblNotch, edtCenters, btnPick, lblD0, edtD0], 'Visible', 'off');
            set([lblC0, edtC0, lblW, edtW], 'Visible', 'on');
            set(lblN, 'Position', [14 285 202 18]);
            set(edtN, 'Position', [14 258 202 24]);
        end
    end

    function on_preset_selected(path)
        load_image_file(path);
    end

    function on_browse(~, ~)
        p = pick_image_file();
        if ~isempty(p), load_image_file(p); end
    end

    function load_image_file(path)
        state.imgPath = path;
        state.img = read_image(path);
        state.ref = try_get_reference(path);
        [state.M, state.N, ~] = size(state.img);

        F = complex(zeros(state.M, state.N, size(state.img, 3)));
        for k = 1:size(state.img, 3)
            F(:, :, k) = fftshift(fft2(state.img(:, :, k)));
        end
        state.spec = log_spectrum(F);

        render_viewport(axIn, state.img, 'Citra Terdegradasi');
        render_viewport(axSpIn, state.spec, 'Spektrum Sebelum Restorasi');
        clear_viewports({axH, axSpOut, axOut});
        update_status(txtStatus, state.img, state.imgPath, ~isempty(state.ref));
    end

    function on_pick_points(~, ~)
        if isempty(state.img), show_alert('Buka citra terlebih dahulu.'); return; end
        title(axSpIn, 'KLIK TITIK DERAU (Tekan ENTER setelah selesai)', ...
            'Color', [0.95 0.75 0.15], 'FontWeight', 'bold');
        axes(axSpIn); %#ok<LAXES>
        [x, y] = ginput();
        if isempty(x)
            title(axSpIn, 'Spektrum Sebelum Restorasi', 'Color', [0.88 0.92 0.98]);
            return;
        end
        u0 = floor(state.M / 2) + 1;
        v0 = floor(state.N / 2) + 1;
        u_off = round(y - u0);
        v_off = round(x - v0);

        strLines = cell(numel(u_off), 1);
        hold(axSpIn, 'on');
        for i = 1:numel(u_off)
            strLines{i} = sprintf('%d %d', u_off(i), v_off(i));
            plot(axSpIn, x(i), y(i), 'ro', 'MarkerSize', 8, 'LineWidth', 1.5);
            plot(axSpIn, 2*v0 - x(i), 2*u0 - y(i), 'mo', 'MarkerSize', 8, 'LineWidth', 1.5);
        end
        hold(axSpIn, 'off');
        edtCenters.String = strjoin(strLines, '; ');
        title(axSpIn, sprintf('%d Titik Terpilih (+ Simetri)', numel(u_off)), ...
            'Color', [0.35 0.90 0.55], 'FontWeight', 'bold');
    end

    function on_process(~, ~)
        if isempty(state.img), show_alert('Buka atau pilih citra uji terlebih dahulu.'); return; end
        cfg = struct();
        cfg.filter = get_popup_string(popFilter);
        cfg.type = get_popup_string(popShape);
        cfg.n = str2double(edtN.String);
        if strcmp(cfg.filter, 'notch')
            cfg.centers = str2num(edtCenters.String); %#ok<ST2NM>
            cfg.D0 = str2double(edtD0.String);
        else
            cfg.C0 = str2double(edtC0.String);
            cfg.W = str2double(edtW.String);
        end

        set(btnRun, 'String', 'Memproses...', 'Enable', 'off'); drawnow;
        [out, info] = restore_periodic_noise(state.img, cfg);
        set(btnRun, 'String', 'Restorasi Derau Periodik', 'Enable', 'on');

        render_viewport(axH, info.H, sprintf('Mask H(u,v) [%s %s]', cfg.filter, cfg.type));
        render_viewport(axSpOut, log_spectrum(info.G), 'Spektrum Sesudah Penapisan');

        outTitle = 'Citra Hasil Restorasi';
        if ~isempty(state.ref)
            psnrVal = psnr_value(state.ref, out);
            outTitle = sprintf('Hasil Restorasi (PSNR: %.2f dB)', psnrVal);
        end
        render_viewport(axOut, out, outTitle);
    end
end

%% ======================= TAB F: MOTION BLUR =======================
function build_tab_motion(tab)
state = struct('img', [], 'imgPath', '', 'ref', []);
[pnl, axDeg, axPsf, axInv, axWnr, txtStatus] = create_standard_layout(tab, 'F. Restorasi Motion Blur');

populate_presets(pnl, 'F_motion_blur_restoration', @on_preset_selected);
uicontrol(pnl, 'Style', 'pushbutton', 'String', '+ Pilih Berkas Citra...', ...
    'Position', [14 555 202 32], 'Callback', @on_browse, ...
    'BackgroundColor', [0.92 0.94 0.98], 'ForegroundColor', [0.12 0.22 0.40], ...
    'FontWeight', 'bold', 'FontSize', 9);

create_label(pnl, 'Panjang Blur Linear (L):', 525);
edtL = create_edit(pnl, '19', 498);

create_label(pnl, 'Sudut Gerak Theta (derajat):', 465);
edtTheta = create_edit(pnl, '20', 438);

create_label(pnl, 'Wiener Parameter (K / NSR):', 405);
edtK = create_edit(pnl, '0.01', 378);

create_label(pnl, 'Inverse Min Threshold:', 345);
edtThr = create_edit(pnl, '0.02', 318);

create_label(pnl, 'Inverse Radius Cutoff (D0):', 285);
edtRad = create_edit(pnl, '65', 258);

btnRun = create_primary_button(pnl, 'Jalankan Dekonvolusi', 200, @on_process);

    function on_preset_selected(path)
        load_image_file(path);
        auto_fill_motion_params(path);
    end

    function auto_fill_motion_params(path)
        [~, fname, ~] = fileparts(path);
        tokens = regexp(fname, '_L(\d+)_A(-?\d+)', 'tokens');
        if ~isempty(tokens)
            edtL.String = tokens{1}{1};
            edtTheta.String = tokens{1}{2};
        end
        if contains(fname, 'noise')
            edtK.String = '0.025';
            edtThr.String = '0.05';
            edtRad.String = '50';
        else
            edtK.String = '0.005';
            edtThr.String = '0.01';
            edtRad.String = '80';
        end
    end

    function on_browse(~, ~)
        p = pick_image_file();
        if ~isempty(p)
            load_image_file(p);
            auto_fill_motion_params(p);
        end
    end

    function load_image_file(path)
        state.imgPath = path;
        state.img = read_image(path);
        state.ref = try_get_reference(path);
        render_viewport(axDeg, state.img, 'Citra Motion Blur (Input)');
        clear_viewports({axPsf, axInv, axWnr});
        update_status(txtStatus, state.img, state.imgPath, ~isempty(state.ref));
    end

    function on_process(~, ~)
        if isempty(state.img), show_alert('Buka atau pilih citra uji terlebih dahulu.'); return; end
        L = str2double(edtL.String);
        theta = str2double(edtTheta.String);
        K = str2double(edtK.String);
        thr = str2double(edtThr.String);
        rad = str2double(edtRad.String);

        set(btnRun, 'String', 'Mendekonvolusi...', 'Enable', 'off'); drawnow;
        invOpts = struct('threshold', thr, 'radius', rad, 'convention', 'math');
        [outInv, infoInv] = restore_motion_blur(state.img, L, theta, 'inverse', invOpts);

        wnrOpts = struct('K', K, 'convention', 'math');
        [outWnr, ~] = restore_motion_blur(state.img, L, theta, 'wiener', wnrOpts);
        set(btnRun, 'String', 'Jalankan Dekonvolusi', 'Enable', 'on');

        render_viewport(axDeg, state.img, 'Citra Terdegradasi');
        render_viewport(axPsf, rescale01(infoInv.psf), sprintf('PSF Motion (L=%g, Sudut=%g deg)', L, theta));

        invTitle = sprintf('Inverse Filter (thr=%g, D0=%g)', thr, rad);
        wnrTitle = sprintf('Wiener Filter (K=%g)', K);
        if ~isempty(state.ref)
            pInv = psnr_value(state.ref, outInv);
            pWnr = psnr_value(state.ref, outWnr);
            invTitle = sprintf('Inverse (PSNR: %.2f dB)', pInv);
            wnrTitle = sprintf('Wiener (PSNR: %.2f dB)', pWnr);
        end
        render_viewport(axInv, outInv, invTitle);
        render_viewport(axWnr, outWnr, wnrTitle);
    end
end

%% ======================= UI BUILDERS & HELPERS =======================
function [pnl, ax1, ax2, ax3, ax4, txtStatus] = create_standard_layout(parent, titleStr)
pnl = uipanel(parent, 'Title', ['  ' titleStr '  '], ...
    'Units', 'normalized', 'Position', [0.012 0.02 0.205 0.95], ...
    'BackgroundColor', [1 1 1], 'ForegroundColor', [0.12 0.16 0.24], ...
    'FontWeight', 'bold', 'FontSize', 10, 'FontName', 'Segoe UI', ...
    'BorderType', 'line', 'HighlightColor', [0.86 0.89 0.93]);

txtStatus = uicontrol(pnl, 'Style', 'text', 'String', 'Status: Siap', ...
    'Position', [12 12 205 36], ...
    'BackgroundColor', [0.96 0.97 0.99], 'ForegroundColor', [0.35 0.42 0.52], ...
    'FontSize', 8, 'FontName', 'Segoe UI', 'HorizontalAlignment', 'left');

ax1 = create_styled_axes(parent, [0.235 0.53 0.365 0.41]);
ax2 = create_styled_axes(parent, [0.620 0.53 0.365 0.41]);
ax3 = create_styled_axes(parent, [0.235 0.07 0.365 0.41]);
ax4 = create_styled_axes(parent, [0.620 0.07 0.365 0.41]);
end

function ax = create_styled_axes(parent, pos)
ax = axes('Parent', parent, 'Units', 'normalized', 'Position', pos, ...
    'Color', [0.08 0.10 0.14], 'XColor', 'none', 'YColor', 'none', ...
    'Box', 'on', 'LineWidth', 1);
axis(ax, 'image', 'off');
end

function render_viewport(ax, img, titleStr)
cla(ax);
show_image(ax, img);
title(ax, titleStr, ...
    'Color', [0.88 0.92 0.98], 'FontName', 'Segoe UI', ...
    'FontSize', 9.5, 'FontWeight', 'bold', 'Interpreter', 'none');
end

function clear_viewports(axesList)
for i = 1:numel(axesList)
    cla(axesList{i});
    title(axesList{i}, '');
    set(axesList{i}, 'Color', [0.08 0.10 0.14]);
end
end

function populate_presets(pnl, folderName, callback)
create_label(pnl, 'Pilih Preset Citra Uji:', 620);
pathsInfo = project_paths();
targetDir = fullfile(pathsInfo.dataset, folderName, 'input');
imgList = list_images(targetDir);

names = {'-- Pilih dari dataset resmi --'};
paths = {''};
for i = 1:numel(imgList)
    [~, fn, ext] = fileparts(imgList{i});
    names{end+1} = [fn ext]; %#ok<AGROW>
    paths{end+1} = imgList{i}; %#ok<AGROW>
end

pop = uicontrol(pnl, 'Style', 'popupmenu', 'String', names, ...
    'Position', [14 595 202 24], ...
    'BackgroundColor', [1 1 1], 'ForegroundColor', [0.15 0.18 0.24], ...
    'FontName', 'Segoe UI', 'FontSize', 8.5);

set(pop, 'Callback', @on_select);
    function on_select(~, ~)
        val = pop.Value;
        if val > 1
            callback(paths{val});
        end
    end
end

function lbl = create_label(pnl, txt, y)
lbl = uicontrol(pnl, 'Style', 'text', 'String', txt, ...
    'Position', [14 y 202 18], ...
    'BackgroundColor', [1 1 1], 'ForegroundColor', [0.35 0.42 0.52], ...
    'FontSize', 8.5, 'FontName', 'Segoe UI', ...
    'HorizontalAlignment', 'left');
end

function edt = create_edit(pnl, defaultVal, y)
edt = uicontrol(pnl, 'Style', 'edit', 'String', defaultVal, ...
    'Position', [14 y 202 24], ...
    'BackgroundColor', [0.98 0.99 1.0], 'ForegroundColor', [0.08 0.12 0.18], ...
    'FontName', 'Segoe UI', 'FontSize', 9, ...
    'HorizontalAlignment', 'left');
end

function pop = create_popup(pnl, items, y)
pop = uicontrol(pnl, 'Style', 'popupmenu', 'String', items, ...
    'Position', [14 y 202 24], ...
    'BackgroundColor', [1 1 1], 'ForegroundColor', [0.12 0.16 0.22], ...
    'FontName', 'Segoe UI', 'FontSize', 8.5);
end

function btn = create_primary_button(pnl, str, y, callback)
btn = uicontrol(pnl, 'Style', 'pushbutton', 'String', str, ...
    'Position', [14 y 202 36], ...
    'BackgroundColor', [0.12 0.44 0.95], 'ForegroundColor', [1 1 1], ...
    'FontWeight', 'bold', 'FontSize', 9, 'FontName', 'Segoe UI', ...
    'Callback', callback);
end

function valStr = get_popup_string(pop)
items = pop.String;
valStr = items{pop.Value};
end

function p = pick_image_file()
[file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff', 'Berkas Citra (*.png, *.jpg, ...)'}, ...
    'Pilih Citra Uji');
if isequal(file, 0)
    p = '';
else
    p = fullfile(path, file);
end
end

function ref = try_get_reference(path)
ref = [];
refPath = find_reference(path);
if ~isempty(refPath) && exist(refPath, 'file') == 2
    ref = read_image(refPath);
end
end

function update_status(txtStatus, img, path, hasRef)
[~, fn, ext] = fileparts(path);
[M, N, C] = size(img);
modeStr = 'Grayscale';
if C == 3, modeStr = 'RGB (Berwarna)'; end
refStr = 'Tdk ada acuan';
if hasRef, refStr = '✓ Acuan Terdeteksi'; end
txtStatus.String = sprintf('File: %s%s\nDim: %dx%d (%s)\n%s', fn, ext, M, N, modeStr, refStr);
end

function show_alert(msg)
errordlg(msg, 'IF4073 PCD Studio');
end
