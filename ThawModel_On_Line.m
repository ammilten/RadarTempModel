clear; close all

%% Sampling Setup

nsamples = 1000;
sigObsN = 1; %dB/km 2-way
sigObsB = 5; %dB
dz = 1;

r = 2; %radargram number (1-5)

saveFolderName = '/home/ammilten/ThawModelResults';

%% Importing data 

base = 'preprocessing/'; % Where TempModelData.mat and FullProcessedData.mat are stored
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
parfor i = 1:length(Thx{r})
    
    tic
    [p,T,A,posterior_params] = findThawProb(N{r}(i), Pb{r}(i), Ps{r}(i), Hs{r}(i), He{r}(i), Thx{r}(i), prior, nsamples, sigObsN, sigObsB, dz,'FixedTb');
    time = toc;
    
    saveresults([subdest,'/trace',num2str(i),'.mat'],p,posterior_params,time)
    disp(['Time for trace ',num2str(i),': ',num2str(time),' seconds'])
    
end

