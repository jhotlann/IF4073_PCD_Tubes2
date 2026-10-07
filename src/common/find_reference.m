function refPath = find_reference(imgPath)
%FIND_REFERENCE Mencari citra acuan pada folder reference/ di samping input/.
[folder, name, ext] = fileparts(imgPath);
refDir = fullfile(fileparts(folder), 'reference');
base = regexprep(name, '(_motion_L\d+_A-?\d+.*|_gaussian_noise|_periodic_noise|_dark)$', '');
refPath = '';
if strcmp(base, name) && ~contains(name, '_motion_')
    return
end
cand = fullfile(refDir, [base ext]);
if exist(cand, 'file') == 2
    refPath = cand;
end
end
