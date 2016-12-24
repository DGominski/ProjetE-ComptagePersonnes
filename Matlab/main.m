clear all;
close all;
clc;


%% TRAINING SVM

Nref = 10;
HOG_cell = [8 8];
trainSVM;

%% ACQUISITION DE L'IMAGE

img = imread('detection_0200.jpeg');
img = rgb2gray(img);

%% MOYENNAGE POUR ELIMINATION DE L'ARRIERE PLAN

% Ac = backgroundfilter(A);
% figure;
% histogram(Ac);

%% DECOUPAGE DE L'IMAGE

array = decoupe(img,40,100,20);
nombre_de_fenetres_testees = size(array,3)

%% EXTRACTION DE DESCRIPTEURS LOCAUX SUR LES BLOCS

for i=1:nombre_de_fenetres_testees
    hogData(i,:) = extractHOGFeatures(double(array(:,:,i)),'CellSize',HOG_cell);
end


%% CLASSIFICATION

for i=1:nombre_de_fenetres_testees
    result(i) = svmclassify(svmStruct,hogData(i,:));
end


%% GESTION DES IDENTIFICATIONS REDONDANTES


