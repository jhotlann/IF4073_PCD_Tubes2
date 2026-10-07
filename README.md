# Aplikasi Pemrosesan Citra Ranah Frekuensi (Tugas 2 IF4073 PCD)

Aplikasi MATLAB berbasis GUI untuk pemrosesan citra digital dalam ranah frekuensi sesuai spesifikasi Tugas 2 IF4073.

## Modul & Fitur

1. **Bagian B — Image Smoothing / Blurring:**
   - Penapis Low-Pass: Ideal (ILPF), Gaussian (GLPF), Butterworth (BLPF).
   - Parameter: Cutoff frequency ($D_0$) dan order ($n$).
2. **Bagian C — High-Pass Filtering:**
   - Penapis High-Pass: Ideal (IHPF), Gaussian (GHPF), Butterworth (BHPF).
   - Parameter: Cutoff frequency ($D_0$) dan order ($n$), normalisasi visualisasi [0, 1].
3. **Bagian D — Peningkatan Kecerahan (Homomorphic Filtering):**
   - Penapisan ranah frekuensi berbasis model iluminasi-reflektansi.
   - Parameter: $\gamma_L, \gamma_H, D_0, c,$ dan pengali DC gain.
4. **Bagian E — Restorasi Derau Periodik:**
   - Penapis: Bandreject (Ideal, Butterworth, Gaussian) dan Notch Reject (Ideal, Butterworth, Gaussian).
   - Analisis spektrum sebelum & sesudah restorasi, serta penentuan koordinat notch interaktif dengan klik spektrum (`ginput`).
5. **Bagian F — Restorasi Motion Blur:**
   - Pemodelan degradasi PSF & OTF linear ($L, \theta$).
   - Dekonvolusi Inverse Filtering (dengan thresholding & radius cutoff stabilisasi).
   - Penapis Wiener Filtering parametrik (rasio derau-ke-sinyal $K$ / NSR).

## Dependensi

- **MATLAB** R2018a atau lebih baru.
- Tidak bergantung secara ketat pada *Image Processing Toolbox* (seluruh transformasi Fourier dasar menggunakan `fft2`, `ifft2`, `fftshift`, `ifftshift`, serta visualisasi menggunakan native `image`/`imagesc`).

## Cara Menjalankan Program

1. Buka MATLAB dan arahkan direktori kerja (*Current Folder*) ke *root* repositori ini.
2. Ketik perintah berikut pada MATLAB Command Window:
   ```matlab
   main
   ```
   atau
   ```matlab
   gui
   ```
3. Pilih *tab* sesuai bagian pemrosesan yang diinginkan (B, C, D, E, atau F), klik tombol **Buka Citra...**, sesuaikan parameter, lalu klik tombol pemrosesan.