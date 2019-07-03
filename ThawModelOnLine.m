function ThawModelOnLine(r,saveFolderName,varargin)
%% Sampling Setup

nsamples = 1000;
sigObsN = 1; %dB/km 2-way
sigObsB = 5; %dB
dz = 1;
theta = 0.2;

%r = 2; %radargram number (1-5)

%saveFolderName = '/home/ammilten/ThawModelResults';

%% Importing data 
addpath(genpath('src'))

base = 'preprocessing/'; % Where TempModelData.mat and FullProcessedData.mat are stored

prior = loadprior();
data = [base, 'TempModelData.mat'];
full = [base, 'FullProcessedData.mat'];

load(data)

%% Creating results folder
dest = saveFolderName;
mkdir(dest)
copyfile(data,[dest,'/inputs.mat'])
copyfile(full,[dest,'/full.mat'])

subdest = [dest,'/radargram',num2str(r)];
mkdir(subdest);

val = nargin;
if val == 2
    disp('using two delta r')
else
    disp('using one delta r')
end

%% Main Loop
parfor i = 1:length(Thx{r})
    
    f = [subdest,'/trace',num2str(i),'.mat'];
    
    if exist(f, 'file') == 0
        tic
        if val==2
            [p,T,A,posterior_params] = findThawProb(N{r}(i), Pb{r}(i), Ps{r}(i), Hs{r}(i), He{r}(i), Thx{r}(i), prior, nsamples, sigObsN, sigObsB, dz, theta, 'FixedTb');
        else
            [p,T,A,posterior_params] = findThawProb(N{r}(i), Pb{r}(i), Ps{r}(i), Hs{r}(i), He{r}(i), Thx{r}(i), prior, nsamples, sigObsN, sigObsB, dz, theta, 'FixedTb',1);
        end
        time = toc;

        saveresults(f,p,posterior_params,time)
        disp(['Time for trace ',num2str(i),': ',num2str(time),' seconds'])
    else
        disp(['Trace ',num2str(i),' already exists'])
    end
    
end

