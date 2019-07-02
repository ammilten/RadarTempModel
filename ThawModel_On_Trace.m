%% Setup

r = 2;
tr = 1260;

nsamples = 1000;
sigObsN = 1;
sigObsB = 5;
dz = 1;
theta = 0.2;

showDistributions = true;
showUncertainties = true;
showAnimation = false;

%% Paths and loading data
base = 'preprocessing/';
load([base, 'FullProcessedData.mat'])

addpath(genpath('src'))

%% Summary
disp('----------------')
disp('Summary')
disp('----------------')
disp(['Attenuation Measurement Error Standard Deviation: ',num2str(sigObsN),' dB/km'])
disp(['Bed Echo Power Measurement Error Standard Deviation: ',num2str(sigObsB),' dB'])
disp([num2str(nsamples),' samples'])
disp(['theta = ',num2str(theta)])
disp(' ')
disp(['Ice Thickness: ',num2str(Thx{r}(tr)),' meters'])
disp(['Start Height: ',num2str(Hs{r}(tr)),' meters below surface'])
disp(['End Height: ',num2str(He{r}(tr)),' meters below surface'])
disp(['Start Power: ',num2str(Ps{r}(tr)),' meters'])
disp(['Bed Echo Power: ',num2str(Pb{r}(tr)),' dB'])
disp(['1-Way Attenuation: ',num2str(N{r}(tr)),' dB/km'])


%% Sampling posterior
% addpath('/home/ammilten/Documents/Stanford/Second Project/Attenuation Model')
% addpath('/home/ammilten/Documents/Stanford/Second Project/Attenuation Model/Archive')



run('prioruncertainty_vostok.m')

tic
disp('--------------------')
disp('Starting Trace')
[p,T,A,post,diagnostic] = findThawProb(...
    N{r}(tr), Pb{r}(tr), Ps{r}(tr), Hs{r}(tr), He{r}(tr), Thx{r}(tr),...
    prior, nsamples, sigObsN, sigObsB, dz, theta, 'FixedTb',1);
p
t = toc;
disp(['Finished Trace (',num2str(t),' seconds)'])

%% Sampling prior
n2 = 100;

samples = samplePrior(prior,nsamples);
tempProfiles = zeros(size(T,1), nsamples);
attnProfiles = zeros(size(A,1), nsamples);

for i=1:n2
    params = samples{i};
    [temp, attn] = genProfiles_fixedTb(dz, Thx{r}(tr), params);
    tempProfiles(:,i) = temp;
    attnProfiles(:,i) = attn;
end

%% Plotting
if showDistributions
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(1,4,1)

    %Main Trace
    plot(pow{r}(:,tr),depth{r}(:,tr))
    ylim([depth{r}(I0{r}(tr),tr)-100, depth{r}(Ib{r}(tr),tr)+100])
    axis ij
    hold on

    % Important Points
    plot(pow{r}(Is{r}(tr),tr),depth{r}(Is{r}(tr),tr),'xk','MarkerSize',20)
    %plot(pow{r}(I0{r}(tr),tr),depth{r}(I0{r}(tr),tr),'xr','MarkerSize',20)
    %plot(pow{r}(Ie{r}(tr),tr),depth{r}(Ie{r}(tr),tr),'xk','MarkerSize',20)
    plot(pow{r}(Ib{r}(tr),tr),depth{r}(Ib{r}(tr),tr),'xr','MarkerSize',20)

    % Start and End for layer reflectivity fitting
    x = xlim();
    plot(x(1):x(2),depth{r}(Is{r}(tr),r)*ones(length(x(1):x(2)),1),'--k')
    plot(x(1):x(2),depth{r}(Ie{r}(tr),r)*ones(length(x(1):x(2)),1),'--k')

    % Plot fitted layer
    %pw = pow{r}(Ie{r}(tr),tr):pow{r}(Is{r}(tr),tr);
    %dep = depth{r}(Is{r}(tr),tr) + (pw(end) - pw) / N{r}(tr) * 1000 / 2;
    %pw = pw(dep <= depth{r}(Ie{r}(tr),tr));
    %dep = dep(dep <= depth{r}(Ie{r}(tr),tr));
    dep = depth{r}(Is{r}(tr),tr):depth{r}(Ie{r}(tr),tr);
    pw = pow{r}(Is{r}(tr),tr) - N{r}(tr) / 500 * (dep - dep(1));
    plot(pw,dep,'-r','LineWidth',2)

    y = ylim();
    plot(pow{r}(Is{r}(tr),tr)*ones(length(y(1):y(2)),1),y(1):y(2),'--k')
    plot(pow{r}(Ib{r}(tr),tr)*ones(length(y(1):y(2)),1),y(1):y(2),'--k')

    grid on
    xlabel('Power (dB)')
    ylabel('Depth (m)')
    title(['Radargram ',num2str(r),' Trace ',num2str(tr)])

    subplot(1,4,2)
    hold on
    for i=1:n2
        plot(tempProfiles(:,i), 0:dz:Thx{r}(tr), '-b')
    end
    for i=1:n2
        plot(T(:,i), 0:dz:Thx{r}(tr), '-k')
    end
    xrange = xlim();
    xrange = xrange(1):xrange(2);
    plot(xrange,  (Thx{r}(tr)-Hs{r}(tr))*ones(length(xrange),1),'--k')
    plot(xrange, (Thx{r}(tr)-He{r}(tr))*ones(length(xrange),1),'--k')
    hold off
    xlabel('Temperature (C)')
    ylabel('Height Above Bed (m)')
    title('Temperature Profiles')
    ylim([0,Thx{r}(tr)])
    yl = get(gca,'ylim');
    xl = get(gca,'xlim');
    annotation('textbox',[.34,.05,.3,.1],...
        'String',['Pr(thawed) = ',num2str(p)],...
        'FitBoxToText','on',...
        'EdgeColor','none')

    subplot(1,4,3)
    hold on
    for i=1:n2
        plot(attnProfiles(:,i), 0:dz:Thx{r}(tr), '-r')
    end
    for i=1:n2
        plot(A(:,i), 0:dz:Thx{r}(tr), '-k')
    end
    xrange = xlim();
    xrange = xrange(1):xrange(2);
    plot(xrange,  (Thx{r}(tr)-Hs{r}(tr))*ones(length(xrange),1),'--k')
    plot(xrange, (Thx{r}(tr)-He{r}(tr))*ones(length(xrange),1),'--k')
    hold off
    xlabel('Attenuation Rate (dB/km)')
    ylabel('Height Above Bed (m)')
    title('Attenuation Profiles')
    ylim([0,Thx{r}(tr)])

    subplot(1,4,4)
    hold on
    z = 0:dz:Thx{r}(tr);
    for i=1:n2
        if tempProfiles(1,i) >= 0 
            R = samples{i}.Rth;
        else
            R = samples{i}.Rfr;
        end

        priorTr = synthTrace(attnProfiles(:,i),0,R,dz);    
        z2 = 0:dz:((length(priorTr)-1)*dz);
        [~,trIndStart] = min(abs(Hs{r}(tr) - z2));
        priorTr = priorTr - priorTr(trIndStart);
        plot(priorTr, z2,'-g')
    end
    for i=1:n2
        if T(1,i) >= 0
            R = post{i}.Rth;
        else
            R = post{i}.Rfr;
        end

        postTr = synthTrace(A(:,i),0,R,dz);
        z2 = 0:dz:((length(postTr)-1)*dz);
        [~,trIndStart] = min(abs(Hs{r}(tr) - z2));
        postTr = postTr - postTr(trIndStart);
        plot(postTr, z2,'-k')
    end
    plot(pow{r}(:,tr)-Ps{r}(tr),depth{r}(:,tr),'-b')

    title('Snythetic Radar Traces')
    ylabel('Depth (m)')
    xlabel('Power (dB)')
    ylim([0,Thx{r}(tr)+100])
    x = xlim();
    plot(x(1):x(2),depth{r}(Is{r}(tr),r)*ones(length(x(1):x(2)),1),'--k')
    plot(x(1):x(2),depth{r}(Ie{r}(tr),r)*ones(length(x(1):x(2)),1),'--k')
    axis ij
end
%% Plot Uncertaintes
if showUncertainties
    plotUncertainties(samples,post)
end

%% Animation of Sampling
if showAnimation
    n2 = 500;

    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(1,4,1)
    %Main Trace
    plot(pow{r}(:,tr),depth{r}(:,tr))
    ylim([depth{r}(I0{r}(tr),tr)-100, depth{r}(Ib{r}(tr),tr)+100])
    axis ij
    hold on
    % Important Points
    plot(pow{r}(Is{r}(tr),tr),depth{r}(Is{r}(tr),tr),'xk','MarkerSize',20)
    plot(pow{r}(Ib{r}(tr),tr),depth{r}(Ib{r}(tr),tr),'xr','MarkerSize',20)
    % Start and End for layer reflectivity fitting
    x = xlim();
    plot(x(1):x(2),depth{r}(Is{r}(tr),r)*ones(length(x(1):x(2)),1),'--k')
    plot(x(1):x(2),depth{r}(Ie{r}(tr),r)*ones(length(x(1):x(2)),1),'--k')
    % Plot fitted layer
    dep = depth{r}(Is{r}(tr),tr):depth{r}(Ie{r}(tr),tr);
    pw = pow{r}(Is{r}(tr),tr) - N{r}(tr) / 500 * (dep - dep(1));
    plot(pw,dep,'-r','LineWidth',2)
    y = ylim();
    plot(pow{r}(Is{r}(tr),tr)*ones(length(y(1):y(2)),1),y(1):y(2),'--k')
    plot(pow{r}(Ib{r}(tr),tr)*ones(length(y(1):y(2)),1),y(1):y(2),'--k')
    grid on
    xlabel('Power (dB)')
    ylabel('Depth (m)')
    title(['Radargram ',num2str(r),' Trace ',num2str(tr)])

    subplot(1,4,2)
    hold on
    plot(T(:,1), 0:dz:Thx{r}(tr), '-b')
    xrange = xlim();
    xrange = xrange(1):xrange(2);
    plot(xrange,  (Thx{r}(tr)-Hs{r}(tr))*ones(length(xrange),1),'--k')
    plot(xrange, (Thx{r}(tr)-He{r}(tr))*ones(length(xrange),1),'--k')
    hold off
    xlabel('Temperature (C)')
    ylabel('Height Above Bed (m)')
    title('Temperature Profiles')
    ylim([0,Thx{r}(tr)])
    yl = get(gca,'ylim');
    xl = get(gca,'xlim');
    annotation('textbox',[.34,.05,.3,.1],...
        'String',['Pr(thawed) = ',num2str(p)],...
        'FitBoxToText','on',...
        'EdgeColor','none')

    subplot(1,4,3)
    hold on
    plot(A(:,1), 0:dz:Thx{r}(tr), '-r')
    xrange = xlim();
    xrange = xrange(1):xrange(2);
    plot(xrange,  (Thx{r}(tr)-Hs{r}(tr))*ones(length(xrange),1),'--k')
    plot(xrange, (Thx{r}(tr)-He{r}(tr))*ones(length(xrange),1),'--k')
    hold off
    xlabel('Attenuation Rate (dB/km)')
    ylabel('Height Above Bed (m)')
    title('Attenuation Profiles')
    ylim([0,Thx{r}(tr)])

    subplot(1,4,4)
    hold on
    i=1;
    if T(1,i) >= 0
        R = post{i}.Rth;
    else
        R = post{i}.Rfr;
    end
    postTr = synthTrace(A(:,i),0,R,dz);
    z2 = 0:dz:((length(postTr)-1)*dz);
    [~,trIndStart] = min(abs(Hs{r}(tr) - z2));
    postTr = postTr - postTr(trIndStart);
    plot(postTr, z2,'-g')
    title('Snythetic Radar Traces')
    ylabel('Depth (m)')
    xlabel('Power (dB)')
    ylim([0,Thx{r}(tr)+100])
    plot(x(1):x(2),depth{r}(Is{r}(tr),r)*ones(length(x(1):x(2)),1),'--k')
    plot(x(1):x(2),depth{r}(Ie{r}(tr),r)*ones(length(x(1):x(2)),1),'--k')
    axis ij

    for i=2:n2
        pause(0.01)
        subplot(1,4,2)
        hold on
        plot(T(:,i-1), 0:dz:Thx{r}(tr), '-k')
        plot(T(:,i), 0:dz:Thx{r}(tr), '-b')

        subplot(1,4,3)
        hold on
        plot(A(:,i-1), 0:dz:Thx{r}(tr), '-k')
        plot(A(:,i), 0:dz:Thx{r}(tr), '-r')

        subplot(1,4,4)
        hold on
        plot(postTr,z2,'-k')
        if T(1,i) >= 0
            R = post{i}.Rth;
        else
            R = post{i}.Rfr;
        end
        postTr = synthTrace(A(:,i),0,R,dz);
        z2 = 0:dz:((length(postTr)-1)*dz);
        [~,trIndStart] = min(abs(Hs{r}(tr) - z2));
        postTr = postTr - postTr(trIndStart);
        plot(postTr, z2,'-g')
    end
end