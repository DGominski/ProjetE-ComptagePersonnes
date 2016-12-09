close all;
clear all;
clc;

addpath('dataPieton');
addpath('img');

%% 
N = 10;
for n = 1:N
    
    pietName = ['pieton_',num2str(n,'%0.2d'),'.jpeg'];
    fondName = ['fond_',num2str(n,'%0.2d'),'.jpeg'];

    pietData(n,:,:) = imread(pietName);
    fondData(n,:,:) = imread(fondName);
end

dataRef = [pietData fondData];
classType = [ones(size(pietData,1),1);zeros(size(fondData,1),1)];

%% Sobel
Gx = [-1 0 1;
     -2 0 2;
     -1 0 1]
Gy = Gx';
H = 10;
for i = 1:N
    Gx_piet = filter2(Gx,squeeze(pietData(i,:,:)));
    Gy_piet = filter2(Gy,squeeze(pietData(i,:,:)));
    Gx_fond = filter2(Gx,squeeze(fondData(i,:,:)));
    Gy_fond = filter2(Gy,squeeze(fondData(i,:,:)));
    dataSobelPiet = squeeze(sqrt(Gy_piet.^2 + Gx_piet.^2));
    dataSobelFond = squeeze(sqrt(Gy_fond.^2 + Gx_fond.^2));
    hPiet = histogram(dataSobelPiet,H);
    dataHistPiet{i} = hPiet.Values;
    hFond = histogram(dataSobelFond,H);
    dataHistFond{i} = hFond.Values;
    close
end

dataHist = [dataHistPiet dataHistFond];

%% 

figure;
svmStruct = svmtrain(dataRef,classType,'ShowPlot',true);