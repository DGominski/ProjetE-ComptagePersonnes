clear all;
close all;
clc;

addpath('/img'); %données
addpath('/data'); %set d'apprentissage


%% TRAINING SVM



%% ACQUISITION DE L'IMAGE

img = imread('detection_0200.jpeg');
img = rgb2gray(img);

%% MOYENNAGE POUR ELIMINATION DE L'ARRIERE PLAN

% Ac = backgroundfilter(A);
% figure;
% histogram(Ac);

%% DECOUPAGE DE L'IMAGE
array = decoupe(img,40,100,10);
nombre_de_fenetres_testees = size(array,3)
figure;

%% EXTRACTION DE DESCRIPTEURS LOCAUX SUR LES BLOCS

for i=1:nombre_de_fenetres_testees
    hogData = extractHOGFeatures(double(array(:,:,i)),'CellSize',HOG_cell);
end


%% CLASSIFICATION

n = randn(1:20
set = cat(1,horzcount,vertcount,diagcount);
result = svmclassify(svmStruct',set');