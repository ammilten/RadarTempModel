%% Runs model for idealized Vostok traces. 
clear; close all
addpath(genpath('src'))

%% Sampling setup
N = 1000;
sigObsN = 2; %dB/km 2-way
sigObsB = 5; %dB
dz = 1;

n2=100; %for plotting

run('prioruncertainty_vostok.m')

%% Vostok
thx = 4600; %m
attn1way = 17/2;
Pb = -76;
Ps = -55;
Hs = 1100;
Hf = 3700;

disp('Starting Vostok')
[pv,Tv,Av,paramv] = findThawProb(attn1way, Pb, Ps, Hs, Hf, thx, prior, N, sigObsN, sigObsB, dz,'FixedTb');
disp('Finished Vostok')

samplesv = samplePrior(prior,N);
tempProfiles = zeros(length(Tv), N);
attnProfiles = zeros(length(Av), N);

for i=1:n2
    params = samplesv{i};
    [temp, attn] = genProfiles_fixedTb(dz, thx, params);
    tempProfiles(:,i) = temp;
    attnProfiles(:,i) = attn;
end

figure;
subplot(1,2,1)
hold on
for i=1:n2
    plot(tempProfiles(:,i), 0:dz:thx, '-b')
end
for i=1:n2
    plot(Tv(:,i), 0:dz:thx, '-k')
end

xrange = xlim();
xrange = xrange(1):xrange(2);
plot(xrange,  (thx-Hs)*ones(length(xrange),1),'--k')
plot(xrange, (thx-Hf)*ones(length(xrange),1),'--k')

hold off
xlabel('Temperature (C)')
ylabel('Height Above Bed (m)')
title('Vostok Temperature Profiles')
ylim([0,4200])

subplot(1,2,2)
hold on
for i=1:n2
    plot(attnProfiles(:,i), 0:dz:thx, '-r')
end
for i=1:n2
    plot(Av(:,i), 0:dz:thx, '-k')
end

xrange = xlim();
xrange = xrange(1):xrange(2);
plot(xrange,  (thx-Hs)*ones(length(xrange),1),'--k')
plot(xrange, (thx-Hf)*ones(length(xrange),1),'--k')

hold off
xlabel('Attenuation Rate (dB/km)')
ylabel('Height Above Bed (m)')
title('Vostok Attenuation Profiles')
ylim([0,4200])

%% Frozen
thx = 3000; %m
attn1way = 19/2;
Pb = -85;
Ps = -64;
Hs = 1000;
Hf = 2950;

disp('Starting Dome C')
[pf,Tf,Af,paramf] = findThawProb(attn1way, Pb, Ps, Hs, Hf, thx, prior, N, sigObsN, sigObsB, dz,'FixedTb');
disp('Finished Dome C')

samplesf = samplePrior(prior,N);
tempProfiles = zeros(length(Tf), N);
attnProfiles = zeros(length(Af), N);

for i=1:n2
    params = samplesf{i};
    [temp, attn] = genProfiles_fixedTb(dz, thx, params);
    tempProfiles(:,i) = temp;
    attnProfiles(:,i) = attn;
end

figure;
subplot(1,2,1)
hold on
for i=1:n2
    plot(tempProfiles(:,i), 0:dz:thx, '-b')
end
for i=1:n2
    plot(Tf(:,i), 0:dz:thx, '-k')
end

xrange = xlim();
xrange = xrange(1):xrange(2);
plot(xrange,  (thx-Hs)*ones(length(xrange),1),'--k')
plot(xrange, (thx-Hf)*ones(length(xrange),1),'--k')

hold off

xlabel('Temperature (C)')
ylabel('Height Above Bed (m)')
title('Dome C Temperature Profiles')
ylim([0,3000])

subplot(1,2,2)
hold on
for i=1:n2
    plot(attnProfiles(:,i), 0:dz:thx, '-r')
end
for i=1:n2
    plot(Af(:,i), 0:dz:thx, '-k')
end

xrange = xlim();
xrange = xrange(1):xrange(2);
plot(xrange,  (thx-Hs)*ones(length(xrange),1),'--k')
plot(xrange, (thx-Hf)*ones(length(xrange),1),'--k')
 
hold off
xlabel('Attenuation Rate (dB/km)')
ylabel('Height Above Bed (m)')
title('Dome C Attenuation Profiles')
ylim([0,3000])


%% Plot summary statistics
disp('-----------------------------------------------------------')
disp(['Probability of Vostok being thawed:     ',num2str(pv)])
disp(['Probability of Dome C being thawed: ',num2str(pf)])

plotUncertainties(samplesf,paramf)
plotUncertainties(samplesv,paramv)
