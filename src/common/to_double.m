function img = to_double(img)
%TO_DOUBLE Mengubah citra (uint8/uint16/logical/double) menjadi double [0,1].
if islogical(img)
    img = double(img);
elseif isinteger(img)
    img = double(img) / double(intmax(class(img)));
else
    img = double(img);
end
end
