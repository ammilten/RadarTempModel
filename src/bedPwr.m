function Delta_m = bedPwr(attn, H, R)
% attn: attenuation profile
% temp: temperature profile
% H:    Distance between bed and where measurements begin
% Rfr:  Reflectivity of frozen bed
% Rth:  Reflectivity of thawed bed

A = trapz(attn) * H / (length(attn)-1) / 1000 * 2;

Delta_m = R - A;


