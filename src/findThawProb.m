function [Ps, tempPosterior, attnPosterior, postParams, ratio] = findThawProb(attn, Bobs, Ps, Hs, He, thx, prior, N, sigObsN, sigObsP, dz, theta, option,varargin)
% Variables:
%     attn:     measured attenuation rate of upper portion
%     He:       measured height
%     Pg:       measured bed echo power after geometric spreading
%     Rth:      reflectivity of thawed ice
%     prior:    prior parameters controlling temp and attn profiles
%     params:   parameters for MCMC?

% Step 1. Use observed data to constrain possible temperature profiles
% Step 2. Use posterior temperature profiles to compute uncertainty lower
%         attenuation term
% Step 3. Grab base temperature from posterior temperature profiles. Use
%         these to compute frozen/thaw probability

% attn = 10;
% Pg = 30;
% He = 200;
% Rth = 20;
% run('prioruncertainty.m')

    
% If no extra arguments, use {Rfr, Rth}, if not use {Rfr=Rth}
if nargin==13
    %disp('Using Frozen/Thawed DeltaR')
    [tempPosterior, attnPosterior, postParams, ratio] = constrainTemp_withpower(attn, Bobs, Ps, Hs, He, thx, prior, N, sigObsN, sigObsP, dz, theta, option);
else
    %disp('Using Single DeltaR')
    [tempPosterior, attnPosterior, postParams, ratio] = mcmc2(attn, Bobs, Ps, Hs, He, thx, prior, N, sigObsN, sigObsP, dz, theta, option);
end
%[tempPrior, attnPrior] = priorProfiles(prior, N, dz, option);
%[tempPosterior, attnPosterior] = constrainTemp_mcmc(attn, P, Hs, He, prior, N, sigObsN, sigObsP, dz, option);

Ps = sum(tempPosterior(1,:) >= 0) / N;












