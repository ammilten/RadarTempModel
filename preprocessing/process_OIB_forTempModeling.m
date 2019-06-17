clear; close all;
load('radargrams.mat')
n = length(H);


%% Surface Depth, Power, Index
H0 = cell(size(h));
P0 = cell(size(h));
I0 = cell(size(h));

for i = 1:n
    H0{i} = zeros(size(h{i}));
    P0{i} = zeros(size(h{i}));
    I0{i} = zeros(size(h{i}));
    
    for j = 1:size(depth{i},2)
        [~,d] = min(abs(depth{i}(:,j) - h{i}(j)-500));
        trace = pow{i}(:,j);
        [v,d2] = findMaxAbove(trace,d);
        
        H0{i}(j) = depth{i}(d2,j);
        P0{i}(j) = v;
        I0{i}(j) = d2;
    end
end

%% Bed Pick, Power, Index
Hb = cell(size(H));
Pb = cell(size(H));
Ib = cell(size(H));

for i = 1:n
    Hb{i} = zeros(size(h{i}));
    Pb{i} = zeros(size(h{i}));
    Ib{i} = zeros(size(h{i}));
    
    for j = 1:size(depth{i},2)
        [~,d] = min(abs(depth{i}(:,j) - H{i}(j)));
        trace = pow{i}(1:d+200,j);
        [Pwr_bed, d2] = findMaxBelow(trace,d-50);
        
        Hb{i}(j) = depth{i}(d2,j);
        Pb{i}(j) = Pwr_bed;
        Ib{i}(j) = d2;
    end
end

%% Find ice thickness (H)
%round to nearest meter
Thx = cell(size(H));
for i = 1:length(H)
    Thx{i} = round(Hb{i}-H0{i});
end

%% Start (Below Firn) Depth, Power, Index 
start = 1000; %always start 1000m below surface

% all values in Hs will be constant but doing this for ease of formatting
Hs = cell(size(H));
Ps = cell(size(H));
Is = cell(size(H));

for i = 1:n
    Hs{i} = zeros(size(H{i})) + start;
    
    hh = zeros(size(H{i}));
    dd = zeros(size(H{i}));
    for j = 1:size(depth{i},2)
        [~,d] = min(abs(depth{i}(:,j) - Hs{i}(j)));
        %hh(j) = pow{i}(d,j);
        hh(j) = mean(pow{i}(d-25:d+25,j)); %Averaging 50 samples below
        dd(j) = d;
    end
    Ps{i} = hh;
    Is{i} = dd;
end


%% Noise Floor Depth, Power, Index (He)
He = cell(size(H));
Pe = cell(size(H));
Ie = cell(size(H));

buff = 200;
for i = 1:n
    nf = zeros(size(H{i}));
    pf = zeros(size(H{i}));
    aa = zeros(size(H{i}));
    
    for j = 1:size(H{i},1)
        [~,d] = min(abs(depth{i}(:,j) - Hb{i}(j)));
        trace = pow{i}(buff:d+50,j);
        ii = findNoiseFloor(trace);
        if isnan(ii)
            nf(j) = nan;
            pf(j) = nan;
        else
            ii = ii + buff;
            nf(j) = depth{i}(ii,j);
            pf(j) = pow{i}(ii,j);
            aa(j) = ii;
        end
    end
    He{i} = nf;
    Pe{i} = pf;
    Ie{i} = aa;
end

%% Plotting to see how we did on picks
figure; 
for i = 1:5
    subplot(1,5,i)
    imagesc(pow{i})
    colormap('gray')
    hold on
    
    %Attenuation bounds
    plot(1:length(He{i}),Is{i},'.w') %Start depth
    plot(1:length(Hs{i}),Ie{i},'.w') % Noise Floor
    
    %Surface
    plot(1:length(H0{i}),I0{i},'.r') 
    
    %Bed
    plot(1:length(Hb{i}),Ib{i},'.b') 

end

%% Compute 1 way attenuation rate (N)
N = cell(size(H));

for i = 1:length(H)
    
    attn1way = zeros(size(H{i}));
    for j = 1:length(attn1way)
        
        pts = pow{i}(Is{i}(j):Ie{i}(j),j);
        deps = depth{i}(Is{i}(j):Ie{i}(j),j);
        
        linefit = polyfit(deps,pts,1);
        
        attn1way(j) = -1 * linefit(1) * 1000 / 2; %Convert to dB/km 1-way 
    end
    N{i} = attn1way;
end

%% Save Data

save('FullProcessedData.mat','H0','P0','I0','Hs','Ps','Is','He','Pe','Ie','Hb','Pb','Ib','pow','depth','Thx','N')
save('TempModelData.mat','Hs','He','Thx','Ps','Pb','N')

