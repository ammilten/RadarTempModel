clear;
addpath(genpath('src'))

%% Sampling Setup

N = 1000;
sigObsN = 2; %dB/km 2-way
sigObsB = 5; %dB
dz = 1;

n2=100; %for plotting

run('prioruncertainty_vostok.m')

%% Trace properties

thx = 4807; %m
attn1way = 9.3982; %dB/km
Pb = -77; %dB
Ps = -60; %dB
Hs = 1000; %m
Hf = 2854; %m

%% Sampling
disp('Starting trace')
[p,T,A,param] = findThawProb(attn1way, Pb, Ps, Hs, Hf, thx, prior, N, sigObsN, sigObsB, dz,'FixedTb');
disp('Finished trace')

p
%% Plotting

% Sampling prior
samples = samplePrior(prior,N);
tempProfiles = zeros(length(T), N);
attnProfiles = zeros(length(A), N);

for i=1:n2
    params = samples{i};
    [temp, attn] = genProfiles_fixedTb(dz, thx, params);
    tempProfiles(:,i) = temp;
    attnProfiles(:,i) = attn;
end

figure;

% Plot temp curves
subplot(1,2,1)
hold on
for i=1:n2
    plot(tempProfiles(:,i), 0:dz:thx, '-b') %Prior
end
for i=1:n2
    plot(T(:,i), 0:dz:thx, '-k') %Posterior
end

xrange = xlim();
xrange = xrange(1):xrange(2);
plot(xrange,  (thx-Hs)*ones(length(xrange),1),'--k')
plot(xrange, (thx-Hf)*ones(length(xrange),1),'--k')

hold off
xlabel('Temperature (C)')
ylabel('Height Above Bed (m)')
title('Temperature Profiles')
ylim([0,4200])

% Plot attenuation curves
subplot(1,2,2)
hold on
for i=1:n2
    plot(attnProfiles(:,i), 0:dz:thx, '-r') %Prior
end
for i=1:n2
    plot(A(:,i), 0:dz:thx, '-k') %Posterior
end

xrange = xlim();
xrange = xrange(1):xrange(2);
plot(xrange,  (thx-Hs)*ones(length(xrange),1),'--k')
plot(xrange, (thx-Hf)*ones(length(xrange),1),'--k')

hold off
xlabel('Attenuation Rate (dB/km)')
ylabel('Height Above Bed (m)')
title('Attenuation Profiles')
ylim([0,4200])
