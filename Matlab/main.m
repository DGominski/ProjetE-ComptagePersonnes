clear all;
close all;
clc;

addpath('/img');

%% ACQUISITION DE L'IMAGE

script_1_load_data;

%% MOYENNAGE POUR ELIMINATION DE L'ARRIERE PLAN

Ac = backgroundfilter(A);
figure;
histogram(Ac);

%% DECOUPAGE DE L'IMAGE
array = decoupe(img,300,200);
figure;


%% TRAINING SVM AVEC SET DE DONNEES DE REFERENCE

set = reshape(A,1,[]);
group = 1:length(set);
figure;
svmStruct = svmtrain(set,group,'ShowPlot',true);

%% EXTRACTION DE DESCRIPTEURS LOCAUX SUR LES BLOCS



%% CLASSIFICATION