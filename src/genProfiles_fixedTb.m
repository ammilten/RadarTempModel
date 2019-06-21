function [tempProfile, attnProfile, trace] = genProfiles_fixedTb(dz,thx,params)
% params:
%     thermalCond
%     iceThickness
%     accumulationRate
%     geoHeatFlux
%     surfaceTemp
%
%     pureIceCond
%     Const
%     activationEnergy
%     referenceTemp

diffusivity = params.diffusivity;
iceThickness = thx;
accumulationRate = params.accumulationRate;
surfaceTemp = params.surfaceTemp;
bottomTemp = min(0,params.bottomTemp);

Const = params.Const;
referenceTemp = params.referenceTemp;


sig = [9.2*10^-6,3.2,0.43]; % ice conductivity (s/m, s/m/M for the second two)
E = [0.51,0.20,0.19]; %activation energy, eV
C = [0, 0.5, 2]*10^-6; % acidity, Molar (s/m/M), C(1) is not used, it should be unitary
K = 8.6173303*10^-5; %Boltzman constant in eV/K

%accumulationRate = accumulationRate / 1e3 / 365.25 / 24 / 3600;
z = 0:dz:iceThickness;

tempProfile = temperature_fixedTb(z, diffusivity, iceThickness, accumulationRate, surfaceTemp, bottomTemp);
%tempProfile = temperature(z, diffusivity, thermalCond, iceThickness, accumulationRate, geoHeatFlux, surfaceTemp, false);
attnProfile = attenuation(tempProfile, sig, E, C, Const, K, referenceTemp);

