function Delta_m = bedPwr(attn, temp, H, Rfr, Rth)
% attn: attenuation profile
% temp: temperature profile
% H:    Distance between bed and where measurements begin
% Rfr:  Reflectivity of frozen bed
% Rth:  Reflectivity of thawed bed

if temp(1) >= 0
    R = Rth;
else
    R = Rfr;
end

A = trapz(attn) * H / (length(attn)-1) / 1000 * 2;

Delta_m = R - A;


