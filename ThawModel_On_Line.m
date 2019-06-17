clear; close all
%% Path Setup

% Name of results folder to be created 
saveFolderName = 'ThawModelResults3';

% Where TempModelData.mat and FullProcessedData.mat are stored
base = '/home/ammilten/Documents/Stanford/Second Project/Attenuation Model/Data/Vostok Radar Line/';

%% Sampling Setup
nsamples = 1000;
sigObsN = 2; %dB/km 2-way
sigObsB = 5; %dB
dz = 1;

r = 2; %radargram number (1-5)

%% Importing data 
run('prioruncertainty_vostok.m')
data = [base, 'TempModelData.mat'];
full = [base, 'FullProcessedData.mat'];
load(data)

%% Creating results folder
dest = [base, saveFolderName];
mkdir(dest)
copyfile(data,[dest,'/inputs.mat'])
copyfile(full,[dest,'/full.mat'])

subdest = [dest,'/radargram',num2str(r)];
mkdir(subdest);

%% Main Loop
parfor i = 200:250
    
    tic
%     thx = Thx{r}(i); %m
%     attn1way = N{r}(i);
%     pb = Pb{r}(i);
%     ps = Ps{r}(i);
%     hs = Hs{r}(i);
%     he = He{r}(i);
    
    [p,T,A,posterior_params] = findThawProb(N{r}(i), Pb{r}(i), Ps{r}(i), Hs{r}(i), He{r}(i), Thx{r}(i), prior, nsamples, sigObsN, sigObsB, dz,'FixedTb');
    saveresults([subdest,'/trace',num2str(i),'.mat'],p,posterior_params)
    time = toc;
    
    disp(['Time for trace ',num2str(i),': ',num2str(time),' seconds'])
end

