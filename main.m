close all;
clear all;
clc;

addpath('dataPieton');
addpath('img');

pietName = ['pieton_',num2str(1,'%0.2d'),'.jpeg'];
fondName = ['fond_',num2str(1,'%0.2d'),'.jpeg'];

%% 
for n = 1:10
    pietData(n,:,:) = imread(pietName);
    fondData(n,:,:) = imread(fondName);
end

dataRef = [pietData fondData];
classType = [ones(size(pietData,1),1);zeros(size(fondData,1),1)];

%%

%% 
figure;
svmStruct = svmtrain(dataRef,classType,'ShowPlot',true);