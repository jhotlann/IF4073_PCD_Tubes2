function gui()
% GUI - Aplikasi Pemrosesan Citra Ranah Frekuensi (Tugas 2 IF4073 PCD)
% ponytail: satu file GUI modular dengan uitabgroup, axes native, dan reuse src/*.

% Setup path ke modul src
thisDir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(thisDir, 'src')));

fig = figure('Name', 'IF4073 PCD - Ranah Frekuensi', ...
    'NumberTitle', 'off', 'MenuBar', 'none', 'Toolbar', 'none', ...
    'Units', 'pixels', 'Position', [80 60 1200 740], ...
    'Color', [0.94 0.94 0.94]);

tg = uitabgroup(fig, 'Position', [0.01 0.01 0.98 0.98]);

build_tab_lpf(uitab(tg, 'Title', 'B. Low-Pass Filter'));
build_tab_hpf(uitab(tg, 'Title', 'C. High-Pass Filter'));
build_tab_bright(uitab(tg, 'Title', 'D. Brightness'));
build_tab_periodic(uitab(tg, 'Title', 'E. Periodic Noise'));
build_tab_motion(uitab(tg, 'Title', 'F. Motion Blur'));
end

%% ======================= TAB B: LOW-PASS FILTER =======================
function build_tab_lpf(tab)
state = struct('img', []);
[pnl, axInput, axSpec, axH, axOut] = create_four_axes_layout(tab);

uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Buka Citra...', ...
    'Position', [10 580 180 32], 'Callback', @on_load);

uicontrol(pnl, 'Style', 'text', 'String', 'Jenis Penapis:', ...
    'Position', [10 540 180 18], 'HorizontalAlignment', 'left');
popType = uicontrol(pnl, 'Style', 'popupmenu', 'String', {'gaussian', 'butterworth', 'ideal'}, ...
    'Position', [10 515 180 25]);

uicontrol(pnl, 'Style', 'text', 'String', 'Cutoff (D0):', ...
    'Position', [10 480 180 18], 'HorizontalAlignment', 'left');
edtD0 = uicontrol(pnl, 'Style', 'edit', 'String', '50', 'Position', [10 455 180 25]);

uicontrol(pnl, 'Style', 'text', 'String', 'Order (n) [Butterworth]:', ...
    'Position', [10 420 180 18], 'HorizontalAlignment', 'left');
edtN = uicontrol(pnl, 'Style', 'edit', 'String', '2', 'Position', [10 395 180 25]);

uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Terapkan LPF', ...
    'Position', [10 340 180 35], 'FontWeight', 'bold', 'Callback', @on_process);

    function on_load(~, ~)
        state.img = load_image_dialog();
        if isempty(state.img), return; end
        show_image(axInput, state.img, 'Citra Masukan');
        cla(axSpec); cla(axH); cla(axOut);
    end

    function on_process(~, ~)
        if isempty(state.img), errordlg('Buka citra terlebih dahulu.'); return; end
        types = popType.String;
        ftype = types{popType.Value};
        D0 = str2double(edtD0.String);
        n = str2double(edtN.String);
        [out, info] = smooth_image(state.img, ftype, D0, n);
        show_image(axInput, state.img, 'Citra Masukan');
        show_image(axSpec, log_spectrum(info.F), 'Spektrum Masukan |F(u,v)|');
        show_image(axH, info.H, sprintf('Mask H(u,v) [%s, D0=%g]', ftype, D0));
        show_image(axOut, out, 'Citra Hasil Smoothing');
    end
end

%% ======================= TAB C: HIGH-PASS FILTER =======================
function build_tab_hpf(tab)
state = struct('img', []);
[pnl, axInput, axSpec, axH, axOut] = create_four_axes_layout(tab);

uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Buka Citra...', ...
    'Position', [10 580 180 32], 'Callback', @on_load);

uicontrol(pnl, 'Style', 'text', 'String', 'Jenis Penapis:', ...
    'Position', [10 540 180 18], 'HorizontalAlignment', 'left');
popType = uicontrol(pnl, 'Style', 'popupmenu', 'String', {'gaussian', 'butterworth', 'ideal'}, ...
    'Position', [10 515 180 25]);

uicontrol(pnl, 'Style', 'text', 'String', 'Cutoff (D0):', ...
    'Position', [10 480 180 18], 'HorizontalAlignment', 'left');
edtD0 = uicontrol(pnl, 'Style', 'edit', 'String', '50', 'Position', [10 455 180 25]);

uicontrol(pnl, 'Style', 'text', 'String', 'Order (n) [Butterworth]:', ...
    'Position', [10 420 180 18], 'HorizontalAlignment', 'left');
edtN = uicontrol(pnl, 'Style', 'edit', 'String', '2', 'Position', [10 395 180 25]);

uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Terapkan HPF', ...
    'Position', [10 340 180 35], 'FontWeight', 'bold', 'Callback', @on_process);

    function on_load(~, ~)
        state.img = load_image_dialog();
        if isempty(state.img), return; end
        show_image(axInput, state.img, 'Citra Masukan');
        cla(axSpec); cla(axH); cla(axOut);
    end

    function on_process(~, ~)
        if isempty(state.img), errordlg('Buka citra terlebih dahulu.'); return; end
        types = popType.String;
        ftype = types{popType.Value};
        D0 = str2double(edtD0.String);
        n = str2double(edtN.String);
        [out, info] = highpass_image(state.img, ftype, D0, n);
        show_image(axInput, state.img, 'Citra Masukan');
        show_image(axSpec, log_spectrum(info.F), 'Spektrum Masukan |F(u,v)|');
        show_image(axH, info.H, sprintf('Mask H(u,v) [%s, D0=%g]', ftype, D0));
        show_image(axOut, rescale01(out), 'Citra Hasil HPF (Rescaled [0,1])');
    end
end

%% ======================= TAB D: BRIGHTNESS =======================
function build_tab_bright(tab)
state = struct('img', []);
[pnl, axInput, axSpec, axH, axOut] = create_four_axes_layout(tab);

uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Buka Citra...', ...
    'Position', [10 580 180 32], 'Callback', @on_load);

uicontrol(pnl, 'Style', 'text', 'String', 'gammaL (Frekuensi Rendah):', ...
    'Position', [10 540 180 18], 'HorizontalAlignment', 'left');
edtGL = uicontrol(pnl, 'Style', 'edit', 'String', '0.5', 'Position', [10 515 180 25]);

uicontrol(pnl, 'Style', 'text', 'String', 'gammaH (Frekuensi Tinggi):', ...
    'Position', [10 480 180 18], 'HorizontalAlignment', 'left');
edtGH = uicontrol(pnl, 'Style', 'edit', 'String', '1.5', 'Position', [10 455 180 25]);

uicontrol(pnl, 'Style', 'text', 'String', 'Cutoff (D0):', ...
    'Position', [10 420 180 18], 'HorizontalAlignment', 'left');
edtD0 = uicontrol(pnl, 'Style', 'edit', 'String', '30', 'Position', [10 395 180 25]);

uicontrol(pnl, 'Style', 'text', 'String', 'Sharpness Slope (c):', ...
    'Position', [10 360 180 18], 'HorizontalAlignment', 'left');
edtC = uicontrol(pnl, 'Style', 'edit', 'String', '1.0', 'Position', [10 335 180 25]);

uicontrol(pnl, 'Style', 'text', 'String', 'DC Gain Pengali:', ...
    'Position', [10 300 180 18], 'HorizontalAlignment', 'left');
edtGain = uicontrol(pnl, 'Style', 'edit', 'String', '1.2', 'Position', [10 275 180 25]);

uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Tingkatkan Kecerahan', ...
    'Position', [10 220 180 35], 'FontWeight', 'bold', 'Callback', @on_process);

    function on_load(~, ~)
        state.img = load_image_dialog();
        if isempty(state.img), return; end
        show_image(axInput, state.img, 'Citra Gelap (Input)');
        cla(axSpec); cla(axH); cla(axOut);
    end

    function on_process(~, ~)
        if isempty(state.img), errordlg('Buka citra terlebih dahulu.'); return; end
        gL = str2double(edtGL.String);
        gH = str2double(edtGH.String);
        D0 = str2double(edtD0.String);
        c = str2double(edtC.String);
        gain = str2double(edtGain.String);
        [out, info] = brighten_homomorphic(state.img, gL, gH, D0, c, gain);
        show_image(axInput, state.img, 'Citra Asli');
        show_image(axSpec, log_spectrum(info.F), 'Spektrum Domain Log');
        show_image(axH, rescale01(info.H), 'Mask Homomorfik H(u,v)');
        show_image(axOut, out, 'Citra Hasil Homomorfik');
    end
end

%% ======================= TAB E: PERIODIC NOISE =======================
function build_tab_periodic(tab)
state = struct('img', [], 'spec', [], 'M', 0, 'N', 0);
pnl = uipanel(tab, 'Title', 'Parameter Derau Periodik', ...
    'Position', [0.01 0.02 0.22 0.96], 'BackgroundColor', [0.94 0.94 0.94]);

% 5-axes layout untuk derau periodik
axIn = axes('Parent', tab, 'Position', [0.26 0.53 0.22 0.40]);
axSpIn = axes('Parent', tab, 'Position', [0.51 0.53 0.22 0.40]);
axH = axes('Parent', tab, 'Position', [0.76 0.53 0.22 0.40]);
axSpOut = axes('Parent', tab, 'Position', [0.38 0.06 0.25 0.40]);
axOut = axes('Parent', tab, 'Position', [0.66 0.06 0.25 0.40]);

uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Buka Citra...', ...
    'Position', [10 610 200 30], 'Callback', @on_load);

uicontrol(pnl, 'Style', 'text', 'String', 'Tipe Penapis:', ...
    'Position', [10 575 200 18], 'HorizontalAlignment', 'left');
popFilter = uicontrol(pnl, 'Style', 'popupmenu', 'String', {'notch', 'bandreject'}, ...
    'Position', [10 550 200 25], 'Callback', @on_toggle_filter);

uicontrol(pnl, 'Style', 'text', 'String', 'Bentuk Transfer:', ...
    'Position', [10 520 200 18], 'HorizontalAlignment', 'left');
popShape = uicontrol(pnl, 'Style', 'popupmenu', 'String', {'gaussian', 'butterworth', 'ideal'}, ...
    'Position', [10 495 200 25]);

% Controls Notch
lblNotch = uicontrol(pnl, 'Style', 'text', 'String', 'Pusat Notch (u,v; ...) per baris:', ...
    'Position', [10 465 200 18], 'HorizontalAlignment', 'left');
edtCenters = uicontrol(pnl, 'Style', 'edit', 'String', '40 0; 0 40', ...
    'Position', [10 440 200 25]);
btnPick = uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Klik Titik dari Spektrum', ...
    'Position', [10 405 200 28], 'Callback', @on_pick_points);
lblD0 = uicontrol(pnl, 'Style', 'text', 'String', 'Radius Notch (D0):', ...
    'Position', [10 375 200 18], 'HorizontalAlignment', 'left');
edtD0 = uicontrol(pnl, 'Style', 'edit', 'String', '8', 'Position', [10 350 200 25]);

% Controls Bandreject
lblC0 = uicontrol(pnl, 'Style', 'text', 'String', 'Pusat Frekuensi Band (C0):', ...
    'Position', [10 465 200 18], 'HorizontalAlignment', 'left', 'Visible', 'off');
edtC0 = uicontrol(pnl, 'Style', 'edit', 'String', '50', ...
    'Position', [10 440 200 25], 'Visible', 'off');
lblW = uicontrol(pnl, 'Style', 'text', 'String', 'Lebar Pita (W):', ...
    'Position', [10 375 200 18], 'HorizontalAlignment', 'left', 'Visible', 'off');
edtW = uicontrol(pnl, 'Style', 'edit', 'String', '10', ...
    'Position', [10 350 200 25], 'Visible', 'off');

% Order n
uicontrol(pnl, 'Style', 'text', 'String', 'Order (n) [Butterworth]:', ...
    'Position', [10 320 200 18], 'HorizontalAlignment', 'left');
edtN = uicontrol(pnl, 'Style', 'edit', 'String', '2', 'Position', [10 295 200 25]);

uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Restorasi Derau', ...
    'Position', [10 230 200 35], 'FontWeight', 'bold', 'Callback', @on_process);

    function on_toggle_filter(~, ~)
        isNotch = (popFilter.Value == 1);
        visN = 'off'; visB = 'on';
        if isNotch, visN = 'on'; visB = 'off'; end
        lblNotch.Visible = visN; edtCenters.Visible = visN; btnPick.Visible = visN;
        lblD0.Visible = visN; edtD0.Visible = visN;
        lblC0.Visible = visB; edtC0.Visible = visB;
        lblW.Visible = visB; edtW.Visible = visB;
    end

    function on_load(~, ~)
        state.img = load_image_dialog();
        if isempty(state.img), return; end
        [state.M, state.N, ~] = size(state.img);
        F = complex(zeros(state.M, state.N, size(state.img, 3)));
        for k = 1:size(state.img, 3)
            F(:, :, k) = fftshift(fft2(state.img(:, :, k)));
        end
        state.spec = log_spectrum(F);
        show_image(axIn, state.img, 'Citra Terdegradasi');
        show_image(axSpIn, state.spec, 'Spektrum Sebelum Restorasi');
        cla(axH); cla(axSpOut); cla(axOut);
    end

    function on_pick_points(~, ~)
        if isempty(state.img), errordlg('Buka citra terlebih dahulu.'); return; end
        msgbox('Klik titik noise pada axes spektrum. Tekan Enter setelah selesai.', 'Pilih Titik');
        axes(axSpIn); %#ok<LAXES>
        [x, y] = ginput();
        if isempty(x), return; end
        % Konversi koordinat visual ke offset frekuensi (u: baris, v: kolom)
        u0 = floor(state.M / 2) + 1;
        v0 = floor(state.N / 2) + 1;
        u_off = round(y - u0);
        v_off = round(x - v0);
        strLines = cell(numel(u_off), 1);
        for i = 1:numel(u_off)
            strLines{i} = sprintf('%d %d', u_off(i), v_off(i));
        end
        edtCenters.String = strjoin(strLines, '; ');
    end

    function on_process(~, ~)
        if isempty(state.img), errordlg('Buka citra terlebih dahulu.'); return; end
        cfg = struct();
        filters = popFilter.String;
        shapes = popShape.String;
        cfg.filter = filters{popFilter.Value};
        cfg.type = shapes{popShape.Value};
        cfg.n = str2double(edtN.String);
        if strcmp(cfg.filter, 'notch')
            cfg.centers = str2num(edtCenters.String); %#ok<ST2NM>
            cfg.D0 = str2double(edtD0.String);
        else
            cfg.C0 = str2double(edtC0.String);
            cfg.W = str2double(edtW.String);
        end
        [out, info] = restore_periodic_noise(state.img, cfg);
        show_image(axH, info.H, sprintf('Mask H(u,v) [%s %s]', cfg.filter, cfg.type));
        show_image(axSpOut, log_spectrum(info.G), 'Spektrum Sesudah Penapisan');
        show_image(axOut, out, 'Citra Hasil Restorasi');
    end
end

%% ======================= TAB F: MOTION BLUR =======================
function build_tab_motion(tab)
state = struct('img', []);
pnl = uipanel(tab, 'Title', 'Parameter Motion Blur', ...
    'Position', [0.01 0.02 0.22 0.96], 'BackgroundColor', [0.94 0.94 0.94]);

[axDeg, axPsf, axInv, axWnr] = create_motion_axes(tab);

uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Buka Citra...', ...
    'Position', [10 610 200 30], 'Callback', @on_load);

uicontrol(pnl, 'Style', 'text', 'String', 'Panjang Blur (L):', ...
    'Position', [10 575 200 18], 'HorizontalAlignment', 'left');
edtL = uicontrol(pnl, 'Style', 'edit', 'String', '19', 'Position', [10 550 200 25]);

uicontrol(pnl, 'Style', 'text', 'String', 'Sudut Theta (derajat):', ...
    'Position', [10 520 200 18], 'HorizontalAlignment', 'left');
edtTheta = uicontrol(pnl, 'Style', 'edit', 'String', '20', 'Position', [10 495 200 25]);

uicontrol(pnl, 'Style', 'text', 'String', 'Wiener Parameter (K / NSR):', ...
    'Position', [10 460 200 18], 'HorizontalAlignment', 'left');
edtK = uicontrol(pnl, 'Style', 'edit', 'String', '0.01', 'Position', [10 435 200 25]);

uicontrol(pnl, 'Style', 'text', 'String', 'Inverse Threshold:', ...
    'Position', [10 400 200 18], 'HorizontalAlignment', 'left');
edtThr = uicontrol(pnl, 'Style', 'edit', 'String', '0.02', 'Position', [10 375 200 25]);

uicontrol(pnl, 'Style', 'text', 'String', 'Inverse Cutoff Radius (D0):', ...
    'Position', [10 340 200 18], 'HorizontalAlignment', 'left');
edtRad = uicontrol(pnl, 'Style', 'edit', 'String', '70', 'Position', [10 315 200 25]);

uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Restorasi (Inverse & Wiener)', ...
    'Position', [10 250 200 38], 'FontWeight', 'bold', 'Callback', @on_process);

    function on_load(~, ~)
        state.img = load_image_dialog();
        if isempty(state.img), return; end
        show_image(axDeg, state.img, 'Citra Motion Blur (Input)');
        cla(axPsf); cla(axInv); cla(axWnr);
    end

    function on_process(~, ~)
        if isempty(state.img), errordlg('Buka citra terlebih dahulu.'); return; end
        L = str2double(edtL.String);
        theta = str2double(edtTheta.String);
        K = str2double(edtK.String);
        thr = str2double(edtThr.String);
        rad = str2double(edtRad.String);

        % Inverse
        invOpts = struct('threshold', thr, 'radius', rad, 'convention', 'math');
        [outInv, infoInv] = restore_motion_blur(state.img, L, theta, 'inverse', invOpts);

        % Wiener
        wnrOpts = struct('K', K, 'convention', 'math');
        [outWnr, ~] = restore_motion_blur(state.img, L, theta, 'wiener', wnrOpts);

        show_image(axDeg, state.img, 'Citra Terdegradasi');
        show_image(axPsf, rescale01(infoInv.psf), sprintf('PSF (L=%g, theta=%g deg)', L, theta));
        show_image(axInv, outInv, sprintf('Hasil Inverse (thr=%g, D0=%g)', thr, rad));
        show_image(axWnr, outWnr, sprintf('Hasil Wiener (K=%g)', K));
    end
end

%% ======================= LAYOUT HELPERS =======================
function [pnl, ax1, ax2, ax3, ax4] = create_four_axes_layout(parent)
pnl = uipanel(parent, 'Title', 'Kontrol & Parameter', ...
    'Position', [0.01 0.02 0.22 0.96], 'BackgroundColor', [0.94 0.94 0.94]);
ax1 = axes('Parent', parent, 'Position', [0.26 0.53 0.34 0.40]);
ax2 = axes('Parent', parent, 'Position', [0.63 0.53 0.34 0.40]);
ax3 = axes('Parent', parent, 'Position', [0.26 0.06 0.34 0.40]);
ax4 = axes('Parent', parent, 'Position', [0.63 0.06 0.34 0.40]);
end

function [ax1, ax2, ax3, ax4] = create_motion_axes(parent)
ax1 = axes('Parent', parent, 'Position', [0.26 0.53 0.34 0.40]);
ax2 = axes('Parent', parent, 'Position', [0.63 0.53 0.34 0.40]);
ax3 = axes('Parent', parent, 'Position', [0.26 0.06 0.34 0.40]);
ax4 = axes('Parent', parent, 'Position', [0.63 0.06 0.34 0.40]);
end

function img = load_image_dialog()
[file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif;*.tiff', 'Berkas Citra (*.png, *.jpg, ...)'}, ...
    'Pilih Citra Uji');
if isequal(file, 0)
    img = [];
    return;
end
img = read_image(fullfile(path, file));
end
