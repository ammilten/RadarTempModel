function [tempSamples, attnSamples, postParams] = constrainTemp_withpower(N_obs, B_obs, Ps, Hs, He, thx, prior, N, sigObsN, sigObsB, dz, option)
% Nobs:     observed one-way attenuation rate
% Bobs:     observed bed echo power
% Ps:       power at H=Hs for normalizing corrected bed echo power
% Hs:       Height at the start of attenuation observations, below firn
% He:       Height at end of attenuation observations
% prior:    struct with prior parameters and uncertainty
% N:        Number of posterior samples to generate
% sigObsN:  Standard deviation of measured attenuation
% sigObsB:  Standard deviation of measured bed echo power (Bobs-Ps)
% dz:       Vertical discretization 
% option:   'FixedTb' for fixed bed temperature, 'GeoHeatFlux' for that eqn
burnin = 0.2;

Delta_obs = B_obs - Ps;

theta = .2;

z = 0:dz:thx;
[~,ne] = min(abs(thx - He - z));
[~,ns] = min(abs(thx - Hs - z));

tempSamples = zeros(length(z),N);
attnSamples = zeros(length(z),N);
postParams = cell(N,1);

% Sampling Loop
accepted = 0;
rejected = 0;

sample_old = samplePrior(prior,1);
switch option
    case 'FixedTb'
        [temp1, attn1] = genProfiles_fixedTb(dz, thx, sample_old{1});
    otherwise
        [temp1, attn1] = genProfiles(dz, thx, sample_old{1});
end
N_m = mean(attn1(ne:ns));
Delta_m= bedPwr(attn1(1:ns), temp1, thx-Hs, sample_old{1}.Rfr, sample_old{1}.Rth);

pAttn1 = normpdf(N_m, N_obs, sigObsN);
pPwr1 = normpdf(Delta_m, Delta_obs, sigObsB);

prob_old = pAttn1*pPwr1;

ratio = [];
while accepted < N*(1+burnin)
    %Generate sample and data
    sample2 = samplePrior(prior,1);
    sample = newsample(sample_old{1},sample2{1}, theta);
    switch option
        case 'FixedTb'
            [temp, attn] = genProfiles_fixedTb(dz, thx, sample);
        otherwise
            [temp, attn] = genProfiles(dz, thx, sample);
    end
    
    %Compute theoretical attenuation rate from sampled data
    N_m = mean(attn(ne:ns));
    Delta_m = bedPwr(attn(1:ns), temp, thx-Hs, sample.Rfr, sample.Rth);
    
    %Accept/reject criteria
    u = rand();
    pAttn = normpdf(N_m, N_obs, sigObsN);
    pPwr = normpdf(Delta_m, Delta_obs, sigObsB);
    prob = pAttn * pPwr; % Power and Attenuation
    %prob = pAttn;%Just attenuation
    
    alpha = prob/prob_old;
    if u < alpha
        accepted = accepted + 1;
        prob_old = prob;
        sample_old = {sample};
        ratio = [ratio, accepted/(accepted+rejected)];
        
        %Accept after pre-defined burn-in
        if accepted > round(burnin * N)
            ii = accepted - round(burnin*N);
            tempSamples(:,ii) = temp;
            attnSamples(:,ii) = attn;
            postParams{ii} = sample;
        end
        
    else
        rejected = rejected + 1;
    end
    
end

% Get rid of burn-in samples
%tempSamples = tempSamples(:,end-N+1:end);
%attnSamples = attnSamples(:,end-N+1:end);

%accepted / (accepted+rejected)
