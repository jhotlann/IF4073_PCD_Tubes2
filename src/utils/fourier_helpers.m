function helpers = fourier_helpers()
    % FOURIER_HELPERS Returns a struct containing Fourier transform utility functions.
    helpers.forward_fft = @forward_fft;
    helpers.inverse_fft = @inverse_fft;
    helpers.get_magnitude_spectrum = @get_magnitude_spectrum;
    helpers.get_distance_matrix = @get_distance_matrix;
    helpers.apply_rgb = @apply_rgb;
end

function F_shifted = forward_fft(img)
    % 1. Convert image from spatial domain to frequency domain using fft2
    % and move zero-frequency component to spectrum center via fftshift.
    F_shifted = fftshift(fft2(double(img)));
end

function img_out = inverse_fft(F_shifted, target_class)
    % 2. Inverse frequency spectrum to spatial image using ifftshift and ifft2,
    % get real component and clip intensity.
    % target_class: optional ('uint8' default, or 'double')
    if nargin < 2
        target_class = 'uint8';
    end
    
    spatial = real(ifft2(ifftshift(F_shifted)));
    
    if strcmp(target_class, 'uint8')
        img_out = uint8(max(0, min(255, round(spatial))));
    else
        img_out = max(0, min(1, spatial));
    end
end

function magnitude_spectrum = get_magnitude_spectrum(F_shifted)
    % 3. Calculate magnitude spectrum normalized for GUI using log(1 + |F|)
    magnitude = log(1 + abs(F_shifted));
    min_val = min(magnitude(:));
    max_val = max(magnitude(:));
    
    if max_val > min_val
        magnitude_spectrum = (magnitude - min_val) / (max_val - min_val);
    else
        magnitude_spectrum = zeros(size(magnitude));
    end
end

function [D, u, v] = get_distance_matrix(M, N)
    % 4. Create frequency coordinates (u, v) using meshgrid and calculate
    % distance matrix D(u, v) = sqrt((u - M/2)^2 + (v - N/2)^2) from center.
    % Center is positioned at (M/2 + 1, N/2 + 1) in 1-based indexing.
    u_center = floor(M / 2) + 1;
    v_center = floor(N / 2) + 1;
    
    [v, u] = meshgrid(1:N, 1:M);
    D = sqrt((u - u_center).^2 + (v - v_center).^2);
end

function result = apply_rgb(img, process_fn)
    % 5. Wrapper for executing Fourier operations / filtering for each
    % channel RGB before merging back (also handles 2D grayscale).
    if ndims(img) == 2
        result = process_fn(img);
    else
        channels = cell(1, size(img, 3));
        for c = 1:size(img, 3)
            channels{c} = process_fn(img(:, :, c));
        end
        result = cat(3, channels{:});
    end
end