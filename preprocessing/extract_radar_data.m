% Plots radargrams from DomeC - Vostok flight line with bed and surface
% picks and corrects for geometric spreading -- code by Eliza Dawson

% Read in data from OIB CReSIS NetCDF's
filename = [path_to_data,'DomeC-Vostok-2013/IRMCR1B_20131127_01_0'];

beg = 23;
for num = 23:46
    name = [filename, int2str(num),'.nc'];
    file = fullfile(name);

    LAT{:,num + 1 - beg} = ncread(file,'lat');
    LON{:,num + 1 - beg} = ncread(file,'lon');
    sfc{:,num + 1 - beg} = ncread(file,'Surface');
    fasttime{:,num + 1 - beg} = ncread(file,'fasttime');
    ampdB{:,num + 1 - beg} = ncread(file,'amplitude'); % already in dB I think!
    AvgAttn(num-beg+1,:) = 2.*mean(ampdB{1, num-beg+1},2);

end


%% Read in distance to surface and thickness of ice from csv file
flight_29 = fullfile([path_to_data,'CSVData/Data_20131127_01_029_224754.csv']);
flight_39 = fullfile([path_to_data,'CSVData/Data_20131127_01_039_234208.csv']);
flight_40 = fullfile([path_to_data,'CSVData/Data_20131127_01_040_234743.csv']);
flight_43 = fullfile([path_to_data,'CSVData/Data_20131127_01_043_000405.csv']);
flight_44 = fullfile([path_to_data,'CSVData/Data_20131127_01_044_000916.csv']);

data29 = csvread(flight_29,1,1); %missing fist column when reading it in!!
data39 = csvread(flight_39,1,1); %missing fist column when reading it in!!
data40 = csvread(flight_40,1,1); %missing fist column when reading it in!!
data43 = csvread(flight_43,1,1); %missing fist column when reading it in!!
data44 = csvread(flight_44,1,1); %missing fist column when reading it in!!
h29 = data29(:,6); % Distance to surface
h39 = data39(:,6); % Distance to surface
h40 = data40(:,6); % Distance to surface
h43 = data43(:,6); % Distance to surface
h44 = data44(:,6); % Distance to surface

H29 = data29(:,3); % Thickness
H39 = data39(:,3); % Thickness
H40 = data40(:,3); % Thickness
H43 = data43(:,3); % Thickness
H44 = data44(:,3); % Thickness

%% plots of the thickness and compare sfc during processing the csv file sfc
D40 = 3*10^8 .* sfc{18}./2;
% hold on; plot(h40) %sfc postprocess
% hold on; plot(D40) %sfc preprocess
% hold on; plot(H40) %bed
% set(gca, 'YDir','reverse')
% ylabel('thickness (m)')


%% Correct for geometric spreading loss
eps = 3.2; %permittivity of ice from MacGregor

GdB29 = 2*10*log10(h29 + H29/sqrt(eps));
GdB39 = 2*10*log10(h39 + H39/sqrt(eps));
GdB40 = 2*10*log10(h40 + H40/sqrt(eps));
GdB43 = 2*10*log10(h43 + H43/sqrt(eps));
GdB44 = 2*10*log10(h44 + H44/sqrt(eps));

pow{1} = 1*ampdB{7}+GdB29.';
pow{2} = 1*ampdB{17}+GdB39.';
pow{3} = 1*ampdB{18}+GdB40.';
pow{4} = 1*ampdB{21}+GdB43.';
pow{5} = 1*ampdB{22}+GdB44.';

%% plot the geometric spreading loss (sanity check)
% expect:
% 1. thicker ice == more spreading loss
% 2. more topography == more variation in spreading loss
% hold on; plot(GdB29,'k')
% hold on; plot(GdB39,'k')
% hold on; plot(GdB40,'r')
% hold on; plot(GdB43,'b')
% hold on; plot(GdB44,'b')
%% convert fasttime to distance
time = fasttime{1} * 10^-6; % convert microseconds to seconds

% calculate the depth:
depth = 3*10^8 .* time(1) ./ 2;
for m = 2:length(time)
    if depth(m-1) < mean(h40)
        depth(m) = 3*10^8 .* time(m) ./ 2; %two way travel time through air
    else
        depth(m) = 3*10^8/sqrt(eps) .* time(m) ./ 2; %through ice
    end
end
depth = depth+200; %match surface



%% plot the Radargrams over vostok and very frozen scaled to correct depth
% for count = 17:21
y = (1:length(GdB40));
imNum = [29,39,40,43,44];
h = {h29 h39 h40 h43 h44};
H = {H29 H39 H40 H43 H44};

%% New Depth
depth2 = cell(1,5);
time = fasttime{1} * 10^-6;
for i = 1:5
    depth2{i} = zeros(size(pow{i}));
    for j = 1:size(pow{i},2)
        d2 = 3e8 * time(1) ./ 2;
        for k = 2:size(pow{i},1)
            if d2(k-1) < h{i}(j)
                d2(k) = d2(k-1) + 3*10^8 .* (time(k)-time(k-1)) ./ 2; %two way travel time through air
            else
                d2(k) = d2(k-1) + 3*10^8/sqrt(eps) .* (time(k)-time(k-1)) ./ 2; %through ice
            end
        end
        depth2{i}(:,j) = d2 - h{i}(j); % subtract to match surface
    end
end
                
%% Plot
% 
% for count = 1:5
%     figure(count)
%     imagesc(y,depth,pow{count});
%     c = colorbar;
%     colormap(gray(256));
%     % title(h,'Propagation Delay, \mu s');
%     title(c,'dB');
% %     ylabel('thickness (m)')
%     title(['IRMCR1B20131127010',int2str(imNum(count))]);
%     hold on; plot(h{count},'r','LineWidth',2) %surface
%     hold on; plot(h{count}+H{count},'b','LineWidth',2) %bed
%     set(gca, 'YDir','reverse')
%     ylabel('thickness (m)')
%     xlabel('distance (m)')
%     if count == 1
% %         hold on; plot([850 850],[min(depth) max(depth)],'k','LineWidth',2)
% %         hold on; plot([860 860],[min(depth) max(depth)],'k','LineWidth',2)
% %          
% %         hold on; plot([1150 1150],[min(depth) max(depth)],'k','LineWidth',2)
% %         hold on; plot([1160 1160],[min(depth) max(depth)],'k','LineWidth',2)
% % 
% %         hold on; plot([1380 1380],[min(depth) max(depth)],'k','LineWidth',2)
% %         hold on; plot([1390 1390],[min(depth) max(depth)],'k','LineWidth',2)
%                        
%     end
% 
%     if count == 2
% %         hold on; plot([1460 1460],[min(depth) max(depth)],'k','LineWidth',2)
% %         hold on; plot([1470 1470],[min(depth) max(depth)],'k','LineWidth',2)
%                        
%     end
%     if count == 3
% %         hold on; plot([86 86],[min(depth) max(depth)],'k','LineWidth',2)
% %         hold on; plot([96 96],[min(depth) max(depth)],'k','LineWidth',2)
% %        
% %         hold on; plot([480 480],[min(depth) max(depth)],'k','LineWidth',2)
% %         hold on; plot([490 490],[min(depth) max(depth)],'k','LineWidth',2)
%                 
%     end
%     if count == 4
% %         hold on; plot([285 285],[min(depth) max(depth)],'k','LineWidth',2)
% %         hold on; plot([295 295],[min(depth) max(depth)],'k','LineWidth',2)
% %         
% %         hold on; plot([345 345],[min(depth) max(depth)],'k','LineWidth',2)
% %         hold on; plot([355 355],[min(depth) max(depth)],'k','LineWidth',2)
% %         
% %         hold on; plot([390 390],[min(depth) max(depth)],'k','LineWidth',2)
% %         hold on; plot([400 400],[min(depth) max(depth)],'k','LineWidth',2)
% 
% %         hold on; plot([740 740],[min(depth) max(depth)],'k','LineWidth',2)
% %         hold on; plot([750 750],[min(depth) max(depth)],'k','LineWidth',2)    
%     end
%     if count == 5                
%         hold on; plot([390 390],[min(depth) max(depth)],'k','LineWidth',2)
%         hold on; plot([400 400],[min(depth) max(depth)],'k','LineWidth',2)
% 
%         hold on; plot([640 640],[min(depth) max(depth)],'k','LineWidth',2)
%         hold on; plot([650 650],[min(depth) max(depth)],'k','LineWidth',2)
%         
%         hold on; plot([800 800],[min(depth) max(depth)],'k','LineWidth',2)
%         hold on; plot([810 810],[min(depth) max(depth)],'k','LineWidth',2)
% 
%     end
% 
% %     grid on
% end
%% calculate several power averages over lake V and frozen
DomeCPow = [mean(pow{1}(:,850:850),2) mean(pow{1}(:,1150:1160),2) mean(pow{1}(:,1380:1390),2)];
DomeCPowAvg = mean(DomeCPow,2);
VosPow = [mean(pow{2}(:,1460:1460),2) mean(pow{3}(:,86:96),2) mean(pow{3}(:,480:490),2)];
VosPowAvg = mean(VosPow,2);
FrozPow = [mean(pow{4}(:,285:295),2) mean(pow{4}(:,345:355),2) mean(pow{4}(:,390:400),2)];
FrozPowAvg = mean(FrozPow,2);
Froz2Pow = [mean(pow{5}(:,390:400),2) mean(pow{5}(:,640:650),2) mean(pow{5}(:,800:810),2)];
Froz2PowAvg = mean(Froz2Pow,2);

%% linear fit to attenuation loss
DomeCLinFit = polyfit(DomeCPowAvg(300:850),depth(300:850).',1);
X = [ones(length(DomeCPowAvg(300:850)),1) DomeCPowAvg(300:850)];
b = X\depth(300:850).';
yCalc2C = X*b;
VosLinFit = polyfit(VosPowAvg(340:1230),depth(340:1230).',1);
X = [ones(length(VosPowAvg(340:1230)),1) VosPowAvg(340:1230)];
b = X\depth(340:1230).';
yCalc2 = X*b;
FrozLinFit = polyfit(FrozPowAvg(300:850),depth(300:850).',1);
XF = [ones(length(FrozPowAvg(300:850)),1) FrozPowAvg(300:850)];
bF = XF\depth(300:850).';
yCalc2F = XF*bF;
Froz2LinFit = polyfit(Froz2PowAvg(300:850),depth(300:850).',1);
XF2 = [ones(length(Froz2PowAvg(300:850)),1) Froz2PowAvg(300:850)];
bF2 = XF2\depth(300:850).';
yCalc2F2 = XF2*bF2;

%% plot power as a function of depth
% figure(2)
% 
% hold on; plot(DomeCPowAvg,depth,'Color','k','LineWidth',3) % 39 - 42 DomeC
% hold on; plot(VosPowAvg,depth,'b','LineWidth',3) % 39 - 42 over vostok
% % hold on; plot(FrozPowAvg,depth,'k','LineWidth',3) % 44 - 45 very frozen
% % hold on; plot(Froz2PowAvg,depth,'g','LineWidth',3) % 44 - 45 very frozen 2
% 
% % add linear fits
% hold on; plot(VosPowAvg(340:1230),yCalc2,'r','LineWidth',3)
% % hold on; plot(FrozPowAvg(300:850),yCalc2F,'r','LineWidth',3)
% % hold on; plot(Froz2PowAvg(300:850),yCalc2F2,'r','LineWidth',3)
% hold on; plot(DomeCPowAvg(300:850),yCalc2C,'r','LineWidth',3)
% 
% hold on; plot(-120:10:-50,polyval(VosLinFit,-120:10:-50),'--r','LineWidth',2)
% % hold on; plot(-120:10:-50,polyval(FrozLinFit,-120:10:-50),'--r','LineWidth',2)
% % hold on; plot(-120:10:-50,polyval(Froz2LinFit,-120:10:-50),'--r','LineWidth',2)
% hold on; plot(-120:10:-50,polyval(DomeCLinFit,-120:10:-50),'--r','LineWidth',2)
% 
% set(gca, 'YDir','reverse')
% set(gca,'FontSize',18)
% 
% ylabel('thickness (m)')
% xlabel('dB')
% ylim([1000 5500])
% xlim([-120 -50]);
% xticks([-120:10:-50]);
% grid on
% 
% % legend('Vostok ','Very Frozen','Location','SouthEast')
% title('Attentuation loss with depth')
Vslope = 1/VosLinFit(1)*1000; % dB/km
Fslope = 1/FrozLinFit(1)*1000; %dB/km
F2slope = 1/Froz2LinFit(1)*1000; %dB/km
DomeCSlope = 1/DomeCLinFit(1)*1000; %dB/km


%% Save relevant variables
data = {data29, data39, data40, data43, data44};
files = {flight_29, flight_39, flight_40, flight_43, flight_44};
depth=depth2;
save('radargrams.mat','pow','h','H','data','files','depth')

