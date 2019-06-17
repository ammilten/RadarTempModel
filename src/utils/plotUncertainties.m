function plotUncertainties(prior,posterior)
% prior and posterior are samples in cell arrays

Pr = samples2dataset(prior);
Po = samples2dataset(posterior);

fields = Pr.Properties.VarNames(:);
nfields = size(Pr,2);

[a,~] = numSubplots(nfields);
figure;
for f = 1:nfields
    prdat = double(Pr(:,f));
    podat = double(Po(:,f));
    [yr,xr] = ksdensity(prdat);
    [yo,xo] = ksdensity(podat);
    
    subplot(a(1),a(2),f)
    hold on 
    plot(xr, yr, '-k')
    plot(xo, yo, '-r')
    hold off 
    %legend('Prior','Posterior')
    title(fields{f})
    ylabel('PDF')
end
    