% Function calculates attenuation given temperature and ice chemistry
function N = attenuation(tempProfile, sig, E, C, Const, K, referenceTemp)

Tr = referenceTemp;
T = tempProfile + 273.15; %C to K


N = Const * (...
    sig(1) * exp(-E(1)/K * (1./T - 1/Tr)) + ...
    sig(2) * C(2) * exp(-E(2)/K * (1./T - 1/Tr)) + ...
    sig(3) * C(3) * exp(-E(3)/K * (1./T - 1/Tr)));

N= N .*10^6; % convert to dB/km

