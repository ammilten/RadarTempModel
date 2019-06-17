% Function calculates temperature profile given temperatures at both boundaries
function T = temperature_fixedTb(z, diffusivity, iceThickness, accumulationRate, surfaceTemp, bottomTemp)

Ts = surfaceTemp + 273.15; %C to K
Tb = bottomTemp + 273.15; %C to K

accumulationRate = accumulationRate./(3.154*10^7); %convert yrs to seconds;

l = sqrt(2 * diffusivity * iceThickness ./ accumulationRate);
T = Ts - (Tb - Ts)/erf(iceThickness/l) * (erf(z/l) - erf(iceThickness/l));
T = T - 273.15;

end 




